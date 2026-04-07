//
//  StatsView.swift
//  expense_tracker
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var viewModel: TransactionViewModel
    @State private var selectedPeriod: Period = .monthly

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
            Color(red: 0.38, green: 0.52, blue: 1.0),   // indigo
            Color(red: 0.68, green: 0.38, blue: 1.0),   // violet
            Color(red: 1.0,  green: 0.38, blue: 0.58),  // rose
            Color(red: 1.0,  green: 0.72, blue: 0.22),  // amber
            Color(red: 0.22, green: 0.88, blue: 0.72),  // teal
            Color(red: 0.38, green: 0.92, blue: 0.58),  // mint
        ]

        if selectedPeriod == .weekly {
            // Week: breakdown by day of week
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
            // Month: breakdown by category
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
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            if viewModel.transactions.isEmpty {
                SmartEmptyState(type: .noStats)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        periodPicker
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        summaryRow
                            .padding(.horizontal, 20)

                        if !expenseCategories.isEmpty {
                            spendingBreakdownCard
                                .padding(.horizontal, 20)

                            topCategoriesSection
                                .padding(.horizontal, 20)
                        }

                        trendCard
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 110)
                }
            }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(Period.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .frame(height : 50)
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: 10) {
            StatSummaryCard(label: "Income", amount: totalIncome, color: Color(red: 0.3, green: 0.85, blue: 0.5))
            StatSummaryCard(label: "Expenses", amount: totalExpenses, color: Color(red: 1, green: 0.35, blue: 0.35))
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
                .foregroundColor(.white)

            // Donut chart
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
                        .foregroundColor(Color(white: 0.45))
                    Text(formatCurrency(totalExpenses))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                }
            }

            // Legend grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(pieData) { slice in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(slice.color)
                            .frame(width: 10, height: 10)
                        Text(slice.label)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Text(formatCurrencyShort(slice.value))
                            .font(.caption)
                            .foregroundColor(Color(white: 0.45))
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(white: 0.115), Color(white: 0.075)],
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
                .foregroundColor(.white)

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
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 14) {
                    TrendLegendDot(color: Color(red: 0.3, green: 0.85, blue: 0.5), label: "Income")
                    TrendLegendDot(color: Color(red: 1, green: 0.35, blue: 0.35), label: "Expenses")
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
                            colors: [
                                Color(red: 0.55, green: 1.0,  blue: 0.75),
                                Color(red: 0.18, green: 0.72, blue: 0.48)
                            ],
                            startPoint: .top, endPoint: .bottom
                          )
                        : LinearGradient(
                            colors: [
                                Color(red: 1.0,  green: 0.52, blue: 0.52),
                                Color(red: 0.85, green: 0.18, blue: 0.28)
                            ],
                            startPoint: .top, endPoint: .bottom
                          )
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
                                .foregroundColor(Color(white: 0.38))
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color(white: 0.13))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption2)
                                .foregroundColor(Color(white: 0.38))
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(white: 0.115), Color(white: 0.075)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Decimal) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: value as NSNumber) ?? "$0"
    }

    private func formatCurrencyShort(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "$%.0fk", value / 1000)
        }
        return String(format: "$%.0f", value)
    }

    private func formatAxisAmount(_ amount: Double) -> String {
        if amount >= 1000 { return String(format: "$%.0fk", amount / 1000) }
        return "$\(Int(amount))"
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
                .foregroundColor(Color(white: 0.45))
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
                colors: [Color(white: 0.115), Color(white: 0.07)],
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
        fmt.currencyCode = "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: amount as NSNumber) ?? "$0"
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
                .foregroundColor(Color(white: 0.3))
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
                .foregroundColor(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedAmount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(Color(white: 0.4))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color(white: 0.115), Color(white: 0.075)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
    }

    private var formattedAmount: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "USD"
        fmt.maximumFractionDigits = 0
        return fmt.string(from: amount as NSNumber) ?? "$0"
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
                .foregroundColor(Color(white: 0.45))
        }
    }
}

// MARK: - Preview

#Preview {
    StatsView()
}
