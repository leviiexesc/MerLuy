package com.leviiexesc.merluy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.CurrencyExchange
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.app.NotificationCompat

private val Navy = Color(0xFF06164B)
private val Blue = Color(0xFF176EFF)
private val Cyan = Color(0xFF62F5FF)
private val Muted = Color(0xFF9DB7DF)
private val CardBlue = Color(0xFF123575)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { MerLuyApp() }
    }
}

private enum class Tab { HOME, EXCHANGE, ACCOUNT, SETTINGS, ADMIN }
private data class Rate(val flags: String, val pair: String, val value: String, val change: String)

@Composable
private fun MerLuyApp() {
    var tab by remember { mutableStateOf(Tab.HOME) }
    var loggedIn by remember { mutableStateOf(false) }
    var pro by remember { mutableStateOf(false) }
    var displayName by remember { mutableStateOf("MerLuy User") }
    var userEmail by remember { mutableStateOf("user@example.com") }
    val rates = listOf(
        Rate("🇺🇸🇪🇺", "USD → EUR", "0.9241", "+0.18%"),
        Rate("🇬🇧🇯🇵", "GBP → JPY", "191.56", "-0.45%"),
        Rate("🇪🇺🇺🇸", "EUR → USD", "1.0821", "+0.12%")
    )

    MaterialTheme {
        Scaffold(
            containerColor = Navy,
            bottomBar = { GlassNav(tab = tab, loggedIn = loggedIn, onSelect = { tab = it }) }
        ) { padding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Brush.radialGradient(listOf(Color(0xFF1267E8), Navy, Color(0xFF020817))))
                    .padding(padding)
            ) {
                when (tab) {
                    Tab.HOME -> HomeScreen(rates)
                    Tab.EXCHANGE -> ExchangeScreen()
                    Tab.ACCOUNT -> AccountScreen(
                        loggedIn = loggedIn,
                        pro = pro,
                        userName = displayName,
                        email = userEmail,
                        onLogin = { name, email ->
                            displayName = name
                            userEmail = email
                            loggedIn = true
                        },
                        onPro = { pro = true }
                    )
                    Tab.SETTINGS -> SettingsScreen()
                    Tab.ADMIN -> AdminScreen()
                }
            }
        }
    }
}

