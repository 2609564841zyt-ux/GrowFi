import SwiftUI

@main
struct GrowFiApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case home
    case accounting
    case finance
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "首页"
        case .accounting: "记账"
        case .finance: "理财"
        case .profile: "我的"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .accounting: "calendar"
        case .finance: "chart.line.uptrend.xyaxis"
        case .profile: "person"
        }
    }
}

private enum AccountingMode: String, CaseIterable, Identifiable {
    case calendar
    case pocket

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calendar: "📅 日历记账"
        case .pocket: "🐷 小荷包"
        }
    }
}

private enum GF {
    static let background = Color(hex: 0xF5F5F0)
    static let warmTop = Color(hex: 0xFFF8F4)
    static let orange = Color(hex: 0xFF8A5B)
    static let gold = Color(hex: 0xFFC371)
    static let ink = Color(hex: 0x191C1E)
    static let muted = Color(hex: 0x9CA3AF)
    static let softText = Color(hex: 0x56423B)
    static let red = Color(hex: 0xDC2626)
    static let green = Color(hex: 0x16A34A)
    static let line = Color(hex: 0xEDEEF0)
    static let purple = Color(hex: 0x8B7CF6)
    static let mint = Color(hex: 0x6EDC8C)

    static let orangeGradient = LinearGradient(
        colors: [orange, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pageGradient = LinearGradient(
        colors: [warmTop, background],
        startPoint: .top,
        endPoint: .bottom
    )
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

private extension View {
    func card(radius: CGFloat = 24, shadowOpacity: Double = 0.06) -> some View {
        background(.white, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(shadowOpacity), radius: 10, x: 0, y: 8)
    }

    func softCard(radius: CGFloat = 16) -> some View {
        background(GF.background, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    func metricFont(size: CGFloat, weight: Font.Weight = .bold) -> some View {
        font(.system(size: size, weight: weight, design: .rounded))
            .monospacedDigit()
    }
}

private struct RootTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            AccountingView()
                .tabItem { Label(AppTab.accounting.title, systemImage: AppTab.accounting.icon) }
                .tag(AppTab.accounting)

            FinanceMarketView()
                .tabItem { Label(AppTab.finance.title, systemImage: AppTab.finance.icon) }
                .tag(AppTab.finance)

            ProfileView()
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.icon) }
                .tag(AppTab.profile)
        }
        .tint(GF.orange)
    }
}

private struct PageContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 96)
        }
        .background(GF.pageGradient.ignoresSafeArea())
    }
}

private struct HomeView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        PageContainer {
            VStack(spacing: 16) {
                header
                balance
                plantHero
                levelBadge
                healthAndTip
                quickActions
                savingsGoals
                WeeklySpendingCard()
                GrowthCard()
            }
        }
        .accessibilityLabel("GrowFi 首页")
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("GrowFi")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(GF.ink)
                Text("本月资产（元）")
                    .font(.system(size: 12))
                    .foregroundStyle(GF.muted)
            }

            Spacer()

            Button {
                selectedTab = .accounting
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(GF.orange)
                    Text("浇水")
                        .font(.system(size: 12))
                        .foregroundStyle(GF.ink)
                    Text("记收支")
                        .font(.system(size: 12))
                        .foregroundStyle(GF.softText.opacity(0.75))
                }
                .frame(width: 60, height: 74)
                .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: GF.orange.opacity(0.2), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("浇水并记收支")
        }
    }

    private var balance: some View {
        HStack(alignment: .lastTextBaseline, spacing: 12) {
            Text("¥12,530")
                .metricFont(size: 32, weight: .bold)
                .foregroundStyle(GF.ink)

            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                Text("+¥1,200 (+8.6%)")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(GF.red)

            Spacer()
        }
        .padding(.top, 18)
    }

    private var plantHero: some View {
        ZStack {
            Circle()
                .fill(GF.orange.opacity(0.10))
                .frame(width: 320, height: 320)
                .blur(radius: 24)

            Bubble(text: "+¥8,200\n工资", color: GF.red)
                .offset(x: -112, y: -52)
            Bubble(text: "-¥386\n餐饮", color: GF.green, size: 56)
                .offset(x: 112, y: -28)
            Bubble(text: "+¥500\n奖金", color: GF.red, size: 56)
                .offset(x: -132, y: 82)
            Bubble(text: "+¥210\n理财", color: GF.red)
                .offset(x: 102, y: 70)

            PlantIllustration()
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 10)
        }
        .frame(height: 300)
        .accessibilityHidden(true)
    }

    private var levelBadge: some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule().fill(GF.orangeGradient).frame(width: 6, height: 16)
                }
            }
            Text("成长中 · Lv.3")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(GF.orange)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(.white.opacity(0.72), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.55), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var healthAndTip: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("财务健康度").font(.system(size: 13)).foregroundStyle(GF.muted)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("78").metricFont(size: 38)
                    Text("分").font(.system(size: 12)).foregroundStyle(GF.muted)
                }
                ProgressLine(value: 0.78, color: GF.orange)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .card(radius: 24)

            VStack(alignment: .leading, spacing: 10) {
                Label("小希建议", systemImage: "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(GF.orange)
                Text("减少餐饮支出15%，可进入开花阶段")
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .foregroundStyle(GF.softText)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(Color(hex: 0xFFF6ED), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(GF.orange.opacity(0.12), lineWidth: 1))
            .shadow(color: GF.orange.opacity(0.06), radius: 10, x: 0, y: 8)
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            QuickAction(title: "记一笔", symbol: "pencil", background: Color(hex: 0xFFDBCE)) {
                selectedTab = .accounting
            }
            QuickAction(title: "去攒钱", symbol: "piggy.bank", background: Color(hex: 0xFFDDB4)) {
                selectedTab = .accounting
            }
            QuickAction(title: "去理财", symbol: "chart.bar", background: Color(hex: 0xFDE098)) {
                selectedTab = .finance
            }
        }
    }

    private var savingsGoals: some View {
        VStack(spacing: 12) {
            SavingGoalCard(goal: .travel)
            SavingGoalCard(goal: .phone)
        }
    }
}

