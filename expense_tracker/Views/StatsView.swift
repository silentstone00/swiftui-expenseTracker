//
//  StatsView.swift
//  expense_tracker
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var viewModel: TransactionViewModel
    @State private var selectedPeriod: Period = .monthly
    @State private var showCSVShare: Bool = false
    @State private var csvActivityItem: CSVActivityItem? = nil
    @State private var isGenerating: Bool = false

    enum Period: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
    }

    // MARK: - Computed Data

    private var periodTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        switch selectedPeriod {
        case .weekly:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return viewModel.transactions.filter { $0.date >= start && $0.date <= now }
        case .monthly:
            let comps = calendar.dateComponents([.year, .month], from: now)
            guard let start = calendar.date(from: comps) else { return [] }
            let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start) ?? now
            return viewModel.transactions.filter { $0.date >= start && $0.date <= end }
        }
    }

    private var totalIncome: Decimal {
        periodTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Decimal {
        periodTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var netAmount: Decimal { totalIncome - totalExpenses }

    private var expenseCategories: [(category: Category, amount: Decimal)] {
        var breakdown: [Category: Decimal] = [:]
        for t in periodTransactions where t.type == .expense {
            breakdown[t.category, default: 0] += t.amount
        }
        return breakdown
            .map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    private var pieData: [PieEntry] {
        let palette: [Color] = [
            Color(red: 0.38, green: 0.52, blue: 1.0),
            Color(red: 0.68, green: 0.38, blue: 1.0),
            Color(red: 1.0,  green: 0.38, blue: 0.58),
            Color(red: 1.0,  green: 0.72, blue: 0.22),
            Color(red: 0.22, green: 0.88, blue: 0.72),
            Color(red: 0.38, green: 0.92, blue: 0.58),
        ]

        if selectedPeriod == .weekly {
            let calendar = Calendar.current
            let fmt = DateFormatter(); fmt.dateFormat = "EEE"
            var byDay: [String: (total: Decimal, order: Int)] = [:]
            for t in periodTransactions where t.type == .expense {
                let day = fmt.string(from: t.date)
                let weekday = calendar.component(.weekday, from: t.date)
                byDay[day] = ((byDay[day]?.total ?? 0) + t.amount, weekday)
            }
            return byDay
                .sorted { $0.value.order < $1.value.order }
                .enumerated()
                .map { i, item in
                    PieEntry(id: UUID(), label: item.key,
                             value: Double(truncating: item.value.total as NSNumber),
                             color: palette[i % palette.count])
                }
        } else {
            return expenseCategories.prefix(6).enumerated().map { i, item in
                PieEntry(
                    id: item.category.id,
                    label: item.category.name,
                    value: Double(truncating: item.amount as NSNumber),
                    color: palette[i % palette.count]
                )
            }
        }
    }

    private var pieChartTitle: String {
        selectedPeriod == .weekly ? "Daily Spending" : "Spending Breakdown"
    }

    private var trendData: [TrendEntry] {
        let calendar = Calendar.current
        let now = Date()
        var items: [TrendEntry] = []

        if selectedPeriod == .weekly {
            let fmt = DateFormatter(); fmt.dateFormat = "EEE"
            for offset in (0..<7).reversed() {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { continue }
                let label = fmt.string(from: date)
                let dayTx = viewModel.transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let inc = dayTx.filter { $0.type == .income }.reduce(0.0) { $0 + Double(truncating: $1.amount as NSNumber) }
                let exp = dayTx.filter { $0.type == .expense }.reduce(0.0) { $0 + Double(truncating: $1.amount as NSNumber) }
                items.append(TrendEntry(label: label, type: "Income", amount: inc))
                items.append(TrendEntry(label: label, type: "Expenses", amount: exp))
            }
        } else {
            let fmt = DateFormatter(); fmt.dateFormat = "MMM"
            for offset in (0..<6).reversed() {
                guard let date = calendar.date(byAdding: .month, value: -offset, to: now) else { continue }
                let label = fmt.string(from: date)
                let monthTx = viewModel.transactions.filter {
                    calendar.isDate($0.date, equalTo: date, toGranularity: .month)
                }
                let inc = monthTx.filter { $0.type == .income }.reduce(0.0) { $0 + Double(truncating: $1.amount as NSNumber) }
                let exp = monthTx.filter { $0.type == .expense }.reduce(0.0) { $0 + Double(truncating: $1.amount as NSNumber) }
                items.append(TrendEntry(label: label, type: "Income", amount: inc))
                items.append(TrendEntry(label: label, type: "Expenses", amount: exp))
            }
        }
        return items
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.transactions.isEmpty {
                SmartEmptyState(type: .noStats, style: .centered)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        periodPicker
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        if !expenseCategories.isEmpty {
                            spendingBreakdownCard.padding(.horizontal, 20)
                            topCategoriesSection.padding(.horizontal, 20)
                        }

                        trendCard.padding(.horizontal, 20)

                        if selectedPeriod == .monthly {
                            generateReportButton.padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 110)
                }
                .gesture(
                    DragGesture(minimumDistance: 40, coordinateSpace: .local)
                        .onEnded { value in
                            // Only respond to clearly horizontal swipes
                            guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                if value.translation.width < 0 {
                                    // Swipe left → Month
                                    selectedPeriod = .monthly
                                } else {
                                    // Swipe right → Week
                                    selectedPeriod = .weekly
                                }
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                )
            }
        }
        .sheet(isPresented: $showCSVShare) {
            if let item = csvActivityItem {
                ShareSheet(item: item)
            }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(Period.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .frame(height: 50)
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: 10) {
            StatSummaryCard(label: "Income",   amount: totalIncome,   color: Color(red: 0.3, green: 0.85, blue: 0.5))
            StatSummaryCard(label: "Expenses", amount: totalExpenses, color: Color(red: 1,   green: 0.35, blue: 0.35))
            StatSummaryCard(
                label: "Net",
                amount: netAmount,
                color: netAmount >= 0 ? Color(red: 0.3, green: 0.85, blue: 0.5) : Color(red: 1, green: 0.35, blue: 0.35)
            )
        }
    }

    // MARK: - Spending Breakdown

    private var spendingBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(pieChartTitle)
                .font(.headline)
                .foregroundColor(.primaryText)

            ZStack {
                Chart(pieData) { slice in
                    SectorMark(
                        angle: .value("Amount", slice.value),
                        innerRadius: .ratio(0.64),
                        angularInset: 2.5
                    )
                    .foregroundStyle(slice.color)
                    .cornerRadius(5)
                }
                .frame(height: 190)

                VStack(spacing: 3) {
                    Text("Total")
                        .font(.caption2)
                        .foregroundColor(.tertiaryText)
                    Text(formatCurrency(totalExpenses))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primaryText)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(pieData) { slice in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(slice.color)
                            .frame(width: 10, height: 10)
                        Text(slice.label)
                            .font(.caption)
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Text(formatCurrencyShort(slice.value))
                            .font(.caption)
                            .foregroundColor(.tertiaryText)
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.statCardTop, .statCardBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }

    // MARK: - Top Categories

    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Categories")
                .font(.headline)
                .foregroundColor(.primaryText)

            VStack(spacing: 8) {
                ForEach(Array(expenseCategories.prefix(2).enumerated()), id: \.element.category.id) { index, item in
                    StatCategoryRow(
                        rank: index + 1,
                        category: item.category,
                        amount: item.amount,
                        percentage: totalExpenses > 0
                            ? Double(truncating: item.amount as NSNumber) / Double(truncating: totalExpenses as NSNumber)
                            : 0
                    )
                }
            }
        }
    }

    // MARK: - Trend Chart

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trend")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                Spacer()
                HStack(spacing: 14) {
                    TrendLegendDot(color: Color(red: 0.3, green: 0.85, blue: 0.5),  label: "Income")
                    TrendLegendDot(color: Color(red: 1,   green: 0.35, blue: 0.35), label: "Expenses")
                }
            }

            Chart(trendData) { item in
                BarMark(
                    x: .value("Period", item.label),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(
                    item.type == "Income"
                        ? LinearGradient(
                            colors: [Color(red: 0.55, green: 1.0, blue: 0.75), Color(red: 0.18, green: 0.72, blue: 0.48)],
                            startPoint: .top, endPoint: .bottom)
                        : LinearGradient(
                            colors: [Color(red: 1.0, green: 0.52, blue: 0.52), Color(red: 0.85, green: 0.18, blue: 0.28)],
                            startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(5)
                .position(by: .value("Type", item.type), axis: .horizontal, span: .ratio(0.55))
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(formatAxisAmount(v))
                                .font(.caption2)
                                .foregroundColor(.secondaryText)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondaryText.opacity(0.3))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption2)
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.statCardTop, .statCardBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }

    // MARK: - Generate Report Button

    private var currentMonthName: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"  // Only month name, no year
        return fmt.string(from: Date())
    }

    private var generateReportButton: some View {
        Button(action: {
            guard !isGenerating else { return }
            isGenerating = true
            // Capture data on main thread before jumping off
            let transactions = periodTransactions.sorted(by: { $0.date < $1.date })
            let fileName = "\(currentMonthName.replacingOccurrences(of: " ", with: "_"))_Transactions.csv"
            Task.detached(priority: .userInitiated) {
                let data = buildCSVData(from: transactions)
                await MainActor.run {
                    if let data {
                        csvActivityItem = CSVActivityItem(data: data, fileName: fileName)
                        showCSVShare = true
                    }
                    isGenerating = false
                }
            }
        }) {
            HStack(spacing: 10) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.primaryText)
                        .scaleEffect(0.85)
                        .frame(width: 18, height: 18)
                }

                Text(isGenerating ? "Generating…" : "Generate \(currentMonthName) Report")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .id(isGenerating)          // swap view identity to prevent text animation
            }
            .foregroundColor(.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.statCardTop, .statCardBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.primaryText.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func buildCSVData(from transactions: [Transaction]) -> Data? {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd"

        var rows: [String] = ["Date,Category,Type,Amount,Note"]
        for t in transactions {
            let date = dateFmt.string(from: t.date)
            let category = t.category.name.csvEscaped
            let type = t.type == .income ? "Income" : "Expense"
            let amount = String(describing: t.amount)
            let note = (t.note ?? "").csvEscaped
            rows.append("\(date),\(category),\(type),\(amount),\(note)")
        }

        return rows.joined(separator: "\n").data(using: .utf8)
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Decimal) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "INR"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: value as NSNumber) ?? "₹0"
    }

    private func formatCurrencyShort(_ value: Double) -> String {
        value >= 1000 ? String(format: "₹%.0fk", value / 1000) : String(format: "₹%.0f", value)
    }

    private func formatAxisAmount(_ amount: Double) -> String {
        amount >= 1000 ? String(format: "₹%.0fk", amount / 1000) : "₹\(Int(amount))"
    }
}

