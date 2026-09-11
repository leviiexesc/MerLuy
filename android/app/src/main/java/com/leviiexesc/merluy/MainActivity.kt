package com.leviiexesc.merluy

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
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
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

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
    val rates = listOf(
        Rate("🇺🇸🇪🇺", "USD → EUR", "0.9241", "+0.18%"),
        Rate("🇬🇧🇯🇵", "GBP → JPY", "191.56", "-0.45%"),
        Rate("🇪🇺🇺🇸", "EUR → USD", "1.0821", "+0.12%")
    )

    MaterialTheme {
        Scaffold(
            containerColor = Navy,
            bottomBar = {
                GlassNav(tab = tab, loggedIn = loggedIn, onSelect = { tab = it })
            }
        ) { padding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Brush.radialGradient(listOf(Color(0xFF1267E8), Navy, Color(0xFF020817))))
                    .padding(padding)
            ) {
                when (tab) {
                    Tab.HOME -> HomeScreen(rates, onNotifications = { })
                    Tab.EXCHANGE -> ExchangeScreen()
                    Tab.ACCOUNT -> AccountScreen(loggedIn, pro, onLogin = { loggedIn = true }, onPro = { pro = true })
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
        modifier = Modifier.padding(horizontal = 12.dp, vertical = 10.dp).navigationBarsPadding(),
        shape = RoundedCornerShape(30.dp),
        color = Color(0xDD17191C),
        tonalElevation = 8.dp,
        shadowElevation = 16.dp
    ) {
        Row(Modifier.fillMaxWidth().padding(5.dp), horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            items.forEach { (item, label, icon) ->
                val selected = tab == item
                Column(
                    modifier = Modifier.weight(1f).height(62.dp).clickable { onSelect(item) }.background(if (selected) Color.White.copy(alpha = .16f) else Color.Transparent, CircleShape),
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
private fun ScreenColumn(content: @Composable () -> Unit) {
    LazyColumn(Modifier.fillMaxSize().padding(horizontal = 18.dp), verticalArrangement = Arrangement.spacedBy(12.dp), content = { item { content() } })
}

@Composable
private fun HomeScreen(rates: List<Rate>, onNotifications: () -> Unit) {
    ScreenColumn {
        Spacer(Modifier.height(10.dp))
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Logo(); Spacer(Modifier.width(8.dp)); Text("MerLuy", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold); Spacer(Modifier.weight(1f))
            Icon(Icons.Default.Notifications, "Notifications", tint = Color.White, modifier = Modifier.size(30.dp).clickable { onNotifications() })
        }
        Text("Welcome to MerLuy", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold)
        Text("Real-time liquid-grade global transactions", color = Muted, fontSize = 13.sp)
        Text("LIVE MARKETS", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        rates.forEach { rate -> RateCard(rate) }
        Text("QUICK CONVERT", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        GlassCard {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Text("You send\n1,000", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold); Text("🇺🇸 USD", color = Color.White) }
            Spacer(Modifier.height(12.dp)); Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Text("You receive\n924.10", color = Cyan, fontSize = 18.sp, fontWeight = FontWeight.Bold); Text("🇪🇺 EUR", color = Color.White) }
        }
    }
}

@Composable
private fun ExchangeScreen() {
    var amount by remember { mutableStateOf("100") }
    var result by remember { mutableStateOf("€85.00") }
    ScreenColumn {
        Spacer(Modifier.height(12.dp)); Text("Exchange", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold); Text("Convert between world currencies", color = Muted, fontSize = 13.sp)
        Text("AMOUNT", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        OutlinedTextField(amount, { amount = it }, Modifier.fillMaxWidth(), label = { Text("Amount") })
        GlassCard { Text("From", color = Muted); Text("🇺🇸  USD · US Dollar", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold); Text("⇅", color = Cyan, fontSize = 28.sp, modifier = Modifier.align(Alignment.CenterHorizontally)); Text("To", color = Muted); Text("🇪🇺  EUR · Euro", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold) }
        Button({ result = "៛410,000.00" }, Modifier.fillMaxWidth().height(52.dp)) { Text("Convert Amount") }
        GlassCard { Text("RESULT", color = Color(0xFF4ADE80), fontSize = 11.sp); Text(result, color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.Bold); Text("Updated just now", color = Muted, fontSize = 11.sp) }
    }
}

@Composable
private fun AccountScreen(loggedIn: Boolean, pro: Boolean, onLogin: () -> Unit, onPro: () -> Unit) {
    ScreenColumn {
        Spacer(Modifier.height(12.dp)); Text(if (loggedIn) "Profile" else "Account", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold); Text("Your account, verification, and plan", color = Muted, fontSize = 13.sp)
        GlassCard { Logo(64); Text(if (loggedIn) "MerLuy User" else "Create your account", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.CenterHorizontally)); Text(if (loggedIn) "user@example.com" else "Login or register to continue", color = Muted, modifier = Modifier.align(Alignment.CenterHorizontally)); if (!loggedIn) Button(onLogin, Modifier.fillMaxWidth().height(50.dp)) { Text("Login / Register") } }
        GlassCard { Text(if (pro) "Pro Plan · ACTIVE" else "Free Plan", color = if (pro) Color(0xFFFFE36E) else Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold); if (!pro) { OutlinedTextField("MERLUY-PRO-001", {}, Modifier.fillMaxWidth(), label = { Text("License key") }); Button(onPro, Modifier.fillMaxWidth().height(50.dp)) { Text("Scan & Activate Pro") } } }
    }
}

@Composable
private fun SettingsScreen() {
    var dark by remember { mutableStateOf(true) }
    ScreenColumn { Spacer(Modifier.height(12.dp)); Text("Settings", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold); Text("Manage your preferences", color = Muted, fontSize = 13.sp); GlassCard { Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Text("Dark Theme", color = Color.White); Switch(dark, { dark = it }) }; Text("Language · English / Khmer", color = Color.White, modifier = Modifier.padding(top = 16.dp)); Text("Default Currency · USD", color = Color.White, modifier = Modifier.padding(top = 16.dp)) }; Text("ABOUT", color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold); GlassCard { Text("Privacy Policy", color = Color.White); Text("Rate MerLuy", color = Color.White, modifier = Modifier.padding(top = 16.dp)); Text("Developed by Chiro · V Beta", color = Muted, modifier = Modifier.padding(top = 16.dp)) } }
}

@Composable
private fun AdminScreen() { ScreenColumn { Spacer(Modifier.height(12.dp)); Text("Admin Dashboard", color = Color.White, fontSize = 27.sp, fontWeight = FontWeight.ExtraBold); Text("Private workspace", color = Muted); Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) { Stat("Users", "128"); Stat("Conversions", "642") }; Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) { Stat("Exchange opens", "96"); Stat("API", "Live") }; GlassCard { Text("Notifications", color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.Bold); OutlinedTextField("MerLuy update", {}, Modifier.fillMaxWidth(), label = { Text("Title") }); Button({}, Modifier.fillMaxWidth().height(50.dp)) { Text("Send Notification") } } } }

@Composable private fun Stat(label: String, value: String) { GlassCard(Modifier.weight(1f)) { Text(value, color = Color.White, fontSize = 23.sp, fontWeight = FontWeight.Bold); Text(label, color = Muted, fontSize = 11.sp) } }
@Composable private fun RateCard(rate: Rate) { GlassCard { Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Column { Text("${rate.flags}  ${rate.pair}", color = Color.White, fontWeight = FontWeight.Bold); Text(rate.value, color = Color.White, fontSize = 23.sp, fontWeight = FontWeight.Bold) }; Text(rate.change, color = if (rate.change.startsWith("+")) Color(0xFF4ADE80) else Color(0xFFF87171) } } }
@Composable private fun GlassCard(modifier: Modifier = Modifier, content: @Composable () -> Unit) { Card(modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = CardBlue.copy(alpha = .8f)), shape = RoundedCornerShape(18.dp)) { Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp), content = content) } }
@Composable private fun Logo(size: androidx.compose.ui.unit.Dp = 34.dp) { Box(Modifier.size(size).background(Brush.linearGradient(listOf(Cyan, Blue)), CircleShape), contentAlignment = Alignment.Center) { Icon(Icons.Default.CurrencyExchange, "MerLuy", tint = Color.White, modifier = Modifier.size(size * .55f)) } }