private struct Bubble: View {
    let text: String
    let color: Color
    var size: CGFloat = 64

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(.white.opacity(0.56), in: Circle())
            .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 8)
    }
}

private struct PlantIllustration: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(.black.opacity(0.12))
                .frame(width: 150, height: 24)
                .offset(y: 82)
                .blur(radius: 5)

            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0xFFE7B4), Color(hex: 0xD58B45)], startPoint: .top, endPoint: .bottom))
                .frame(width: 150, height: 78)
                .offset(y: 52)

            Ellipse()
                .fill(Color(hex: 0x9B5B25))
                .frame(width: 128, height: 34)
                .offset(y: 18)

            Capsule()
                .fill(Color(hex: 0x69B23B))
                .frame(width: 12, height: 112)
                .offset(y: -26)

            leaf(rotation: -38, x: -42, y: -48, width: 72, height: 42)
            leaf(rotation: 32, x: 42, y: -56, width: 72, height: 42)
            leaf(rotation: -18, x: -20, y: -96, width: 60, height: 36)
            leaf(rotation: 24, x: 28, y: -102, width: 58, height: 34)
        }
    }

    private func leaf(rotation: Double, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        Ellipse()
            .fill(LinearGradient(colors: [Color(hex: 0xD9F65C), Color(hex: 0x74C83E)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation))
            .offset(x: x, y: y)
    }
}

private struct QuickAction: View {
    let title: String
    let symbol: String
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(GF.orange)
                    .frame(width: 40, height: 40)
                    .background(background, in: Circle())
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(GF.ink)
            }
            .frame(maxWidth: .infinity, minHeight: 98)
            .card(radius: 16, shadowOpacity: 0.04)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

private struct SavingGoal: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let subtitle: String
    let value: String
    let target: String
    let percent: Double
    let color: Color

    static let travel = SavingGoal(emoji: "✈️", title: "旅游基金", subtitle: "坚持就是胜利！", value: "¥6,500", target: "¥10,000", percent: 0.65, color: GF.orange)
    static let phone = SavingGoal(emoji: "📱", title: "新款手机", subtitle: "再攒一个月！", value: "¥3,200", target: "¥5,999", percent: 0.53, color: GF.orange)
    static let emergency = SavingGoal(emoji: "🛡️", title: "应急备用", subtitle: "已坚持 120 天", value: "¥12,000", target: "¥20,000", percent: 0.60, color: GF.purple)
}

