import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var currencyAPI: CurrencyAPIService
    @EnvironmentObject private var language: LanguageManager
    @EnvironmentObject private var notifications: NotificationService
    @EnvironmentObject private var usage: AppUsageStore
    @State private var showingNotifications = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HomeHeader(showingNotifications: $showingNotifications, unreadCount: notifications.unreadCount)
                if let statusMessage = notifications.statusMessage {
                    Label(statusMessage, systemImage: "bell.badge.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(MerLuyTheme.positive)
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.language.text("Welcome to MerLuy"))
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Text(language.language.text("Real-time liquid-grade global transactions"))
                        .font(.system(size: 13))
                        .foregroundStyle(MerLuyTheme.textSecondary)
                }
                .padding(.top, 3)

                VStack(alignment: .leading, spacing: 12) {
                    Text(language.language.text("Live Markets"))
                        .font(.system(size: 15, weight: .bold))
                    ForEach(SampleData.rates) { rate in
                        MarketCard(rate: rate, liveRate: currencyAPI.rate(from: rate.from, to: rate.to))
                    }
                }

                QuickConvertCard()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationCenterView()
        }
        .task {
            usage.recordHomeOpen()
            await currencyAPI.fetchRates()
        }
    }
}

private struct HomeHeader: View {
    @Binding var showingNotifications: Bool
    let unreadCount: Int

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [Color.cyan, MerLuyTheme.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 30, height: 30)
                Text("MerLuy")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            Spacer()
            Button {
                showingNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.12)))
                    if unreadCount > 0 {
                        Text(unreadCount > 9 ? "9+" : "\(unreadCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(MerLuyTheme.negative)
                            .clipShape(Circle())
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

private struct MarketCard: View {
    let rate: ExchangeRate
    let liveRate: Double?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(rate.from.flag + rate.to.flag)
                    Text(rate.pairName)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text((liveRate ?? rate.rate).formatted(.number.precision(.fractionLength(rate.rate > 10 ? 2 : 4))))
                    .font(.system(size: 21, weight: .bold, design: .monospaced))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 11) {
                Text(String(format: "%+.2f%%", rate.change))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(rate.change >= 0 ? MerLuyTheme.positive : MerLuyTheme.negative)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background((rate.change >= 0 ? MerLuyTheme.positive : MerLuyTheme.negative).opacity(0.13))
                    .clipShape(Capsule())
                Text("1 \(rate.from.code)")
                    .font(.system(size: 10))
                    .foregroundStyle(MerLuyTheme.textSecondary)
            }
        }
        .padding(13)
        .glassCard(radius: 16)
    }
}

private struct QuickConvertCard: View {
    @EnvironmentObject private var language: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(language.language.text("Quick Convert"))
                .font(.system(size: 15, weight: .bold))
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text(language.language.text("You send")).font(.system(size: 10)).foregroundStyle(MerLuyTheme.textSecondary)
                    Text("1,000").font(.system(size: 19, weight: .bold, design: .monospaced))
                }
                Spacer()
                CurrencyPill(currency: SampleData.usd)
            }
            Divider().overlay(MerLuyTheme.divider)
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text(language.language.text("You receive")).font(.system(size: 10)).foregroundStyle(MerLuyTheme.textSecondary)
                    Text("924.10").font(.system(size: 19, weight: .bold, design: .monospaced)).foregroundStyle(MerLuyTheme.indigo)
                }
                Spacer()
                CurrencyPill(currency: SampleData.eur)
            }
        }
        .padding(16)
        .glassCard(radius: 18)
    }
}

struct CurrencyPill: View {
    let currency: Currency
    var body: some View {
        HStack(spacing: 5) {
            Text(currency.flag).font(.system(size: 16))
            Text(currency.code).font(.system(size: 11, weight: .bold))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.10))
        .clipShape(Capsule())
    }
}
