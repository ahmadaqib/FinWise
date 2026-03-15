import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.example.finwisePersonal"

private enum HandPalette {
  static let paper = Color(hex: 0xFDFBF7)
  static let ink = Color(hex: 0x2D2D2D)
  static let muted = Color(hex: 0xE5E0D8)
  static let accent = Color(hex: 0xFF4D4D)
  static let blue = Color(hex: 0x2D5DA1)
  static let paleBlue = Color(hex: 0xDCE8F8)
  static let paleYellow = Color(hex: 0xFFF3B0)
  static let paleRed = Color(hex: 0xFFD9D9)
}

private enum HandFonts {
  static func heading(_ size: CGFloat) -> Font {
    .custom("MarkerFelt-Wide", size: size)
  }

  static func body(_ size: CGFloat) -> Font {
    .custom("Noteworthy", size: size)
  }

  static func bodyBold(_ size: CGFloat) -> Font {
    .custom("Noteworthy-Bold", size: size)
  }
}

private struct WidgetStore {
  private static let defaults = UserDefaults(suiteName: widgetGroupId)

  static func string(_ key: String, fallback: String) -> String {
    defaults?.string(forKey: key) ?? fallback
  }

  static func int(_ key: String, fallback: Int) -> Int {
    defaults?.integer(forKey: key) ?? fallback
  }

  static func daysRemaining(fallback: String) -> String {
    guard
      let raw = defaults?.string(forKey: "cycleEndEpoch"),
      let epochMs = Double(raw)
    else {
      return fallback
    }

    let cycleEnd = Date(timeIntervalSince1970: epochMs / 1000.0)
    let diff = cycleEnd.timeIntervalSinceNow
    if diff <= 0 {
      return "0 hari"
    }

    let days = Int(diff / 86_400)
    return "\(days) hari"
  }
}

struct BudgetEntry: TimelineEntry {
  let date: Date
  let remainingBudget: String
  let dailyLimit: String
  let daysRemaining: String
  let lastSync: String
}

struct HealthEntry: TimelineEntry {
  let date: Date
  let healthScore: Int
  let healthStatus: String
  let daysRemaining: String
  let healthTrend: String
  let lastSync: String
}

struct RunwayEntry: TimelineEntry {
  let date: Date
  let runwayDaily: String
  let runwayStatus: String
  let runwayHint: String
  let daysRemaining: String
  let lastSync: String
}

struct BudgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> BudgetEntry {
    BudgetEntry(
      date: Date(),
      remainingBudget: "Rp 2.450.000",
      dailyLimit: "Rp 140.000",
      daysRemaining: "18 hari",
      lastSync: "12:30"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (BudgetEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetEntry>) -> Void) {
    completion(Timeline(entries: [loadEntry()], policy: .after(Date().addingTimeInterval(60 * 30))))
  }

  private func loadEntry() -> BudgetEntry {
    let fallbackDays = WidgetStore.string("daysRemaining", fallback: "0 hari")
    return BudgetEntry(
      date: Date(),
      remainingBudget: WidgetStore.string("remainingBudget", fallback: "Rp 0"),
      dailyLimit: WidgetStore.string("dailyLimit", fallback: "Rp 0"),
      daysRemaining: WidgetStore.daysRemaining(fallback: fallbackDays),
      lastSync: WidgetStore.string("widgetLastSync", fallback: "--:--")
    )
  }
}

struct HealthProvider: TimelineProvider {
  func placeholder(in context: Context) -> HealthEntry {
    HealthEntry(
      date: Date(),
      healthScore: 84,
      healthStatus: "Stabil",
      daysRemaining: "18 hari",
      healthTrend: "Terkontrol",
      lastSync: "12:30"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HealthEntry>) -> Void) {
    completion(Timeline(entries: [loadEntry()], policy: .after(Date().addingTimeInterval(60 * 30))))
  }

