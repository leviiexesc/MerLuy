require('dotenv').config();
const express = require('express');
const fs = require('fs');
const admin = require('firebase-admin');
const apn = require('apn');

const app = express();
const port = Number(process.env.PORT || 3000);
const registeredTokens = {
  ios: new Set(),
  android: new Set(),
};

app.use(express.json({ limit: '1mb' }));

function normalizeText(value) {
  return String(value || '').trim();
}

function sendJSON(res, status, payload) {
  res.status(status).json(payload);
}

function initFirebase() {
  if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
    console.log('Firebase not configured. Android push is disabled until a service account is added.');
    return;
  }

  try {
    const serviceAccount = JSON.parse(
      Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8')
    );

    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }

    console.log('Firebase initialized.');
  } catch (error) {
    console.error('Invalid FIREBASE_SERVICE_ACCOUNT config:', error.message);
  }
}

let apnProvider = null;
function initAPNS() {
  if (!process.env.APNS_KEY_ID || !process.env.APNS_TEAM_ID || !process.env.APNS_BUNDLE_ID) {
    console.log('APNS not configured. iPhone push is disabled until Apple credentials are added.');
    return;
  }

  const apnsKeyPath = process.env.APNS_KEY_PATH || './AuthKey.p8';
  if (!fs.existsSync(apnsKeyPath)) {
    console.log('APNS key file not found at', apnsKeyPath, '. iPhone push is disabled until it is added.');
    return;
  }

  apnProvider = new apn.Provider({
    token: {
      key: fs.readFileSync(apnsKeyPath),
      keyId: process.env.APNS_KEY_ID,
      teamId: process.env.APNS_TEAM_ID,
    },
    production: process.env.APNS_ENV === 'production',
    connectionTimeout: 60,
  });

  console.log('APNS initialized.');
}

async function sendAndroidNotification(token, title, body) {
  if (!token || !admin.apps.length) {
    return { ok: false, reason: 'android token missing or firebase not configured' };
  }

  try {
    const message = {
      token,
      notification: { title, body },
      android: {
        priority: 'high',
        notification: {
          channelId: 'merluy_alerts',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    return { ok: true, response };
  } catch (error) {
    return { ok: false, reason: error.message };
  }
}

async function sendIOSNotification(token, title, body) {
  if (!apnProvider || !token) {
    return { ok: false, reason: 'ios token missing or apns not configured' };
  }

  try {
    const note = new apn.Notification({
      aps: {
        alert: {
          title,
          body,
        },
        sound: 'default',
        badge: 1,
      },
    });

    note.topic = process.env.APNS_BUNDLE_ID;
    const result = await apnProvider.send(note, token);
    return { ok: result.failed.length === 0, result };
  } catch (error) {
    return { ok: false, reason: error.message };
  }
}

app.get('/health', (req, res) => {
  sendJSON(res, 200, {
    status: 'ok',
    message: 'MerLuy server is running.',
    iosTokens: registeredTokens.ios.size,
    androidTokens: registeredTokens.android.size,
  });
});

app.post('/api/register', (req, res) => {
  const { platform, deviceToken } = req.body || {};

  if (!platform || !deviceToken) {
    return sendJSON(res, 400, { error: 'platform and deviceToken are required.' });
  }

  const normalizedPlatform = String(platform).toLowerCase();
  if (normalizedPlatform !== 'ios' && normalizedPlatform !== 'android') {
    return sendJSON(res, 400, { error: 'platform must be ios or android.' });
  }

  registeredTokens[normalizedPlatform].add(deviceToken);
  return sendJSON(res, 200, {
    ok: true,
    platform: normalizedPlatform,
    registered: registeredTokens[normalizedPlatform].size,
  });
});

app.post('/api/notify', async (req, res) => {
  const title = normalizeText(req.body?.title || 'MerLuy');
  const message = normalizeText(req.body?.message || 'New update');
  const platform = String(req.body?.platform || '').toLowerCase();
  const deviceToken = normalizeText(req.body?.deviceToken || '');
  const sound = normalizeText(req.body?.sound || 'default');

  const targetPlatforms = platform ? [platform] : ['ios', 'android'];
  const results = [];

  for (const currentPlatform of targetPlatforms) {
    const tokens = deviceToken
      ? [deviceToken]
      : [...registeredTokens[currentPlatform]];

    if (!tokens.length) {
      results.push({ platform: currentPlatform, ok: false, reason: 'no device registered' });
      continue;
    }

    for (const token of tokens) {
      if (currentPlatform === 'ios') {
        const result = await sendIOSNotification(token, title, message);
        results.push({ platform: currentPlatform, token, ...result });
      } else {
        const result = await sendAndroidNotification(token, title, message);
        results.push({ platform: currentPlatform, token, ...result });
      }
    }
  }

  const anySuccess = results.some((entry) => entry.ok);
  return sendJSON(res, anySuccess ? 200 : 400, {
    ok: anySuccess,
    title,
    message,
    sound,
    results,
  });
});

app.listen(port, () => {
  console.log(`MerLuy server running on http://localhost:${port}`);
});

initFirebase();
initAPNS();
