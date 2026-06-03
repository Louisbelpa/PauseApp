import SwiftUI

struct RootView: View {
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    var body: some View {
        ZStack {
            if onboardingComplete {
                MainTabView().transition(.opacity)
            } else {
                OnboardingView { onboardingComplete = true }.transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: Theme.animDuration), value: onboardingComplete)
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Stats",    systemImage: "chart.bar.fill") }
            AppsListView().tabItem  { Label("Apps",     systemImage: "apps.iphone") }
            SettingsView().tabItem  { Label("Réglages", systemImage: "gearshape.fill") }
        }
        .tint(Theme.accent)
    }
}
