import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \InterventionEvent.timestamp, order: .reverse) private var events: [InterventionEvent]
    @AppStorage("estimated_session_minutes") private var estimatedMinutes: Double = 20.0

    private var resistedCount: Int   { events.filter(\.resisted).count }
    private var openedCount: Int     { events.filter { !$0.resisted }.count }
    private var resistanceRate: Double {
        events.isEmpty ? 0 : Double(resistedCount) / Double(events.count) * 100
    }
    private var timeSaved: Double    { Double(resistedCount) * estimatedMinutes }

    private var last7Days: [DayBucket] {
        let cal = Calendar.current
        return (0..<7).reversed().map { offset in
            let date  = cal.date(byAdding: .day, value: -offset, to: Date())!
            let start = cal.startOfDay(for: date)
            let end   = cal.date(byAdding: .day, value: 1, to: start)!
            let day   = events.filter { $0.timestamp >= start && $0.timestamp < end }
            return DayBucket(date: date,
                             resisted: day.filter(\.resisted).count,
                             opened:   day.filter { !$0.resisted }.count)
        }
    }

    private var perAppStats: [AppStat] {
        var dict: [String: (r: Int, t: Int)] = [:]
        for e in events {
            var s = dict[e.appName] ?? (0, 0)
            s.t += 1
            if e.resisted { s.r += 1 }
            dict[e.appName] = s
        }
        return dict.map { AppStat(name: $0.key, resisted: $0.value.r, total: $0.value.t) }
                   .sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if events.isEmpty {
                    EmptyDashboardView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stat cards
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                StatCard(title: "Interventions", value: "\(events.count)",
                                         icon: "hand.raised.fill",  color: Theme.accent)
                                StatCard(title: "Résistance",    value: "\(Int(resistanceRate))%",
                                         icon: "shield.fill",       color: Theme.green)
                                StatCard(title: "Ouvertes",       value: "\(openedCount)",
                                         icon: "arrow.right.circle.fill", color: Theme.red)
                                StatCard(title: "Temps économ.", value: formatTime(timeSaved),
                                         icon: "clock.fill",       color: Theme.amber)
                            }

                            // 7-day chart
                            VStack(alignment: .leading, spacing: 14) {
                                Text("7 derniers jours")
                                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.text)

                                Chart(last7Days) { bucket in
                                    BarMark(
                                        x: .value("Jour",      bucket.date, unit: .day),
                                        y: .value("Résistées", bucket.resisted)
                                    )
                                    .foregroundStyle(Theme.accent)
                                    .cornerRadius(4)

                                    BarMark(
                                        x: .value("Jour",    bucket.date, unit: .day),
                                        y: .value("Ouvertes", bucket.opened)
                                    )
                                    .foregroundStyle(Theme.red.opacity(0.6))
                                    .cornerRadius(4)
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { _ in
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                            .foregroundStyle(Theme.textDim)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel().foregroundStyle(Theme.textDim)
                                        AxisGridLine().foregroundStyle(Theme.border)
                                    }
                                }
                                .frame(height: 180)

                                HStack(spacing: 16) {
                                    LegendDot(color: Theme.accent,           label: "Résistées")
                                    LegendDot(color: Theme.red.opacity(0.6), label: "Ouvertes")
                                }
                            }
                            .padding(20).background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                            // Per-app breakdown
                            if !perAppStats.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Par application")
                                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.text)
                                    ForEach(perAppStats) { stat in
                                        AppStatRow(stat: stat)
                                    }
                                }
                                .padding(20).background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func formatTime(_ minutes: Double) -> String {
        let m = Int(minutes)
        guard m >= 60 else { return "\(m)min" }
        let h = m / 60; let rem = m % 60
        return rem == 0 ? "\(h)h" : "\(h)h\(rem)"
    }
}

// MARK: - Models

struct DayBucket: Identifiable {
    let id   = UUID()
    let date: Date
    let resisted: Int
    let opened:   Int
}

struct AppStat: Identifiable {
    let id = UUID()
    let name: String
    let resisted: Int
    let total: Int
    var rate: Double { total > 0 ? Double(resisted) / Double(total) : 0 }
}

// MARK: - Sub-views

struct StatCard: View {
    let title: String
    let value: String
    let icon:  String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(color)
            Text(value).font(.system(size: 28, weight: .semibold)).foregroundStyle(Theme.text)
            Text(title).font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.textDim)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct AppStatRow: View {
    let stat: AppStat
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(stat.name).font(.system(size: 15, weight: .medium)).foregroundStyle(Theme.text)
                Spacer()
                Text("\(stat.resisted)/\(stat.total)")
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.textDim)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Theme.border).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Theme.accent)
                        .frame(width: geo.size.width * stat.rate, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

struct LegendDot: View {
    let color: Color; let label: String
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 12)).foregroundStyle(Theme.textDim)
        }
    }
}

struct EmptyDashboardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis").font(.system(size: 56)).foregroundStyle(Theme.accent)
            VStack(spacing: 8) {
                Text("Pas encore de données")
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(Theme.text)
                Text("Configure une app et teste le lien Raccourcis pour voir tes stats.")
                    .font(.system(size: 15)).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
            }
        }
    }
}