private struct SavingGoalCard: View {
    let goal: SavingGoal
    var showDeposit: Bool = false

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 12) {
                    Text(goal.emoji)
                        .font(.system(size: 20))
                        .frame(width: showDeposit ? 48 : 40, height: showDeposit ? 48 : 40)
                        .background(goal.color.opacity(0.13), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(goal.title).font(.system(size: 15, weight: .semibold))
                        Text(goal.subtitle).font(.system(size: 12)).foregroundStyle(GF.muted)
                    }
                }
                Spacer()
                if showDeposit {
                    Button("存入") {}
                        .font(.system(size: 12))
                        .foregroundStyle(goal.color)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(goal.color.opacity(0.09), in: Capsule())
                        .overlay(Capsule().stroke(goal.color.opacity(0.25), lineWidth: 1))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(GF.muted)
                }
            }

            HStack(alignment: .lastTextBaseline) {
                Text(goal.value).metricFont(size: showDeposit ? 20 : 20)
                Spacer()
                Text("/ \(goal.target) (\(Int(goal.percent * 100))%)")
                    .font(.system(size: 12))
                    .foregroundStyle(GF.muted)
            }

            ProgressLine(value: goal.percent, color: goal.color)

            if showDeposit {
                HStack(spacing: 4) {
                    Image(systemName: "target")
                    Text("还差 \(remainingText(goal)) 达到目标")
                }
                .font(.system(size: 11))
                .foregroundStyle(GF.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .card(radius: 24)
    }

    private func remainingText(_ goal: SavingGoal) -> String {
        switch goal.title {
        case "旅游基金": "¥3,500"
        case "新款手机": "¥2,799"
        default: "¥8,000"
        }
    }
}

private struct ProgressLine: View {
    let value: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(GF.line)
                Capsule()
                    .fill(LinearGradient(colors: [color, color.opacity(0.62)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: proxy.size.width * value)
            }
        }
        .frame(height: 8)
    }
}

private struct WeeklySpendingCard: View {
    private let bars: [(CGFloat, CGFloat)] = [(32, 12), (50, 22), (28, 18), (42, 24), (66, 14), (40, 24), (58, 20)]
    private let labels = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("本周收支").font(.system(size: 15, weight: .semibold))
                Spacer()
                HStack(spacing: 12) {
                    Legend(color: GF.red, text: "收入")
                    Legend(color: GF.green, text: "支出")
                }
            }
            HStack(alignment: .bottom, spacing: 15) {
                ForEach(Array(bars.enumerated()), id: \.offset) { index, pair in
                    VStack(spacing: 5) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Capsule().fill(GF.red).frame(width: 5, height: pair.0)
                            Capsule().fill(GF.green).frame(width: 5, height: pair.1)
                        }
                        Text(labels[index]).font(.system(size: 9)).foregroundStyle(GF.muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 88, alignment: .bottom)
        }
        .padding(20)
        .card(radius: 24)
    }
}

private struct Legend: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(.system(size: 10)).foregroundStyle(GF.muted)
        }
    }
}

