import SwiftUI

struct ContentView: View {
    enum Tab: Int { case home, exchange, profile, settings, admin }
    @State private var selectedTab: Tab = .home
    @EnvironmentObject private var profile: UserProfile

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .exchange: ExchangeView()
                case .profile: ProfileView()
                case .settings: SettingsView()
                case .admin: AdminView()
                }
            }
            .padding(.bottom, 92)
            .safeAreaPadding(.bottom, 0)

            CustomTabBar(selectedTab: $selectedTab, adminAuthenticated: profile.isAdmin, isLoggedIn: profile.isLoggedIn)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
        }
        .onChange(of: profile.isAdmin) { isAdmin in
            if !isAdmin, selectedTab == .admin { selectedTab = .profile }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    let adminAuthenticated: Bool
    let isLoggedIn: Bool

    private var tabs: [(ContentView.Tab, String, String)] {
        var items: [(ContentView.Tab, String, String)] = [
            (.home, "Home", "house.fill"),
            (.exchange, "Exchange", "arrow.triangle.2.circlepath"),
            (.profile, isLoggedIn ? "Profile" : "Account", "person.crop.circle.fill"),
            (.settings, "Settings", "gearshape.fill")
        ]
        if adminAuthenticated { items.append((.admin, "Admin", "chart.bar.xaxis")) }
        return items
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(tabs, id: \.0.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) { selectedTab = tab.0 }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.2)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.1)
                            .font(.system(size: 9, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selectedTab == tab.0 ? MerLuyTheme.indigo : MerLuyTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 60)
                    .contentShape(Rectangle())
                    .background {
                        if selectedTab == tab.0 {
                            Capsule()
                                .fill(LinearGradient(colors: [Color.white.opacity(0.22), MerLuyTheme.indigo.opacity(0.25)], startPoint: .top, endPoint: .bottom))
                                .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
                        }
                    }
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.1)
                .accessibilityAddTraits(selectedTab == tab.0 ? .isSelected : [])
            }
        }
        .padding(5)
        .frame(maxWidth: 620)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().fill(Color.white.opacity(0.04)))
                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.40), radius: 22, y: 10)
        }
        .contentShape(Capsule())
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: selectedTab)
    }
}

#Preview { ContentView() }
