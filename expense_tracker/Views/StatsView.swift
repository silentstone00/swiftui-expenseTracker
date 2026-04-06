//
//  StatsView.swift
//  expense_tracker
//
//  Statistics and charts view displaying spending patterns
//

import SwiftUI
import Charts

struct StatsView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedPeriod: Period = .weekly
    
    // MARK: - Period Enum
    
    enum Period: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background matching Figma
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period selector (Weekly/Monthly)
                        periodSelector
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Spending by category
                        categorySpendingSection
                        
                        // Bar chart
                        spendingChartSection
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.05), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            await viewModel.loadTransactions()
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedPeriod == period ? Color(red: 0.05, green: 0.05, blue: 0.05) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period
                                ? Color.white
                                : Color.clear
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(4)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(14)
    }
    
    // MARK: - Category Spending Section
    
    private var categorySpendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if let summary = viewModel.monthlySummary, !summary.categoryBreakdown.isEmpty {
                ForEach(Array(summary.categoryBreakdown.sorted(by: { $0.value > $1.value })), id: \.key.id) { category, amount in
                    CategorySpendingRow(
                        category: category,
                        amount: amount,
                        totalExpenses: summary.totalExpenses
                    )
                    .padding(.horizontal)
                }
            } else {
                emptyStateView
            }
        }
    }
    
    // MARK: - Spending Chart Section
    
    private var spendingChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Spending Trend")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let summary = viewModel.monthlySummary {
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(red: 0.4, green: 0.8, blue: 0.75))
                                .frame(width: 8, height: 8)
                            Text("$\(formatAmount(summary.totalIncome))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 8, height: 8)
                            Text("$\(formatAmount(summary.totalExpenses))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Simple bar chart visualization
            if !viewModel.transactions.isEmpty {
                barChartView
                    .frame(height: 200)
                    .padding(.horizontal)
            } else {
                emptyChartView
            }
        }
    }
    
    // MARK: - Bar Chart View
    
    private var barChartView: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(getChartData(), id: \.day) { data in
                    VStack(spacing: 4) {
                        // Expense bar (gray)
                        if data.expense > 0 {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: (geometry.size.width - CGFloat(getChartData().count - 1) * 12) / CGFloat(getChartData().count), height: calculateBarHeight(amount: data.expense, maxAmount: getMaxAmount(), totalHeight: 160))
                                .cornerRadius(4, corners: [.topLeft, .topRight])
                        }
                        
                        // Income bar (teal)
                        if data.income > 0 {
                            Rectangle()
                                .fill(Color(red: 0.4, green: 0.8, blue: 0.75))
                                .frame(width: (geometry.size.width - CGFloat(getChartData().count - 1) * 12) / CGFloat(getChartData().count), height: calculateBarHeight(amount: data.income, maxAmount: getMaxAmount(), totalHeight: 160))
                                .cornerRadius(4, corners: [.topLeft, .topRight])
                        }
                        
                        // Day label
                        Text(data.day)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty States
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No spending data yet")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No transaction data")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
    
    // MARK: - Helper Methods
    
    private func getChartData() -> [ChartData] {
        let calendar = Calendar.current
        let now = Date()
        
        if selectedPeriod == .weekly {
            // Last 7 days
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
            // Last 6 months
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
        return totalHeight * ratio
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSNumber) ?? "0"
    }
}

// MARK: - Chart Data Model

struct ChartData {
    let day: String
    let income: Decimal
    let expense: Decimal
}

// MARK: - Category Spending Row

struct CategorySpendingRow: View {
    let category: Category
    let amount: Decimal
    let totalExpenses: Decimal
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(category.color.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(category.color.color)
            }
            
            // Category name and comparison
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name.uppercased())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("More than last week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(formatCurrency(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        
        let nsDecimal = value as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "$0"
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    StatsView()
}