  private func loadEntry() -> HealthEntry {
    let fallbackDays = WidgetStore.string("daysRemaining", fallback: "0 hari")
    return HealthEntry(
      date: Date(),
      healthScore: WidgetStore.int("healthScore", fallback: 0),
      healthStatus: WidgetStore.string("healthStatus", fallback: "Perlu cek"),
      daysRemaining: WidgetStore.daysRemaining(fallback: fallbackDays),
      healthTrend: WidgetStore.string("healthTrend", fallback: "Pantau"),
      lastSync: WidgetStore.string("widgetLastSync", fallback: "--:--")
    )
  }
}

struct RunwayProvider: TimelineProvider {
  func placeholder(in context: Context) -> RunwayEntry {
    RunwayEntry(
      date: Date(),
      runwayDaily: "Rp 120.000",
      runwayStatus: "WASPADA",
      runwayHint: "Patuhi limit harian sampai gajian.",
      daysRemaining: "18 hari",
      lastSync: "12:30"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (RunwayEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<RunwayEntry>) -> Void) {
    completion(Timeline(entries: [loadEntry()], policy: .after(Date().addingTimeInterval(60 * 30))))
  }

  private func loadEntry() -> RunwayEntry {
    let fallbackDays = WidgetStore.string("daysRemaining", fallback: "0 hari")
    return RunwayEntry(
      date: Date(),
      runwayDaily: WidgetStore.string("runwayDaily", fallback: "Rp 0"),
      runwayStatus: WidgetStore.string("runwayStatus", fallback: "WASPADA"),
      runwayHint: WidgetStore.string("runwayHint", fallback: "Pantau pengeluaran harian."),
      daysRemaining: WidgetStore.daysRemaining(fallback: fallbackDays),
      lastSync: WidgetStore.string("widgetLastSync", fallback: "--:--")
    )
  }
}

struct BudgetWidgetView: View {
  let entry: BudgetEntry

  var body: some View {
    SketchCard {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 8) {
          Text("CATATAN FLOW")
            .font(HandFonts.bodyBold(10))
            .foregroundColor(HandPalette.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(HandPalette.paleYellow)
            .overlay(SketchRoundedShape(tl: 12, tr: 7, br: 11, bl: 8).stroke(HandPalette.ink, lineWidth: 2))
            .clipShape(SketchRoundedShape(tl: 12, tr: 7, br: 11, bl: 8))
          Spacer()
          Text("Sync \(entry.lastSync)")
            .font(HandFonts.body(11))
            .foregroundColor(HandPalette.ink)
        }

        Text("Sisa budget bebas")
          .font(HandFonts.body(14))
          .foregroundColor(HandPalette.ink)
          .padding(.top, 10)

        Text(entry.remainingBudget)
          .font(HandFonts.heading(30))
          .foregroundColor(HandPalette.ink)
          .lineLimit(2)
          .minimumScaleFactor(0.6)

        Rectangle()
          .fill(HandPalette.ink)
          .frame(height: 1)
          .padding(.vertical, 8)

        HStack(spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Adaptive Limit (AI)")
              .font(HandFonts.body(11))
              .foregroundColor(HandPalette.ink)
            Text(entry.dailyLimit)
              .font(HandFonts.bodyBold(18))
              .foregroundColor(HandPalette.blue)
              .lineLimit(1)
              .minimumScaleFactor(0.6)
          }
          .frame(maxWidth: .infinity, alignment: .leading)

          VStack(alignment: .leading, spacing: 2) {
            Text("Menuju gajian")
              .font(HandFonts.body(11))
              .foregroundColor(HandPalette.ink)
            Text(entry.daysRemaining)
              .font(HandFonts.bodyBold(18))
              .foregroundColor(HandPalette.accent)
              .lineLimit(1)
              .minimumScaleFactor(0.6)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(HandPalette.muted)
        .overlay(SketchRoundedShape(tl: 14, tr: 8, br: 14, bl: 9).stroke(HandPalette.ink, lineWidth: 2))
        .clipShape(SketchRoundedShape(tl: 14, tr: 8, br: 14, bl: 9))
      }
    }
    .finWiseWidgetBackground(HandPalette.paper)
  }
}

struct HealthWidgetView: View {
  let entry: HealthEntry

