//
//  BalanceCard.swift
//  expense_tracker
//
//  Premium metallic balance card with gyroscope effect
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
    
    // MARK: - Computed Properties
    
    private var rotationX: Double {
        Double(dragOffset.height / 8)
    }
    
    private var rotationY: Double {
        Double(-dragOffset.width / 8)
    }
    
    private var highlightX: CGFloat {
        0.5 + dragOffset.width / 600
    }
    
    private var highlightY: CGFloat {
        0.5 + dragOffset.height / 400
    }
    
    // MARK: - Body
    
    var body: some View {
        cardBody
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.25),
                                .white.opacity(0.05),
                                .black.opacity(0.1),
                                .white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 24, x: CGFloat(-rotationY), y: CGFloat(rotationX))
            .shadow(color: .black.opacity(0.3), radius: 8, x: CGFloat(-rotationY * 0.3), y: CGFloat(rotationX * 0.3))
            .rotation3DEffect(
                .degrees(rotationX),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(rotationY),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            isDragging = false
                            dragOffset = .zero
                        }
                    }
            )
            .scaleEffect(animateCard ? 1.0 : 0.9)
            .opacity(animateCard ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateCard = true
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                    animateNumbers = true
                }
            }
    }
    
    // MARK: - Card Body
    
    private var cardBody: some View {
        ZStack {
            // Metal base
            metalBase
            
            // Brushed texture
            brushedTexture
            
            // Anisotropic bands
            anisotropicBands
            
            // Specular highlight
            specularHighlight
            
            // Holographic sheen
            holographicSheen
            
            // Inner bevel
            innerBevel
            
            // Balance content
            balanceContent
        }
    }
    
    // MARK: - Metal Base
    
    private var metalBase: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.83, green: 0.85, blue: 0.87), location: 0.0),
                .init(color: Color(red: 0.76, green: 0.78, blue: 0.80), location: 0.15),
                .init(color: Color(red: 0.80, green: 0.82, blue: 0.85), location: 0.30),
                .init(color: Color(red: 0.68, green: 0.70, blue: 0.73), location: 0.45),
                .init(color: Color(red: 0.75, green: 0.77, blue: 0.79), location: 0.60),
                .init(color: Color(red: 0.82, green: 0.84, blue: 0.86), location: 0.75),
                .init(color: Color(red: 0.72, green: 0.74, blue: 0.76), location: 0.90),
                .init(color: Color(red: 0.78, green: 0.80, blue: 0.82), location: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Brushed Texture
    
    private var brushedTexture: some View {
        Canvas { context, size in
            for i in 0..<Int(size.height) {
                let y = CGFloat(i)
                let seed = sin(Double(i) * 0.7) * cos(Double(i) * 1.3) * sin(Double(i) * 3.1)
                let alpha = 0.03 + seed * 0.025
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                
                if alpha > 0 {
                    context.stroke(path, with: .color(.white.opacity(alpha)), lineWidth: 0.5)
                } else {
                    context.stroke(path, with: .color(.black.opacity(-alpha * 0.6)), lineWidth: 0.5)
                }
            }
            
            for i in stride(from: 0, to: Int(size.height), by: 3) {
                let y = CGFloat(i)
                let seed2 = cos(Double(i) * 2.1) * sin(Double(i) * 0.4)
                let alpha2 = 0.015 + seed2 * 0.015
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                
                if alpha2 > 0 {
                    context.stroke(path, with: .color(.white.opacity(alpha2)), lineWidth: 1.0)
                }
            }
        }
        .blendMode(.overlay)
    }
    
    // MARK: - Anisotropic Bands
    
    private var anisotropicBands: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .white.opacity(0.06), location: 0.18),
                .init(color: .clear, location: 0.25),
                .init(color: .white.opacity(0.05), location: 0.42),
                .init(color: .clear, location: 0.50),
                .init(color: .white.opacity(0.07), location: 0.65),
                .init(color: .clear, location: 0.72),
                .init(color: .white.opacity(0.04), location: 0.88),
                .init(color: .clear, location: 1.0),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .blendMode(.screen)
    }
    
    // MARK: - Specular Highlight
    
    private var specularHighlight: some View {
        RadialGradient(
            colors: [
                .white.opacity(isDragging ? 0.30 : 0.12),
                .white.opacity(isDragging ? 0.08 : 0.03),
                .clear
            ],
            center: UnitPoint(x: highlightX, y: highlightY),
            startRadius: 10,
            endRadius: 220
        )
        .blendMode(.screen)
    }
    
    // MARK: - Holographic Sheen
    
    private var holographicSheen: some View {
        AngularGradient(
            colors: [
                Color.red.opacity(0.03),
                Color.green.opacity(0.03),
                Color.blue.opacity(0.04),
                Color.yellow.opacity(0.03),
                Color.purple.opacity(0.03),
                Color.cyan.opacity(0.03),
                Color.red.opacity(0.03),
            ],
            center: UnitPoint(x: highlightX, y: highlightY)
        )
        .blendMode(.colorDodge)
        .opacity(isDragging ? 0.8 : 0.4)
    }
    
    // MARK: - Inner Bevel
    
    private var innerBevel: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.2),
                        .clear,
                        .black.opacity(0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
    }
    
    // MARK: - Balance Content
    
    private var balanceContent: some View {
        VStack(spacing: 16) {
            // Month display
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
                    .foregroundColor(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.55))
                
                Text(formatCurrency(summary.balance))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(textGradient)
                    .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
                    .opacity(animateNumbers ? 1 : 0)
                    .scaleEffect(animateNumbers ? 1.0 : 0.8)
            }
            
            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 40)
            
            // Income and Expenses
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.green.opacity(0.7))
                        
                        Text("INCOME")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(1.5)
                            .foregroundColor(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.55))
                    }
                    
                    Text(formatCurrency(summary.totalIncome))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(textGradient)
                        .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.3))
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.red.opacity(0.7))
                        
                        Text("EXPENSES")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(1.5)
                            .foregroundColor(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.55))
                    }
                    
                    Text(formatCurrency(summary.totalExpenses))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(textGradient)
                        .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
    }
    
    // MARK: - Text Gradient
    
    private var textGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.32, green: 0.34, blue: 0.38),
                Color(red: 0.25, green: 0.27, blue: 0.30),
                Color(red: 0.38, green: 0.40, blue: 0.42),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Helper Methods
    
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: summary.month).uppercased()
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        let nsDecimal = value as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.05)
            .ignoresSafeArea()
        
        BalanceCard(summary: MonthlySummary(
            month: Date(),
            totalIncome: 5000.00,
            totalExpenses: 3200.50,
            transactionCount: 25
        ))
        .padding()
    }
}
