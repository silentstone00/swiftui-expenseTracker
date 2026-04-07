//
//  StatsView.swift
//  expense_tracker
//
//  Enhanced statistics view with animated pie charts and insights
//

import SwiftUI

struct StatsView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var viewModel: TransactionViewModel
    @State private var selectedPeriod: Period = .monthly
    
    // MARK: - Period Enum
    
    enum Period: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                if viewModel.transactions.isEmpty {
                    SmartEmptyState(type: .noStats)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            // Period selector
                            periodSelector
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            
                            // Spending breakdown with pie chart
                            spendingBreakdownSection
                            
                            // Category insights
                            categoryInsightsSection
                            
                            // Spending trend chart
                            spendingTrendSection
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedPeriod == period ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                if selectedPeriod == period {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .matchedGeometryEffect(id: "period", in: namespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(14)
    }
    
    @Namespace private var namespace
    
    // MARK: - Spending Breakdown Section
    
    private var spendingBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Spending Breakdown")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            if let summary = viewModel.monthlySummary, !summary.categoryBreakdown.isEmpty {
                HStack(alignment: .top, spacing: 24) {
                    // Pie chart
                    AnimatedPieChart(data: pieChartData)
                        .frame(width: 160, height: 160)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(pieChartData.prefix(5)), id: \.id) { slice in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(slice.color)
                                    .frame(width: 12, height: 12)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(slice.category)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Text(formatCurrency(slice.value))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.09, green: 0.09, blue: 0.09))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Category Insights Section
    
    private var categoryInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Categories")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            if let summary = viewModel.monthlySummary {
                ForEach(Array(summary.categoryBreakdown.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key.id) { category, amount in
                    CategoryInsightRow(
                        category: category,
                        amount: amount,
                        totalExpenses: summary.totalExpenses
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Spending Trend Section
    
    private var spendingTrendSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spending Trend")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Income")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("Expenses")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Bar chart
            if !viewModel.transactions.isEmpty {
                enhancedBarChart
                    .frame(height: 220)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.09, green: 0.09, blue: 0.09))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Enhanced Bar Chart
    
    private var enhancedBarChart: some View {
        GeometryReader { geometry in
            let chartData = getChartData()
            let maxAmount = getMaxAmount()
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(chartData.enumerated()), id: \.element.day) { index, data in
                    VStack(spacing: 8) {
                        // Bars container
                        VStack(spacing: 4) {
                            // Income bar
                            if data.income > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: (geometry.size.width - CGFloat(chartData.count - 1) * 8) / CGFloat(chartData.count),
                                        height: calculateBarHeight(amount: data.income, maxAmount: maxAmount, totalHeight: 160)
                                    )
                            }
                            
                            // Expense bar
                            if data.expense > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .red.opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: (geometry.size.width - CGFloat(chartData.count - 1) * 8) / CGFloat(chartData.count),
                                        height: calculateBarHeight(amount: data.expense, maxAmount: maxAmount, totalHeight: 160)
                                    )
                            }
                        }
                        .frame(height: 160, alignment: .bottom)
                        
                        // Day label
                        Text(data.day)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(width: (geometry.size.width - CGFloat(chartData.count - 1) * 8) / CGFloat(chartData.count))
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var pieChartData: [PieSliceData] {
        guard let summary = viewModel.monthlySummary else { return [] }
        
        let colors: [Color] = [
            .blue, .purple, .pink, .orange, .green, .yellow, .red, .cyan
        ]
        
        return summary.categoryBreakdown
            .sorted(by: { $0.value > $1.value })
            .enumerated()
            .map { index, item in
                PieSliceData(
                    category: item.key.name,
                    value: item.value,
                    color: colors[index % colors.count]
                )
            }
    }
    
    // MARK: - Helper Methods
    
    private func getChartData() -> [ChartData] {
        let calendar = Calendar.current
        let now = Date()
        
        if selectedPeriod == .weekly {
            return (0..<7).reversed().map { dayOffset in
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                    return ChartData(day: "", income: 0, expense: 0)
                }
                
                let dayTransactions = viewModel.transactions.filter {
                    calendar.isDate($0.date, inSameDayAs: date)
                }
                
                let income = dayTransactions.filter { $0.type == .income }.reduce(Decimal(0)) { $0 + $1.amount }
                let expense = dayTransactions.filter { $0.type == .expense }.reduce(Decimal(0)) { $0 + $1.amount }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                let dayName = formatter.string(from: date)
                
                return ChartData(day: dayName, income: income, expense: expense)
            }
        } else {
            return (0..<6).reversed().map { monthOffset in
                guard let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) else {
                    return ChartData(day: "", income: 0, expense: 0)
                }
                
                let monthTransactions = viewModel.transactions.filter {
                    calendar.isDate($0.date, equalTo: date, toGranularity: .month)
                }
                
                let income = monthTransactions.filter { $0.type == .income }.reduce(Decimal(0)) { $0 + $1.amount }
                let expense = monthTransactions.filter { $0.type == .expense }.reduce(Decimal(0)) { $0 + $1.amount }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                let monthName = formatter.string(from: date)
                
                return ChartData(day: monthName, income: income, expense: expense)
            }
        }
    }
    
    private func getMaxAmount() -> Decimal {
        let data = getChartData()
        let maxIncome = data.map { $0.income }.max() ?? 0
        let maxExpense = data.map { $0.expense }.max() ?? 0
        return max(maxIncome, maxExpense)
    }
    
    private func calculateBarHeight(amount: Decimal, maxAmount: Decimal, totalHeight: CGFloat) -> CGFloat {
        guard maxAmount > 0 else { return 0 }
        let ratio = CGFloat(truncating: amount as NSNumber) / CGFloat(truncating: maxAmount as NSNumber)
        return max(4, totalHeight * ratio)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

// MARK: - Chart Data Model

struct ChartData {
    let day: String
    let income: Decimal
    let expense: Decimal
}

// MARK: - Category Insight Row

struct CategoryInsightRow: View {
    let category: Category
    let amount: Decimal
    let totalExpenses: Decimal
    
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(category.color.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(category.color.color)
                }
                
                // Category name and percentage
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(percentage)% of total")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Amount
                Text(formatCurrency(amount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [category.color.color, category.color.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateProgress ? geometry.size.width * CGFloat(percentage) / 100 : 0, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.09, green: 0.09, blue: 0.09))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(category.color.color.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateProgress = true
            }
        }
    }
    
    private var percentage: Int {
        guard totalExpenses > 0 else { return 0 }
        let ratio = Double(truncating: amount as NSNumber) / Double(truncating: totalExpenses as NSNumber)
        return Int(ratio * 100)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

// MARK: - Preview

#Preview {
    StatsView()
}