private struct GrowthCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("🌱")
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 4) {
                    Text("距离开花还差 22 分")
                        .font(.system(size: 14, weight: .semibold))
                    Text("坚持记账21天 +5分 · 完成储蓄目标 +10分 · 理财入门课程 +7分")
                        .font(.system(size: 12))
                        .lineSpacing(3)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            HStack {
                ForEach(["种子", "发芽", "成长", "开花", "结果"], id: \.self) { stage in
                    VStack(spacing: 4) {
                        Circle().fill(stage == "开花" || stage == "结果" ? .white.opacity(0.3) : .white).frame(width: 8, height: 8)
                        Text(stage).font(.system(size: 9))
                    }
                    .foregroundStyle((stage == "开花" || stage == "结果") ? .white.opacity(0.55) : .white)
                }
                Spacer()
                Button("立即升级") {}
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.24), in: Capsule())
            }
        }
        .padding(20)
        .foregroundStyle(.white)
        .background(GF.orangeGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct AccountingView: View {
    @State private var mode: AccountingMode = .calendar

    var body: some View {
        PageContainer {
            VStack(spacing: 16) {
                PageTitle(title: "记账", subtitle: "追踪每一笔收支，养成好习惯")
                AccountingSegment(mode: $mode)

                if mode == .calendar {
                    CalendarAccountingContent()
                } else {
                    PocketContent()
                }
            }
        }
        .accessibilityLabel("记账")
    }
}

private struct PageTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(GF.ink)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(GF.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AccountingSegment: View {
    @Binding var mode: AccountingMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AccountingMode.allCases) { item in
                Button {
                    mode = item
                } label: {
                    Text(item.title)
                        .font(.system(size: 13, weight: mode == item ? .bold : .regular))
                        .foregroundStyle(mode == item ? .white : GF.muted)
                        .frame(maxWidth: .infinity, minHeight: 39)
                        .background {
                            if mode == item {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(GF.orangeGradient)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .frame(height: 47)
        .card(radius: 16)
    }
}

private struct CalendarAccountingContent: View {
    var body: some View {
        VStack(spacing: 16) {
            monthSummary
            CalendarGrid()
            RecentRecordsCard()
        }
    }

    private var monthSummary: some View {
        HStack {
            HStack(spacing: 8) {
                CircleButton(symbol: "chevron.left")
                Text("2026年 5月")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                CircleButton(symbol: "chevron.right")
            }
            Spacer()
            HStack(spacing: 16) {
                Label("¥9,710", systemImage: "arrow.up.right")
                    .foregroundStyle(GF.red)
                Label("¥762", systemImage: "arrow.down.right")
                    .foregroundStyle(GF.green)
            }
            .font(.system(size: 13, weight: .bold))
        }
        .padding(20)
        .card(radius: 24)
    }
}

private struct CircleButton: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(GF.muted)
            .frame(width: 24, height: 24)
            .background(GF.background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct CalendarGrid: View {
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    private let days = Array(1...31)
    private let markedIncome: Set<Int> = [3, 5, 12, 20, 22, 28]
    private let markedExpense: Set<Int> = [1, 8, 15, 25]

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11))
                        .foregroundStyle(GF.muted)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 12) {
                ForEach(0..<5, id: \.self) { _ in Color.clear.frame(height: 37) }
                ForEach(days, id: \.self) { day in
                    VStack(spacing: 3) {
                        Text("\(day)")
                            .font(.system(size: 13, weight: day == 5 ? .bold : .regular, design: .rounded))
                            .foregroundStyle(day == 5 ? GF.orange : GF.ink)
                        Circle()
                            .fill(dotColor(day))
                            .frame(width: dotColor(day) == .clear ? 0 : 4, height: dotColor(day) == .clear ? 0 : 4)
                    }
                    .frame(height: 37)
                    .frame(maxWidth: .infinity)
                    .background(day == 5 ? Color(hex: 0xFFF6ED) : .clear, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(24)
        .card(radius: 24)
    }

    private func dotColor(_ day: Int) -> Color {
        if markedExpense.contains(day) { return GF.red }
        if markedIncome.contains(day) { return GF.green }
        return .clear
    }
}

private struct RecentRecordsCard: View {
    private let records = [
        Record(emoji: "💸", title: "医疗", subtitle: "5月28日 · 药品", amount: "-¥30", color: GF.green),
        Record(emoji: "💰", title: "副业", subtitle: "5月25日 · 设计稿酬", amount: "+¥800", color: GF.red),
        Record(emoji: "💸", title: "学习", subtitle: "5月22日 · 线上课程", amount: "-¥199", color: GF.green),
        Record(emoji: "💸", title: "娱乐", subtitle: "5月20日 · 电影票", amount: "-¥68", color: GF.green),
        Record(emoji: "💸", title: "咖啡", subtitle: "5月17日 · 星巴克", amount: "-¥38", color: GF.green),
        Record(emoji: "💰", title: "理财", subtitle: "5月15日 · 基金收益", amount: "+¥210", color: GF.red)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("最近记录")
                .font(.system(size: 16, weight: .bold))
            ForEach(records) { record in
                HStack(spacing: 12) {
                    Text(record.emoji)
                        .font(.system(size: 16))
                        .frame(width: 36, height: 36)
                        .background(record.color.opacity(0.09), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.title).font(.system(size: 14))
                        Text(record.subtitle).font(.system(size: 12)).foregroundStyle(GF.muted)
                    }
                    Spacer()
                    Text(record.amount)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(record.color)
                }
            }
        }
        .padding(20)
        .card(radius: 24)
    }
}

private struct Record: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let subtitle: String
    let amount: String
    let color: Color
}

private struct PocketContent: View {
    var body: some View {
        VStack(spacing: 16) {
            pocketHero
            SavingGoalCard(goal: .travel, showDeposit: true)
            SavingGoalCard(goal: .phone, showDeposit: true)
            SavingGoalCard(goal: .emergency, showDeposit: true)
            newPlanButton
            autoSavingCard
        }
    }

    private var pocketHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "piggy.bank.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 22))
                VStack(alignment: .leading, spacing: 4) {
                    Text("我的小荷包")
                        .font(.system(size: 16, weight: .bold))
                    Text("定期攒钱，开花结果")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总攒款").font(.system(size: 11)).foregroundStyle(.white.opacity(0.75))
                    Text("¥21,700").metricFont(size: 20)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("目标总额").font(.system(size: 11)).foregroundStyle(.white.opacity(0.75))
                    Text("¥35,999").metricFont(size: 20)
                }
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(GF.orangeGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: GF.orange.opacity(0.30), radius: 12, x: 0, y: 10)
    }

    private var newPlanButton: some View {
        Button {} label: {
            Label("新建存钱计划", systemImage: "plus")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(GF.orange)
                .frame(maxWidth: .infinity, minHeight: 63)
                .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(GF.line, style: StrokeStyle(lineWidth: 1, dash: [2, 3])))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var autoSavingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("智能自动攒钱", systemImage: "wallet.pass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(GF.ink)
            Text("每月1日自动将设定金额转入攒钱计划，无需手动操作，轻松养成攒钱习惯🌱")
                .font(.system(size: 13))
                .lineSpacing(4)
                .foregroundStyle(GF.softText)
            Button("开启自动攒钱") {}
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(GF.orangeGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(20)
        .background(Color(hex: 0xFFF6ED), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(GF.orange.opacity(0.18), lineWidth: 1))
    }
}

private struct FinanceMarketView: View {
    @State private var selectedScope = "全部"
    @State private var selectedIndustry = "全部"
    @State private var showAISheet = false

    private let scopes = ["全部", "✨AI精选", "自选"]
    private let industries = ["全部", "化工", "医疗", "科技", "消费", "能源", "金融", "新能源"]
    private let stocks: [Stock] = [
        .init(name: "宁德时代", code: "300750 · 新能源", desc: "全球动力电池龙头", price: "¥168.50", change: "+2.56%", risk: "中风险", pe: "PE: 28.3", color: GF.red, ai: true),
        .init(name: "恒瑞医药", code: "600276 · 医疗", desc: "国内创新药龙头企业", price: "¥42.30", change: "-1.86%", risk: "中风险", pe: "PE: 35.1", color: GF.green, ai: true),
        .init(name: "万华化学", code: "600309 · 化工", desc: "全球MDI市场领导者", price: "¥78.60", change: "+1.81%", risk: "低风险", pe: "PE: 12.5", color: GF.red, ai: false),
        .init(name: "贵州茅台", code: "600519 · 消费", desc: "中国白酒龙头，高端价值标杆", price: "¥1680.00", change: "+0.75%", risk: "低风险", pe: "PE: 30.2", color: GF.red, ai: false),
        .init(name: "中芯国际", code: "688981 · 科技", desc: "国内最大芯片代工厂", price: "¥56.40", change: "+3.87%", risk: "高风险", pe: "PE: 45.6", color: GF.red, ai: true),
        .init(name: "中国平安", code: "601318 · 金融", desc: "综合金融服务龙头", price: "¥48.20", change: "-1.03%", risk: "低风险", pe: "PE: 8.4", color: GF.green, ai: false),
        .init(name: "隆基绿能", code: "601012 · 新能源", desc: "单晶硅片和组件全球领先", price: "¥23.80", change: "+3.93%", risk: "中风险", pe: "PE: 15.2", color: GF.red, ai: true),
        .init(name: "中石化", code: "600028 · 能源", desc: "国内炼化能源巨头", price: "¥6.80", change: "+1.49%", risk: "低风险", pe: "PE: 10.1", color: GF.red, ai: false),
        .init(name: "药明康德", code: "603259 · 医疗", desc: "全球领先CXO企业", price: "¥68.90", change: "-3.23%", risk: "高风险", pe: "PE: 22.8", color: GF.green, ai: false),
        .init(name: "比亚迪", code: "002594 · 新能源", desc: "新能源汽车及电池领导者", price: "¥285.00", change: "+3.07%", risk: "中风险", pe: "PE: 24.1", color: GF.red, ai: true)
    ]

    var body: some View {
        PageContainer {
            VStack(spacing: 16) {
                marketHeader
                indexCards
                ChipRow(items: scopes, selected: $selectedScope, gradientSelected: true)
                ChipRow(items: industries, selected: $selectedIndustry, darkSelected: true)
                    .padding(.trailing, -24)
                LazyVStack(spacing: 12) {
                    ForEach(stocks) { StockCard(stock: $0) }
                }
            }
        }
        .sheet(isPresented: $showAISheet) {
            AIStockPickerSheet()
                .presentationDetents([.height(681), .large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var marketHeader: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                PageTitle(title: "理财市场", subtitle: "聪明投资，从现在开始")
                Spacer()
                Button {
                    showAISheet = true
                } label: {
                    Label("AI帮选", systemImage: "brain.head.profile")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 35)
                        .background(GF.orangeGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: GF.orange.opacity(0.35), radius: 6, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("AI帮选")
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(GF.muted)
                Text("搜索股票、基金...")
                    .font(.system(size: 14))
                    .foregroundStyle(GF.ink.opacity(0.5))
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 41)
            .card(radius: 16)
        }
    }

    private var indexCards: some View {
        HStack(spacing: 12) {
            MarketIndexCard(title: "上证指数", value: "3,298.72", change: "+0.82%", color: GF.red)
            MarketIndexCard(title: "深证成指", value: "10,512.5", change: "+1.23%", color: GF.red)
            MarketIndexCard(title: "创业板指", value: "2,104.3", change: "-0.45%", color: GF.green)
        }
    }
}

private struct ChipRow: View {
    let items: [String]
    @Binding var selected: String
    var gradientSelected = false
    var darkSelected = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Button { selected = item } label: {
                        Text(item)
                            .font(.system(size: 13, weight: selected == item ? .bold : .regular))
                            .foregroundStyle(selected == item ? .white : GF.softText)
                            .padding(.horizontal, 17)
                            .frame(height: darkSelected ? 35 : 31)
                            .background {
                                RoundedRectangle(cornerRadius: darkSelected ? 16 : 999, style: .continuous)
                                    .fill(chipStyle(for: item))
                            }
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func chipStyle(for item: String) -> AnyShapeStyle {
        if selected == item && gradientSelected {
            return AnyShapeStyle(GF.orangeGradient)
        } else if selected == item && darkSelected {
            return AnyShapeStyle(GF.ink)
        } else {
            return AnyShapeStyle(Color.white)
        }
    }
}

private struct MarketIndexCard: View {
    let title: String
    let value: String
    let change: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 10)).foregroundStyle(GF.muted)
            Text(value).font(.system(size: 13, weight: .bold, design: .rounded))
            Text(change).font(.system(size: 11)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, minHeight: 77, alignment: .leading)
        .padding(.horizontal, 12)
        .card(radius: 16, shadowOpacity: 0.05)
    }
}

private struct Stock: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let desc: String
    let price: String
    let change: String
    let risk: String
    let pe: String
    let color: Color
    let ai: Bool
}

private struct StockCard: View {
    let stock: Stock
    @State private var favorite = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: stock.change.hasPrefix("-") ? "arrow.down.left" : "arrow.up.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(stock.color)
                        .frame(width: 44, height: 44)
                        .background(stock.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(stock.name).font(.system(size: 15, weight: .semibold))
                            if stock.ai {
                                Label("AI", systemImage: "sparkles")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(GF.orangeGradient, in: Capsule())
                            }
                        }
                        Text(stock.code).font(.system(size: 12)).foregroundStyle(GF.muted)
                        Text(stock.desc).font(.system(size: 11)).foregroundStyle(GF.muted)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Button { favorite.toggle() } label: {
                        Image(systemName: favorite ? "star.fill" : "star")
                            .foregroundStyle(favorite ? GF.gold : GF.muted.opacity(0.5))
                    }
                    Text(stock.price).font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(stock.change)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(stock.color)
                        .padding(.horizontal, 8)
                        .frame(height: 22)
                        .background(stock.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            HStack(spacing: 12) {
                Label(stock.pe, systemImage: "chart.bar")
                Label(stock.risk, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(stock.risk == "低风险" ? GF.green : stock.risk == "中风险" ? Color(hex: 0xF59E0B) : GF.red)
                Spacer()
            }
            .font(.system(size: 11))
            .foregroundStyle(GF.muted)
            .padding(.top, 12)
            .overlay(alignment: .top) {
                Rectangle().fill(GF.background).frame(height: 1)
            }
        }
        .padding(16)
        .card(radius: 24)
    }
}

private struct AIStockPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(GF.orangeGradient, in: RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AI 智能选股").font(.system(size: 17, weight: .bold))
                            Text("基于大数据分析为你定制").font(.system(size: 12)).foregroundStyle(GF.muted)
                        }
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17))
                            .foregroundStyle(GF.muted)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("你的风险偏好：稳健型")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(GF.orange)
                    Text("建议配置：70%稳健 + 20%成长 + 10%激进")
                        .font(.system(size: 12))
                        .foregroundStyle(GF.softText)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: 0xFFF6ED), in: RoundedRectangle(cornerRadius: 16))

                SheetSection(title: "🔥 市场热点分析") {
                    HotspotRow(emoji: "⚗️", title: "化工板块景气度上升", detail: "近期化工品价格回暖，万华化学等龙头值得关注")
                    HotspotRow(emoji: "💊", title: "医疗创新药利好政策", detail: "医保谈判利好创新药企业，恒瑞、药明等有望受益")
                    HotspotRow(emoji: "⚡", title: "新能源估值修复", detail: "光储需求持续增长，宁德、比亚迪等配置价值凸显")
                }

                SheetSection(title: "✨ AI 精选推荐") {
                    RecommendationRow(name: "宁德时代", industry: "新能源", change: "+2.56%", color: GF.red)
                    RecommendationRow(name: "恒瑞医药", industry: "医疗", change: "-1.86%", color: GF.green)
                    RecommendationRow(name: "中芯国际", industry: "科技", change: "+3.87%", color: GF.red)
                    RecommendationRow(name: "隆基绿能", industry: "新能源", change: "+3.93%", color: GF.red)
                }

                Text("⚠️ AI分析仅供参考，不构成投资建议。投资有风险，入市需谨慎。")
                    .font(.system(size: 11))
                    .foregroundStyle(GF.muted)
                    .lineSpacing(3)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0xFFF6ED), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(GF.orange.opacity(0.2), lineWidth: 1))
            }
            .padding(24)
        }
        .background(.white)
    }
}

