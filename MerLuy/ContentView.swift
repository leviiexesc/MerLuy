import SwiftUI

struct ContentView: View {
    enum Tab: Int { case home, exchange, settings }
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .exchange: ExchangeView()
                case .settings: SettingsView()
                }
            }
            .safeAreaPadding(.bottom, 74)

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    private let tabs: [(ContentView.Tab, String, String)] = [
        (.home, "Home", "house"),
        (.exchange, "Exchange", "arrow.triangle.2.circlepath"),
        (.settings, "Settings", "gearshape")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.0.rawValue) { tab in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { selectedTab = tab.0 }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.2)
                            .font(.system(size: 17, weight: .semibold))
                        Text(tab.1)
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == tab.0 ? MerLuyTheme.indigo : MerLuyTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(selectedTab == tab.0 ? Color.white.opacity(0.10) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(.ultraThinMaterial.opacity(0.5))
        .glassCard(radius: 25)
    }
}

#Preview { ContentView() }
