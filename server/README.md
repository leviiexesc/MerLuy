# MerLuy Notification Server

This is a lightweight, GitHub-ready backend for sending push notifications to both iPhone and Android clients.

## What it does

- Accepts device registration from iOS and Android clients
- Broadcasts a notification to all registered devices
- Sends an iPhone notification through APNS
- Sends an Android notification through Firebase Cloud Messaging
- Works with free GitHub hosting workflows and a Free Render/Railway deployment

## Quick start

1. Open a terminal inside the `server/` folder.
2. Install dependencies:

   npm install

3. Create a `.env` file from `.env.example` and fill in your credentials.
4. Start the server:

   npm start

5. Test the health endpoint:

   curl http://localhost:3000/health

## API

### Register a device

POST /api/register

Example body:

```json
{
  "platform": "ios",
  "deviceToken": "<ios-device-token>"
}
```

### Send a notification

POST /api/notify

Example body:

```json
{
  "title": "MerLuy update",
  "message": "Your rates were refreshed.",
  "platform": "ios",
  "deviceToken": "<device-token>",
  "sound": "default"
}
```

If you omit `platform` and `deviceToken`, the server tries to broadcast to all registered devices.

## Free deployment options

- Render: free web service
- Railway: free starter plan
- Fly.io: free tier

These are the easiest options for a GitHub-connected backend. The push server itself is free to deploy, but iPhone delivery requires an Apple Developer account and APNS credentials.

## Important note for iPhone

Real APNS delivery for iPhone is not free. Apple requires an Apple Developer account and valid APNS credentials. Android push via Firebase is free. You can still build and test the server from GitHub without paying for Firebase, but a valid Apple developer setup is required for real iPhone push.