private struct SheetSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 14, weight: .semibold))
            VStack(spacing: 12) { content }
        }
    }
}

private struct HotspotRow: View {
    let emoji: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji).font(.system(size: 20)).frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13, weight: .bold))
                Text(detail).font(.system(size: 12)).foregroundStyle(GF.muted).lineSpacing(3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 81, alignment: .leading)
        .softCard(radius: 16)
    }
}

private struct RecommendationRow: View {
    let name: String
    let industry: String
    let change: String
    let color: Color

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 14, weight: .bold))
            Text(industry)
                .font(.system(size: 11))
                .foregroundStyle(GF.muted)
            Spacer()
            Text(change)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Image(systemName: "bolt")
                .font(.system(size: 12))
                .foregroundStyle(GF.gold)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .softCard(radius: 16)
    }
}

private struct ProfileView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                profileHero
                plantStatus
                badges
                LearningSection()
                settingsList
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 96)
        }
        .background(GF.background.ignoresSafeArea())
        .accessibilityLabel("我的")
    }

    private var profileHero: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top) {
                HStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        Text("🧑‍💼")
                            .font(.system(size: 30))
                            .frame(width: 64, height: 64)
                            .background(.white.opacity(0.30), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.60), lineWidth: 1))
                        Text("3")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(GF.mint, in: Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                            .offset(x: 3, y: 3)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("小希同学")
                            .font(.system(size: 20, weight: .bold))
                        Text("理财新手 · 成长中 🌱")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                Spacer()
                Image(systemName: "gearshape")
                    .font(.system(size: 16))
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 14))
            }

            HStack(spacing: 12) {
                ProfileMetric(value: "1,280", label: "积分")
                ProfileMetric(value: "21天", label: "连续天数")
                ProfileMetric(value: "4节", label: "课程")
                ProfileMetric(value: "3枚", label: "徽章")
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [GF.orange, GF.gold, GF.warmTop], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(edges: .top)
        )
        .padding(.horizontal, -24)
    }

    private var plantStatus: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Text("🪴").font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("我的小植物").font(.system(size: 14, weight: .semibold))
                        Text("成长中 · Lv.3 · 还差22分开花").font(.system(size: 12)).foregroundStyle(GF.muted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(GF.muted)
            }
            HStack(spacing: 8) {
                ForEach(["种", "发", "成", "开", "结"], id: \.self) { item in
                    VStack(spacing: 4) {
                        Capsule().fill(["种", "发", "成"].contains(item) ? AnyShapeStyle(GF.orangeGradient) : AnyShapeStyle(GF.line)).frame(height: 6)
                        Text(item).font(.system(size: 9)).foregroundStyle(["种", "发", "成"].contains(item) ? GF.orange : GF.muted)
                    }
                }
            }
        }
        .padding(20)
        .card(radius: 24, shadowOpacity: 0.08)
        .offset(y: -16)
        .padding(.bottom, -16)
    }

    private var badges: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "🏆 成就徽章", action: "查看全部")
            HStack(spacing: 10) {
                AchievementBadge(emoji: "🌱", title: "新手理财")
                AchievementBadge(emoji: "📅", title: "坚持21天")
                AchievementBadge(emoji: "💰", title: "存钱达人")
                AchievementBadge(emoji: "📚", title: "知识先锋")
            }
        }
    }

    private var settingsList: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "bell", title: "消息通知", subtitle: "账单提醒、涨跌提醒", color: GF.orange)
            SettingsRow(icon: "shield", title: "账户安全", subtitle: "密码、绑定手机", color: GF.mint)
            SettingsRow(icon: "book", title: "学习记录", subtitle: "已学4节课程", color: GF.purple)
            SettingsRow(icon: "square.and.arrow.up", title: "邀请好友", subtitle: "分享得积分奖励", color: Color(hex: 0xF59E0B))
            SettingsRow(icon: "questionmark.circle", title: "帮助中心", subtitle: "常见问题解答", color: Color(hex: 0x3B82F6))
            SettingsRow(icon: "gearshape", title: "设置", subtitle: "主题、语言、清除缓存", color: GF.muted)
        }
        .card(radius: 24)
    }
}