  var body: some View {
    SketchCard {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 8) {
          Text("FINANCIAL PULSE")
            .font(HandFonts.bodyBold(10))
            .foregroundColor(HandPalette.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(HandPalette.paleYellow)
            .overlay(SketchRoundedShape(tl: 12, tr: 7, br: 11, bl: 8).stroke(HandPalette.ink, lineWidth: 2))
            .clipShape(SketchRoundedShape(tl: 12, tr: 7, br: 11, bl: 8))
          Spacer()
          Text("Sync \(entry.lastSync)")
            .font(HandFonts.body(11))
            .foregroundColor(HandPalette.ink)
        }

        HStack(spacing: 8) {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
              Text("\(entry.healthScore)")
                .font(HandFonts.heading(34))
                .foregroundColor(HandPalette.ink)
                .lineLimit(1)
              Text("/100")
                .font(HandFonts.body(12))
                .foregroundColor(HandPalette.ink)
            }
            Text(entry.healthStatus.uppercased())
              .font(HandFonts.bodyBold(19))
              .foregroundColor(statusColor(entry.healthStatus))
          }
          Spacer()
          VStack(alignment: .leading, spacing: 2) {
            Text("Sisa hari")
              .font(HandFonts.body(11))
              .foregroundColor(HandPalette.ink)
            Text(entry.daysRemaining)
              .font(HandFonts.bodyBold(17))
              .foregroundColor(HandPalette.accent)
          }
        }
        .padding(10)
        .background(HandPalette.paleBlue)
        .overlay(SketchRoundedShape(tl: 15, tr: 8, br: 17, bl: 9).stroke(HandPalette.ink, lineWidth: 2))
        .clipShape(SketchRoundedShape(tl: 15, tr: 8, br: 17, bl: 9))
        .padding(.top, 10)

        Text("Ritme: \(entry.healthTrend)")
          .font(HandFonts.bodyBold(17))
          .foregroundColor(HandPalette.blue)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
          .padding(10)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(HandPalette.paleYellow)
          .overlay(SketchRoundedShape(tl: 13, tr: 16, br: 9, bl: 11).stroke(HandPalette.ink, lineWidth: 2))
          .clipShape(SketchRoundedShape(tl: 13, tr: 16, br: 9, bl: 11))
          .padding(.top, 8)
      }
    }
    .finWiseWidgetBackground(HandPalette.paper)
  }

  private func statusColor(_ status: String) -> Color {
    switch status.uppercased() {
    case "AMAN", "STABIL":
      return HandPalette.blue
    case "WASPADA":
      return Color(hex: 0xB07200)
    default:
      return HandPalette.accent
    }
  }
}

struct RunwayWidgetView: View {
  let entry: RunwayEntry

