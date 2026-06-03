import SwiftUI
import FamilyControls

struct AppsListView: View {
    @Environment(BlockedAppsManager.self) private var manager
    @State private var showingPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    BlockingStatusCard()

                    let count = manager.activitySelection.applicationTokens.count
                    if count == 0 {
                        EmptySelectionView()
                    } else {
                        SelectedAppsInfo(count: count)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        @Bindable var bManager = manager
                        PrimaryButton(
                            title: count == 0 ? "Choisir des apps" : "Modifier la sélection"
                        ) {
                            Task {
                                if manager.authorizationStatus != .authorized {
                                    await manager.requestAuthorization()
                                }
                                showingPicker = true
                            }
                        }
                        .familyActivityPicker(
                            isPresented: $showingPicker,
                            selection: $bManager.activitySelection
                        )
                        .onChange(of: manager.activitySelection) { _, _ in
                            manager.applyBlocking()
                        }

                        if count > 0 {
                            Button(role: .destructive) {
                                manager.clearBlocking()
                            } label: {
                                Text("Tout désactiver")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(Theme.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Theme.red.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .navigationTitle("Apps")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct BlockingStatusCard: View {
    @Environment(BlockedAppsManager.self) private var manager

    var count: Int { manager.activitySelection.applicationTokens.count }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(count > 0 ? Theme.green.opacity(0.2) : Theme.textDim.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: count > 0 ? "shield.checkered" : "shield.slash")
                    .font(.system(size: 22))
                    .foregroundStyle(count > 0 ? Theme.green : Theme.textDim)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(count > 0 ? "Protection active" : "Aucune protection")
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.text)
                Text(count > 0
                     ? "\(count) app\(count > 1 ? "s" : "") bloquée\(count > 1 ? "s" : "")"
                     : "Ajoute des apps pour commencer")
                    .font(.system(size: 13)).foregroundStyle(Theme.textDim)
            }
            Spacer()
        }
        .padding(16).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct EmptySelectionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "apps.iphone").font(.system(size: 44)).foregroundStyle(Theme.accent)
            VStack(spacing: 8) {
                Text("Aucune app bloquée")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(Theme.text)
                Text("Sélectionne les apps pour créer une pause intentionnelle à chaque ouverture.")
                    .font(.system(size: 14)).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center).padding(.horizontal, 16)
            }
        }
        .padding(24).frame(maxWidth: .infinity)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct SelectedAppsInfo: View {
    let count: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill").foregroundStyle(Theme.green)
                Text("\(count) app\(count > 1 ? "s" : "") sélectionnée\(count > 1 ? "s" : "")")
                    .font(.system(size: 15, weight: .medium)).foregroundStyle(Theme.text)
                Spacer()
            }
            Text("Chaque tentative d'ouverture déclenchera l'écran de pause. Modifie via le bouton ci-dessous.")
                .font(.system(size: 13)).foregroundStyle(Theme.textDim)
        }
        .padding(16).background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}