private struct ProfileMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 15, weight: .bold, design: .rounded))
            Text(label).font(.system(size: 11)).foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, minHeight: 63)
        .background(.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct SectionHeader: View {
    let title: String
    let action: String

    var body: some View {
        HStack {
            Text(title).font(.system(size: 15, weight: .semibold))
            Spacer()
            Text(action)
                .font(.system(size: 12))
                .foregroundStyle(GF.orange)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(GF.orange)
        }
    }
}

private struct AchievementBadge: View {
    let emoji: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji).font(.system(size: 24))
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(GF.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 78)
        .card(radius: 12, shadowOpacity: 0.04)
    }
}

private struct LearningSection: View {
    private let lessons = [
        Lesson(cover: "▶️", title: "理财入门：从零开始认识投资", meta: "⭐ 4.9   👥 2.3万学   ⏱ 12分钟", tag: "热门", progress: nil),
        Lesson(cover: "📈", title: "股票基础：如何看K线图", meta: "⭐ 4.8   ⏱ 18分钟", tag: "新课", progress: 0.45),
        Lesson(cover: "🧑‍🏫", title: "基金定投：月光族也能攒钱", meta: "⭐ 4.7   ⏱ 15分钟", tag: "必修", progress: 0.30),
        Lesson(cover: "💼", title: "避开理财陷阱：P2P血泪史", meta: "⭐ 5   ⏱ 20分钟", tag: "必读", progress: nil)
    ]

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "📚 理财课堂", action: "全部课程")
            VStack(spacing: 10) {
                ForEach(lessons) { lesson in
                    LessonRow(lesson: lesson)
                }
            }
        }
    }
}

