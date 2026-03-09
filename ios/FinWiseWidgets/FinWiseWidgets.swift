import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.example.finwisePersonal"

struct BudgetEntry: TimelineEntry {
  let date: Date
  let remainingBudget: String
  let dailyLimit: String
}

struct HealthEntry: TimelineEntry {
  let date: Date
  let healthScore: Int
  let healthStatus: String
  let daysRemaining: String
  let healthTrend: String
}

struct BudgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> BudgetEntry {
    BudgetEntry(date: Date(), remainingBudget: "Rp 2.450.000", dailyLimit: "Rp 120.000")
  }

  func getSnapshot(in context: Context, completion: @escaping (BudgetEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetEntry>) -> Void) {
    let entry = loadEntry()
    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 30))))
  }

  private func loadEntry() -> BudgetEntry {
    let defaults = UserDefaults(suiteName: widgetGroupId)
    return BudgetEntry(
      date: Date(),
      remainingBudget: defaults?.string(forKey: "remainingBudget") ?? "Rp 0",
      dailyLimit: defaults?.string(forKey: "dailyLimit") ?? "Rp 0"
    )
  }
}

struct HealthProvider: TimelineProvider {
  func placeholder(in context: Context) -> HealthEntry {
      HealthEntry(
      date: Date(),
      healthScore: 100,
      healthStatus: "Aman",
      daysRemaining: "21 hari",
      healthTrend: "Efisien"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HealthEntry>) -> Void) {
    let entry = loadEntry()
    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 30))))
  }

  private func loadEntry() -> HealthEntry {
    let defaults = UserDefaults(suiteName: widgetGroupId)
    return HealthEntry(
      date: Date(),
      healthScore: defaults?.integer(forKey: "healthScore") ?? 0,
      healthStatus: defaults?.string(forKey: "healthStatus") ?? "Perlu cek",
      daysRemaining: defaults?.string(forKey: "daysRemaining") ?? "0 hari",
      healthTrend: defaults?.string(forKey: "healthTrend") ?? "Pantau"
    )
  }
}

struct BudgetWidgetView: View {
  let entry: BudgetEntry

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topTrailing) {
        Color.white

        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(Color(hex: 0xDBEAFE))
          .frame(width: 72, height: 72)
          .offset(x: 8, y: -8)

        VStack(alignment: .leading, spacing: 0) {
          Text("BULAN INI")
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .kerning(1.2)
            .foregroundColor(Color(hex: 0x111827))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: 0xF3F4F6))
            .clipShape(Capsule())

          Spacer(minLength: 14)

          Text("Sisa budget bebas")
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(Color(hex: 0x6B7280))

          Text(entry.remainingBudget)
            .font(.system(size: valueFontSize(for: geometry.size.width), weight: .black, design: .rounded))
            .foregroundColor(Color(hex: 0x111827))
            .lineLimit(2)
            .minimumScaleFactor(0.65)
            .padding(.top, 4)

          Spacer(minLength: 12)

          HStack(spacing: 8) {
            Text("Limit harian")
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundColor(Color(hex: 0x6B7280))

            Spacer(minLength: 6)

            Text(entry.dailyLimit)
              .font(.system(size: 16, weight: .black, design: .rounded))
              .foregroundColor(Color(hex: 0x3B82F6))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .frame(maxWidth: .infinity)
          .background(Color(hex: 0xF3F4F6))
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(16)
      }
      .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
      .finWiseWidgetBackground(Color.white)
    }
  }

  private func valueFontSize(for width: CGFloat) -> CGFloat {
    width < 150 ? 22 : 24
  }
}

struct HealthWidgetView: View {
  let entry: HealthEntry

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Color(hex: 0x3B82F6)

      RoundedRectangle(cornerRadius: 34, style: .continuous)
        .fill(Color(hex: 0x34D399))
        .frame(width: 92, height: 92)
        .offset(x: 10, y: 10)

      VStack(alignment: .leading, spacing: 0) {
        Text("FINANCIAL PULSE")
          .font(.system(size: 10, weight: .semibold, design: .rounded))
          .kerning(1.2)
          .foregroundColor(.white)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(Color(hex: 0x111827))
          .clipShape(Capsule())

        Spacer(minLength: 18)

        HStack(alignment: .lastTextBaseline, spacing: 6) {
          Text("\(entry.healthScore)")
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)

          Text("/100")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(Color(hex: 0xDBEAFE))
        }

        Text(entry.healthStatus)
          .font(.system(size: 18, weight: .black, design: .rounded))
          .foregroundColor(.white)
          .padding(.top, 4)

        Spacer(minLength: 12)

        HStack(spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Sisa hari")
              .font(.system(size: 10, weight: .medium, design: .rounded))
              .foregroundColor(Color(hex: 0x6B7280))
            Text(entry.daysRemaining)
              .font(.system(size: 16, weight: .black, design: .rounded))
              .foregroundColor(Color(hex: 0x111827))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

          VStack(alignment: .leading, spacing: 2) {
            Text("Ritme")
              .font(.system(size: 10, weight: .medium, design: .rounded))
              .foregroundColor(Color(hex: 0x78350F))
            Text(entry.healthTrend)
              .font(.system(size: 16, weight: .black, design: .rounded))
              .foregroundColor(Color(hex: 0x78350F))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
          .background(Color(hex: 0xF59E0B))
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
      }
      .padding(16)
    }
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .finWiseWidgetBackground(Color(hex: 0x3B82F6))
  }
}

struct DashboardWidget: Widget {
  let kind = "DashboardWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BudgetProvider()) { entry in
      BudgetWidgetView(entry: entry)
    }
    .configurationDisplayName("Budget Bebas")
    .description("Pantau sisa budget dan limit harian.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct HealthSnapshotWidget: Widget {
  let kind = "HealthSnapshotWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HealthProvider()) { entry in
      HealthWidgetView(entry: entry)
    }
    .configurationDisplayName("Financial Pulse")
    .description("Lihat skor kesehatan finansial bulan ini.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct FinWiseWidgetsBundle: WidgetBundle {
  var body: some Widget {
    DashboardWidget()
    HealthSnapshotWidget()
  }
}

private extension View {
  @ViewBuilder
  func finWiseWidgetBackground(_ color: Color) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(color, for: .widget)
    } else {
      background(color)
    }
  }
}

private extension Color {
  init(hex: UInt32) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}
