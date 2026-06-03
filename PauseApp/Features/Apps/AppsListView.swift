import SwiftUI
import SwiftData

struct AppsListView: View {
    @Query(sort: \TrackedApp.createdAt) private var apps: [TrackedApp]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    @State private var appToEdit: TrackedApp?
    @State private var appForShortcuts: TrackedApp?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if apps.isEmpty {
                    EmptyAppsView { showingAdd = true }
                } else {
                    List {
                        ForEach(apps) { app in
                            AppRow(app: app)
                                .listRowBackground(Theme.surface)
                                .listRowSeparatorTint(Theme.border)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        modelContext.delete(app)
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button { appForShortcuts = app } label: {
                                        Label("Raccourcis", systemImage: "arrow.triangle.branch")
                                    }
                                    .tint(Theme.accent)
                                }
                                .onTapGesture { appToEdit = app }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Apps")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus").foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAdd)  { AddEditAppView() }
            .sheet(item: $appToEdit)          { AddEditAppView(app: $0) }
            .sheet(item: $appForShortcuts)    { ShortcutsGuideView(app: $0) }
        }
    }
}

struct AppRow: View {
    let app: TrackedApp
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(app.accentColor.opacity(0.2))
                    .frame(width: 46, height: 46)
                Image(systemName: app.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundStyle(app.accentColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text(app.urlScheme)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textDim)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textDim)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyAppsView: View {
    let onAdd: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "apps.iphone.badge.plus")
                .font(.system(size: 56)).foregroundStyle(Theme.accent)
            VStack(spacing: 8) {
                Text("Aucune app configurée")
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(Theme.text)
                Text("Ajoute une app pour créer tes premières pauses intentionnelles.")
                    .font(.system(size: 15)).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }
            PrimaryButton(title: "Ajouter une app", action: onAdd)
                .padding(.horizontal, 48)
        }
    }
}