@Composable
private fun GlassNav(tab: Tab, loggedIn: Boolean, onSelect: (Tab) -> Unit) {
    val items = listOf(
        Triple(Tab.HOME, "Home", Icons.Default.Home),
        Triple(Tab.EXCHANGE, "Exchange", Icons.Default.CurrencyExchange),
        Triple(Tab.ACCOUNT, if (loggedIn) "Profile" else "Account", Icons.Default.AccountCircle),
        Triple(Tab.SETTINGS, "Settings", Icons.Default.Settings),
        Triple(Tab.ADMIN, "Admin", Icons.Default.BarChart)
    )

    Surface(
        modifier = Modifier
            .padding(horizontal = 12.dp, vertical = 10.dp)
            .navigationBarsPadding(),
        shape = RoundedCornerShape(30.dp),
        color = Color(0xDD17191C),
        tonalElevation = 8.dp,
        shadowElevation = 16.dp
    ) {
        Row(
            Modifier.fillMaxWidth().padding(5.dp),
            horizontalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            items.forEach { (item, label, icon) ->
                val selected = tab == item
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .height(62.dp)
                        .clickable { onSelect(item) }
                        .background(if (selected) Color.White.copy(alpha = 0.16f) else Color.Transparent, CircleShape),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(icon, label, tint = if (selected) Cyan else Muted, modifier = Modifier.size(21.dp))
                    Text(label, color = if (selected) Cyan else Muted, fontSize = 9.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

@Composable
private fun HomeScreen(rates: List<Rate>) {
    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(Modifier.height(10.dp)) }
        item {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Logo()
                Spacer(Modifier.width(8.dp))
                Text("MerLuy", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.weight(1f))
                Icon(
                    Icons.Default.Notifications,
                    contentDescription = "Notifications",
                    tint = Color.White,
                    modifier = Modifier.size(30.dp)
                )
            }
        }
        item {
            Text("Welcome to MerLuy", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold)
            Text("Real-time liquid-grade global transactions", color = Muted, fontSize = 13.sp, modifier = Modifier.padding(top = 4.dp))
        }
        item {
            Text("LIVE MARKETS", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }
        items(rates.size) { index ->
            RateCard(rates[index])
        }
        item {
            Text("QUICK CONVERT", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }
        item {
            GlassCard {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("You send\n1,000", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    Text("🇺🇸 USD", color = Color.White)
                }
                Spacer(Modifier.height(12.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("You receive\n924.10", color = Cyan, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    Text("🇪🇺 EUR", color = Color.White)
                }
            }
        }
    }
}

@Composable
private fun ExchangeScreen() {
    var amount by remember { mutableStateOf("100") }
    var result by remember { mutableStateOf("€85.00") }

    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(Modifier.height(12.dp)) }
        item {
            Text("Exchange", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold)
            Text("Convert between world currencies", color = Muted, fontSize = 13.sp, modifier = Modifier.padding(top = 4.dp))
        }
        item {
            Text("AMOUNT", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            OutlinedTextField(
                value = amount,
                onValueChange = { amount = it },
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                label = { Text("Amount") }
            )
        }
        item {
            GlassCard {
                Text("From", color = Muted)
                Text("🇺🇸  USD · US Dollar", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                Text("⇅", color = Cyan, fontSize = 28.sp, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                Text("To", color = Muted)
                Text("🇪🇺  EUR · Euro", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }
        }
        item {
            Button(
                onClick = { result = "៛410,000.00" },
                modifier = Modifier.fillMaxWidth().height(52.dp)
            ) {
                Text("Convert Amount")
            }
        }
        item {
            GlassCard {
                Text("RESULT", color = Color(0xFF4ADE80), fontSize = 11.sp)
                Text(result, color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.Bold)
                Text("Updated just now", color = Muted, fontSize = 11.sp)
            }
        }
    }
}

@Composable
private fun AccountScreen(
    loggedIn: Boolean,
    pro: Boolean,
    userName: String,
    email: String,
    onLogin: (String, String) -> Unit,
    onPro: () -> Unit
) {
    val context = LocalContext.current
    var mode by remember { mutableStateOf("login") }
    var name by remember { mutableStateOf(userName) }
    var emailValue by remember { mutableStateOf(email) }
    var password by remember { mutableStateOf("") }
    var error by remember { mutableStateOf<String?>(null) }

    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(Modifier.height(12.dp)) }
        item {
            Text(if (loggedIn) "Profile" else "Account", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold)
            Text("Your account, verification, and plan", color = Muted, fontSize = 13.sp, modifier = Modifier.padding(top = 4.dp))
        }
        item {
            GlassCard {
                Logo(64.dp)
                Text(
                    if (loggedIn) userName else "Create your account",
                    color = Color.White,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
                Text(
                    if (loggedIn) email else "Login or register to continue",
                    color = Muted,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
                if (!loggedIn) {
                    Row(
                        Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Button(
                            onClick = { mode = "login" },
                            modifier = Modifier.weight(1f)
                        ) {
                            Text("Login")
                        }
                        Button(
                            onClick = { mode = "register" },
                            modifier = Modifier.weight(1f)
                        ) {
                            Text("Register")
                        }
                    }
                    if (mode == "register") {
                        OutlinedTextField(
                            value = name,
                            onValueChange = { name = it },
                            modifier = Modifier.fillMaxWidth(),
                            label = { Text("Full name") }
                        )
                    }
                    OutlinedTextField(
                        value = emailValue,
                        onValueChange = { emailValue = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("Email") }
                    )
                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("Password") }
                    )
                    if (error != null) {
                        Text(error ?: "", color = Color(0xFFF87171), fontSize = 12.sp)
                    }
                    Button(
                        onClick = {
                            val validEmail = emailValue.contains("@") && emailValue.contains(".")
                            val validPassword = password.length >= 6
                            if (mode == "register") {
                                if (name.isBlank() || !validEmail || !validPassword) {
                                    error = "Enter your name, valid email and a 6+ character password."
                                    return@Button
                                }
                                onLogin(name.trim(), emailValue.trim())
                                error = null
                                Toast.makeText(context, "Account created", Toast.LENGTH_SHORT).show()
                            } else {
                                if (!validEmail || !validPassword) {
                                    error = "Use a valid email and 6+ character password."
                                    return@Button
                                }
                                onLogin(name.ifBlank { "MerLuy User" }, emailValue.trim())
                                error = null
                                Toast.makeText(context, "Welcome back", Toast.LENGTH_SHORT).show()
                            }
                        },
                        modifier = Modifier.fillMaxWidth().height(50.dp)
                    ) {
                        Text(if (mode == "login") "Login" else "Create account")
                    }
                }
            }
        }

        item {
            GlassCard {
                Text(if (pro) "Pro Plan · ACTIVE" else "Free Plan", color = if (pro) Color(0xFFFFE36E) else Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                if (!pro) {
                    OutlinedTextField(
                        value = "MERLUY-PRO-001",
                        onValueChange = {},
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("License key") }
                    )
                    Button(
                        onClick = { onPro(); Toast.makeText(context, "Pro activated", Toast.LENGTH_SHORT).show() },
                        modifier = Modifier.fillMaxWidth().height(50.dp)
                    ) {
                        Text("Activate Pro")
                    }
                }
            }
        }
    }
}

@Composable
private fun SettingsScreen() {
    var dark by remember { mutableStateOf(true) }
    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(Modifier.height(12.dp)) }
        item {
            Text("Settings", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold)
            Text("Manage your preferences", color = Muted, fontSize = 13.sp, modifier = Modifier.padding(top = 4.dp))
        }
        item {
            GlassCard {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Dark Theme", color = Color.White)
                    Switch(checked = dark, onCheckedChange = { dark = it })
                }
                Text("Language · English / Khmer", color = Color.White, modifier = Modifier.padding(top = 16.dp))
                Text("Default Currency · USD", color = Color.White, modifier = Modifier.padding(top = 16.dp))
            }
        }
        item {
            Text("ABOUT", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }
        item {
            GlassCard {
                Text("Privacy Policy", color = Color.White)
                Text("Rate MerLuy", color = Color.White, modifier = Modifier.padding(top = 16.dp))
                Text("Developed by Chiro · V Beta", color = Muted, modifier = Modifier.padding(top = 16.dp))
            }
        }
    }
}

@Composable
private fun AdminScreen() {
    val context = LocalContext.current
    var title by remember { mutableStateOf("MerLuy update") }
    var message by remember { mutableStateOf("Your exchange rates have been refreshed.") }

    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 18.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(Modifier.height(12.dp)) }
        item {
            Text("Admin Dashboard", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold)
            Text("Private workspace", color = Muted, fontSize = 13.sp, modifier = Modifier.padding(top = 4.dp))
        }
        item {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Stat("Users", "128")
                Stat("Conversions", "642")
            }
        }
        item {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Stat("Exchange opens", "96")
                Stat("API", "Live")
            }
        }
        item {
            GlassCard {
                Text("Notifications", color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.Bold)
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Title") }
                )
                OutlinedTextField(
                    value = message,
                    onValueChange = { message = it },
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Message") }
                )
                Button(
                    onClick = {
                        MerLuyNotificationHelper.send(context, title, message)
                        Toast.makeText(context, "Notification sent", Toast.LENGTH_SHORT).show()
                    },
                    modifier = Modifier.fillMaxWidth().height(50.dp)
                ) {
                    Text("Send Notification")
                }
            }
        }
    }
}