// MARK: - Supporting Models

struct PieEntry: Identifiable {
    let id: UUID
    let label: String
    let value: Double
    let color: Color
}

struct TrendEntry: Identifiable {
    let id = UUID()
    let label: String
    let type: String
    let amount: Double
}

// MARK: - Supporting Views

private struct StatSummaryCard: View {
    let label: String
    let amount: Decimal
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundColor(.tertiaryText)
            Text(formatted)
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 13)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [.statCardTop, .statCardBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }

    private var formatted: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "INR"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: amount as NSNumber) ?? "₹0"
    }
}

private struct StatCategoryRow: View {
    let rank: Int
    let category: Category
    let amount: Decimal
    let percentage: Double

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption2.weight(.semibold))
                .foregroundColor(.quaternaryText)
                .frame(width: 14, alignment: .center)

            ZStack {
                Circle()
                    .fill(category.color.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(category.color.color)
            }

            Text(category.name)
                .font(.subheadline)
                .foregroundColor(.primaryText)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedAmount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primaryText)
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.tertiaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [.statCardTop, .statCardBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
    }

    private var formattedAmount: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "INR"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: amount as NSNumber) ?? "₹0"
    }
}

private struct TrendLegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
                .font(.caption2)
                .foregroundColor(.tertiaryText)
        }
    }
}

// MARK: - CSV Helpers

private extension String {
    /// Wraps the value in quotes if it contains a comma, quote, or newline
    var csvEscaped: String {
        if self.contains(",") || self.contains("\"") || self.contains("\n") {
            return "\"" + self.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return self
    }
}

// MARK: - CSV Activity Item
//
// UIActivityItemSource writes to temp inside itemForActivityType,
// which runs in the main app process — never via XPC — so the file
// is always accessible regardless of sandbox restrictions.

import UIKit

final class CSVActivityItem: NSObject, UIActivityItemSource {
    private let csvData: Data
    private let fileName: String

    init(data: Data, fileName: String) {
        self.csvData = data
        self.fileName = fileName
    }

    // Placeholder shown while the share sheet is initialising
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return fileName as NSString
    }

    // Called lazily when the user taps a share target — still main-process, not XPC
    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? csvData.write(to: tmpURL, options: .atomic)
        return tmpURL
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return fileName
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let item: CSVActivityItem

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [item], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview { StatsView() }