  var body: some View {
    SketchCard {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 8) {
          Text("RUNWAY GAJIAN")
            .font(HandFonts.bodyBold(10))
            .foregroundColor(HandPalette.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(HandPalette.paleYellow)
            .overlay(SketchRoundedShape(tl: 12, tr: 7, br: 11, bl: 8).stroke(HandPalette.ink, lineWidth: 2))
            .clipShape(SketchRoundedShape(tl: 12, tr: 7, br: 11, bl: 8))
          Spacer()
          Text("Sync \(entry.lastSync)")
            .font(HandFonts.body(11))
            .foregroundColor(HandPalette.ink)
        }

        Text("Rata-rata sisa/hari")
          .font(HandFonts.body(14))
          .foregroundColor(HandPalette.ink)
          .padding(.top, 10)

        Text(entry.runwayDaily)
          .font(HandFonts.heading(30))
          .foregroundColor(HandPalette.blue)
          .lineLimit(1)
          .minimumScaleFactor(0.65)

        HStack(spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Sisa hari")
              .font(HandFonts.body(11))
              .foregroundColor(HandPalette.ink)
            Text(entry.daysRemaining)
              .font(HandFonts.bodyBold(18))
              .foregroundColor(HandPalette.accent)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
          .background(HandPalette.muted)
          .overlay(SketchRoundedShape(tl: 12, tr: 8, br: 13, bl: 9).stroke(HandPalette.ink, lineWidth: 2))
          .clipShape(SketchRoundedShape(tl: 12, tr: 8, br: 13, bl: 9))

          VStack(alignment: .leading, spacing: 2) {
            Text("Status")
              .font(HandFonts.body(11))
              .foregroundColor(HandPalette.ink)
            Text(entry.runwayStatus.uppercased())
              .font(HandFonts.bodyBold(18))
              .foregroundColor(statusTextColor(entry.runwayStatus))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(10)
          .background(statusPanelColor(entry.runwayStatus))
          .overlay(SketchRoundedShape(tl: 10, tr: 14, br: 9, bl: 15).stroke(HandPalette.ink, lineWidth: 2))
          .clipShape(SketchRoundedShape(tl: 10, tr: 14, br: 9, bl: 15))
        }
        .padding(.top, 8)

        Text(entry.runwayHint)
          .font(HandFonts.body(13))
          .foregroundColor(HandPalette.ink)
          .lineLimit(2)
          .minimumScaleFactor(0.7)
          .padding(10)
          .frame(maxWidth: .infinity, alignment: .leading)
          .overlay(
            SketchRoundedShape(tl: 12, tr: 8, br: 14, bl: 7)
              .stroke(HandPalette.ink, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
          )
          .clipShape(SketchRoundedShape(tl: 12, tr: 8, br: 14, bl: 7))
          .padding(.top, 8)
      }
    }
    .finWiseWidgetBackground(HandPalette.paper)
  }

  private func statusPanelColor(_ status: String) -> Color {
    switch status.uppercased() {
    case "AMAN":
      return HandPalette.paleBlue
    case "KRITIS":
      return HandPalette.paleRed
    default:
      return HandPalette.paleYellow
    }
  }

  private func statusTextColor(_ status: String) -> Color {
    switch status.uppercased() {
    case "AMAN":
      return HandPalette.blue
    case "KRITIS":
      return Color(hex: 0xB32020)
    default:
      return Color(hex: 0x7A5A00)
    }
  }
}

struct DashboardWidget: Widget {
  let kind = "DashboardWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BudgetProvider()) { entry in
      BudgetWidgetView(entry: entry)
    }
    .configurationDisplayName("Budget Bebas")
    .description("Sisa budget bebas dan limit aman harian.")
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
    .description("Skor kesehatan keuangan dan ritme spending.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct RunwayWidget: Widget {
  let kind = "RunwayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: RunwayProvider()) { entry in
      RunwayWidgetView(entry: entry)
    }
    .configurationDisplayName("Runway Gajian")
    .description("Aman per hari sampai tanggal gajian.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct FinWiseWidgetsBundle: WidgetBundle {
  var body: some Widget {
    DashboardWidget()
    HealthSnapshotWidget()
    RunwayWidget()
  }
}

private struct SketchCard<Content: View>: View {
  @ViewBuilder var content: Content

  var body: some View {
    ZStack {
      SketchRoundedShape(tl: 20, tr: 8, br: 18, bl: 12)
        .fill(HandPalette.ink)
        .offset(x: 4, y: 4)

      SketchRoundedShape(tl: 20, tr: 8, br: 18, bl: 12)
        .fill(HandPalette.paper)
        .overlay(SketchRoundedShape(tl: 20, tr: 8, br: 18, bl: 12).stroke(HandPalette.ink, lineWidth: 3))

      content
        .padding(14)
    }
    .padding(2)
  }
}

private struct SketchRoundedShape: Shape {
  let tl: CGFloat
  let tr: CGFloat
  let br: CGFloat
  let bl: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let tl = min(tl, min(rect.width, rect.height) / 2)
    let tr = min(tr, min(rect.width, rect.height) / 2)
    let br = min(br, min(rect.width, rect.height) / 2)
    let bl = min(bl, min(rect.width, rect.height) / 2)

    path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX, y: rect.minY + tr),
      control: CGPoint(x: rect.maxX, y: rect.minY)
    )
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX - br, y: rect.maxY),
      control: CGPoint(x: rect.maxX, y: rect.maxY)
    )
    path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX, y: rect.maxY - bl),
      control: CGPoint(x: rect.minX, y: rect.maxY)
    )
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + tl, y: rect.minY),
      control: CGPoint(x: rect.minX, y: rect.minY)
    )
    path.closeSubpath()
    return path
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