@Composable
private fun RowScope.Stat(label: String, value: String) {
    GlassCard(Modifier.weight(1f)) {
        Text(value, color = Color.White, fontSize = 23.sp, fontWeight = FontWeight.Bold)
        Text(label, color = Muted, fontSize = 11.sp)
    }
}

@Composable
private fun RateCard(rate: Rate) {
    GlassCard {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Column {
                Text("${rate.flags}  ${rate.pair}", color = Color.White, fontWeight = FontWeight.Bold)
                Text(rate.value, color = Color.White, fontSize = 23.sp, fontWeight = FontWeight.Bold)
            }
            Text(
                rate.change,
                color = if (rate.change.startsWith("+")) Color(0xFF4ADE80) else Color(0xFFF87171)
            )
        }
    }
}

@Composable
private fun GlassCard(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = CardBlue.copy(alpha = 0.8f)),
        shape = RoundedCornerShape(18.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            content = content
        )
    }
}

@Composable
private fun Logo(size: Dp = 34.dp) {
    Box(
        modifier = Modifier
            .size(size)
            .background(Brush.linearGradient(listOf(Cyan, Blue)), CircleShape),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            Icons.Default.CurrencyExchange,
            contentDescription = "MerLuy logo",
            tint = Color.White,
            modifier = Modifier.size(size * 0.55f)
        )
    }
}

private object MerLuyNotificationHelper {
    fun send(context: Context, title: String, message: String) {
        val channelId = "merluy_alerts"
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "MerLuy Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "MerLuy push messages"
                enableVibration(true)
                setSound(
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                    AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION).build()
                )
            }
            notificationManager?.createNotificationChannel(channel)
        }

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_merluy)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setDefaults(NotificationCompat.DEFAULT_ALL)

        notificationManager?.notify(System.currentTimeMillis().toInt(), builder.build())
    }
}
