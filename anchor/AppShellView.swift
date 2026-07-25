//
//  AppShellView.swift
//  anchor
//

import SwiftUI

struct AppShellView: View {
    private enum Tab: Hashable, CaseIterable {
        case home
        case sessions
        case insights
        case profile
        case settings

        var title: String {
            switch self {
            case .home: "Home"
            case .sessions: "Sessions"
            case .insights: "Insights"
            case .profile: "Profile"
            case .settings: "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home: "house"
            case .sessions: "timer"
            case .insights: "chart.line.uptrend.xyaxis"
            case .profile: "person"
            case .settings: "gearshape"
            }
        }
    }

    let homeState: HomeViewState

    @State private var selectedTab = Tab.home
    @State private var isShowingSession = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Colors.canvas.ignoresSafeArea()

            // Every tab stays alive so its scroll position and selection
            // survive a switch, which a plain `switch` would discard.
            tab(.home) {
                NavigationStack {
                    HomeScreen(
                        state: homeState,
                        onStartSession: { isShowingSession = true },
                        onSeeAllSessions: { selectedTab = .sessions }
                    )
                    .navigationDestination(isPresented: $isShowingSession) {
                        ActiveSessionScreen()
                    }
                }
            }

            tab(.sessions) {
                NavigationStack { SessionsScreen() }
            }

            tab(.insights) {
                NavigationStack { InsightsScreen() }
            }

            tab(.profile) {
                NavigationStack { ProfileScreen() }
            }

            tab(.settings) {
                NavigationStack { SettingsScreen() }
            }
        }
        // The bar lives outside the NavigationStack, so it would otherwise sit
        // on top of a pushed session. Dropping it also frees the inset height.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isShowingSession {
                tabBar
            }
        }
        .tint(Colors.primary)
    }

    private func tab(_ value: Tab, @ViewBuilder content: () -> some View) -> some View {
        content()
            .opacity(selectedTab == value ? 1 : 0)
            .allowsHitTesting(selectedTab == value)
            .accessibilityHidden(selectedTab != value)
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases, id: \.self) { item in
                tabButton(item)
            }
        }
        .padding(6)
        .background(Colors.ink, in: Capsule())
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func tabButton(_ item: Tab) -> some View {
        let isSelected = selectedTab == item

        return Button {
            guard !isSelected else { return }
            if reduceMotion {
                selectedTab = item
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedTab = item
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: item.icon)
                    .font(.system(size: 17, weight: .medium))

                // The label rides along only for the selected tab, so five
                // items fit without shrinking the type.
                if isSelected {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .fixedSize()
                }
            }
            .foregroundStyle(isSelected ? Colors.ink : Colors.onInk)
            .padding(.horizontal, isSelected ? 16 : 12)
            .frame(height: 46)
            .frame(maxWidth: isSelected ? .infinity : nil)
            .background(
                isSelected ? Color.white : Color.clear,
                in: Capsule()
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

}

struct FeaturePlaceholderView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        ZStack {
            CanvasBackground()

            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(Colors.onCanvas.opacity(0.8))

                Text(title)
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.8)
                    .foregroundStyle(Colors.onCanvas)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Colors.onCanvas.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    AppShellView(homeState: .empty)
}
