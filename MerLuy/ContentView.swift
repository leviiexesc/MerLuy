import SwiftUI

struct ContentView: View {
    enum Tab: Int { case home, exchange, settings, admin }
    @State private var selectedTab: Tab = .home
    @AppStorage("merluy.adminMode") private var adminMode = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .exchange: ExchangeView()
                case .settings: SettingsView()
                case .admin: AdminView()
                }
            }
            .padding(.bottom, 74)

            CustomTabBar(selectedTab: $selectedTab, adminMode: adminMode)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    let adminMode: Bool

    private var tabs: [(ContentView.Tab, String, String)] {
        var items: [(ContentView.Tab, String, String)] = [
            (.home, "Home", "house.fill"),
            (.exchange, "Exchange", "arrow.triangle.2.circlepath"),
            (.settings, "Settings", "gearshape.fill")
        ]
        if adminMode { items.append((.admin, "Admin", "bell.badge.fill")) }
        return items
    }

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
                    .frame(minHeight: 56)
                    .contentShape(Rectangle())
                    .background(selectedTab == tab.0 ? Color.white.opacity(0.10) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial.opacity(0.65))
        .glassCard(radius: 27)
        .animation(.easeInOut(duration: 0.22), value: selectedTab)
    }
}

#Preview { ContentView() }
