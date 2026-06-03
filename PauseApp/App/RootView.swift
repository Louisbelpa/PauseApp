import SwiftUI

struct RootView: View {
    @Binding var interventionTarget: InterventionTarget?
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    var body: some View {
        ZStack {
            if onboardingComplete {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView { onboardingComplete = true }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: Theme.animDuration), value: onboardingComplete)
        .fullScreenCover(item: $interventionTarget) { target in
            InterventionView(
                appName: target.appName,
                appScheme: target.appScheme
            ) { interventionTarget = nil }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Stats",    systemImage: "chart.bar.fill") }

            AppsListView()
                .tabItem { Label("Apps",     systemImage: "apps.iphone") }

            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape.fill") }
        }
        .tint(Theme.accent)
    }
}