private struct Lesson: Identifiable {
    let id = UUID()
    let cover: String
    let title: String
    let meta: String
    let tag: String
    let progress: Double?
}

private struct LessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(GF.ink.opacity(0.10))
                Text(lesson.cover).font(.system(size: 30))
            }
            .frame(width: lesson.progress == nil ? 188 : 72, height: lesson.progress == nil ? 106 : 72)

            if lesson.progress != nil {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(lesson.title).font(.system(size: 12, weight: .semibold))
                        Spacer()
                        Text(lesson.tag).font(.system(size: 10)).foregroundStyle(GF.mint)
                    }
                    Text(lesson.meta).font(.system(size: 10)).foregroundStyle(GF.muted)
                    ProgressLine(value: lesson.progress ?? 0, color: GF.orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(lesson.progress == nil ? 0 : 8)
        .overlay(alignment: .bottomLeading) {
            if lesson.progress == nil {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.tag)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(GF.orange, in: Capsule())
                    Spacer()
                    Text(lesson.title).font(.system(size: 13, weight: .bold))
                    Text(lesson.meta).font(.system(size: 10)).foregroundStyle(GF.muted)
                }
                .padding(14)
            }
        }
        .frame(height: lesson.progress == nil ? 176 : 88)
        .card(radius: 16, shadowOpacity: 0.04)
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(GF.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(GF.muted)
        }
        .padding(.horizontal, 20)
        .frame(height: 70)
        .overlay(alignment: .bottomTrailing) {
            Rectangle().fill(GF.background).frame(width: 238, height: 1)
        }
    }
}

#Preview("GrowFi") {
    RootTabView()
}
