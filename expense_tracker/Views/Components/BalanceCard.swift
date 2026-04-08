//
//  BalanceCard.swift
//  expense_tracker
//
//  CSS-inspired metallic card:
//  linear-gradient(45deg, #999 5%, #fff 10%, #ccc 30%, #ddd 50%, #ccc 70%, #fff 80%, #999 95%)
//

import SwiftUI
import CoreMotion
import Combine

struct BalanceCard: View {
    // MARK: - Properties

    let summary: MonthlySummary
    @State private var animateNumbers: Bool = false
    @State private var animateCard: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    // MARK: - Tilt

    private var rotationX: Double { Double(dragOffset.height / 8) }
    private var rotationY: Double { Double(-dragOffset.width / 8) }
    private var highlightX: CGFloat { 0.5 + dragOffset.width / 500 }
    private var highlightY: CGFloat { 0.5 + dragOffset.height / 350 }

    // MARK: - Body

    var body: some View {
        cardBody
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            // CSS box-shadow equivalent + subtle edge stroke
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.80), location: 0.0),
                                .init(color: .white.opacity(0.20), location: 0.5),
                                .init(color: Color(white: 0.45).opacity(0.60), location: 1.0),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            // box-shadow: 0 2px 5px rgba(0,0,0,0.3)
            .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 2)
            // deeper shadow for card lift
            .shadow(color: .black.opacity(0.25), radius: 22, x: CGFloat(-rotationY * 0.6), y: CGFloat(rotationX * 0.6) + 8)
            .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .gesture(
                DragGesture()
                    .onChanged { v in
                        withAnimation(.interactiveSpring()) { isDragging = true; dragOffset = v.translation }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { isDragging = false; dragOffset = .zero }
                    }
            )
            .scaleEffect(animateCard ? 1.0 : 0.9)
            .opacity(animateCard ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { animateCard = true }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) { animateNumbers = true }
            }
    }

    // MARK: - Card Body

    private var cardBody: some View {
        ZStack {
            metallicBase      // CSS gradient translated 1-to-1
            movingSheen       // specular that follows drag
            innerBevel        // embossed edge
            balanceContent
        }
    }

    // MARK: - Metallic Base
    //
    // CSS original (45deg):
    //   #999  5%   → Color(white: 0.60)
    //   #fff  10%  → Color(white: 1.00)
    //   #ccc  30%  → Color(white: 0.80)
    //   #ddd  50%  → Color(white: 0.87)
    //   #ccc  70%  → Color(white: 0.80)
    //   #fff  80%  → Color(white: 1.00)
    //   #999  95%  → Color(white: 0.60)

    private var metallicBase: some View {
        LinearGradient(
            stops: [
                .init(color: Color(white: 0.60), location: 0.05),
                .init(color: Color(white: 1.00), location: 0.10),
                .init(color: Color(white: 0.80), location: 0.30),
                .init(color: Color(white: 0.87), location: 0.50),
                .init(color: Color(white: 0.80), location: 0.70),
                .init(color: Color(white: 1.00), location: 0.80),
                .init(color: Color(white: 0.60), location: 0.95),
            ],
            startPoint: .topLeading,   // 45deg
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Moving Sheen
    // Simulates light shifting as you tilt — like hover effect in the CSS

    private var movingSheen: some View {
        RadialGradient(
            colors: [
                .white.opacity(isDragging ? 0.55 : 0.20),
                .white.opacity(0.05),
                .clear,
            ],
            center: UnitPoint(x: highlightX, y: highlightY),
            startRadius: 4,
            endRadius: 160
        )
        .blendMode(.screen)
        .animation(.easeInOut(duration: 0.15), value: isDragging)
    }

    // MARK: - Inner Bevel

    private var innerBevel: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.50), location: 0.0),
                        .init(color: .clear,               location: 0.4),
                        .init(color: .black.opacity(0.15), location: 0.9),
                        .init(color: .black.opacity(0.05), location: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }

    // MARK: - Balance Content

    private var balanceContent: some View {
        VStack(spacing: 16) {
            // Month
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundStyle(textGradient)
                Text(monthText)
                    .font(.system(size: 12, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(textGradient)
            }

            // Balance
            VStack(spacing: 4) {
                Text("TOTAL BALANCE")
                    .font(.system(size: 9, weight: .regular))
                    .tracking(2)
                    // CSS text-shadow: 1px 1px 2px rgba(255,255,255,0.5)
                    .foregroundColor(Color(white: 0.30).opacity(0.60))

                Text(formatCurrency(summary.balance))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(textGradient)
                    .shadow(color: .white.opacity(0.5), radius: 2, x: 1, y: 1) // text-shadow
                    .opacity(animateNumbers ? 1 : 0)
                    .scaleEffect(animateNumbers ? 1.0 : 0.8)
            }

            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color(white: 0.30).opacity(0.25), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 40)

            // Income / Expenses
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.green.opacity(0.75))
                        Text("INCOME")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(1.5)
                            .foregroundColor(Color(white: 0.30).opacity(0.60))
                    }
                    Text(formatCurrency(summary.totalIncome))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(textGradient)
                        .shadow(color: .white.opacity(0.5), radius: 2, x: 1, y: 1)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color(white: 0.30).opacity(0.25))
                    .frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.red.opacity(0.75))
                        Text("EXPENSES")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(1.5)
                            .foregroundColor(Color(white: 0.30).opacity(0.60))
                    }
                    Text(formatCurrency(summary.totalExpenses))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(textGradient)
                        .shadow(color: .white.opacity(0.5), radius: 2, x: 1, y: 1)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
    }

    // MARK: - Text Gradient
    // Dark charcoal — matches CSS color: #000 on metallic background

    private var textGradient: LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.15), Color(white: 0.10), Color(white: 0.20)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Helpers

    private var monthText: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: summary.month).uppercased()
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "INR"
        f.maximumFractionDigits = 2
        return f.string(from: value as NSDecimalNumber) ?? "₹0.00"
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()
        BalanceCard(summary: MonthlySummary(
            month: Date(),
            totalIncome: 5000.00,
            totalExpenses: 3200.50,
            transactionCount: 25
        ))
        .padding()
    }
}
