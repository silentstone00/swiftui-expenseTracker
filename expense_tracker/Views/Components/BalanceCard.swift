//
//  BalanceCard.swift
//  expense_tracker
//
//  Enhanced balance card with glassmorphism and subtle gyroscope effect
//

import SwiftUI
import CoreMotion
import Combine

struct BalanceCard: View {
    // MARK: - Properties
    
    let summary: MonthlySummary
    @Environment(\.colorScheme) var colorScheme
    @State private var animateNumbers: Bool = false
    @State private var animateCard: Bool = false
    @State private var isPressed: Bool = false
    
    // Gyroscope motion
    @StateObject private var motionManager = MotionManager()
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Month display with icon
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(monthText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Balance (main value) with animated counter
            VStack(spacing: 6) {
                Text("Total Balance")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Text(formatCurrency(summary.balance))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateNumbers ? 1 : 0)
                    .scaleEffect(animateNumbers ? 1.0 : 0.8)
            }
            
            // Divider with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Income and Expenses row with icons
            HStack(spacing: 0) {
                // Income
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.9))
                        
                        Text("Income")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                            .textCase(.uppercase)
                            .tracking(0.8)
                    }
                    
                    Text(formatCurrency(summary.totalIncome))
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                
                // Vertical divider
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 40)
                
                // Expenses
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.9))
                        
                        Text("Expenses")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                            .textCase(.uppercase)
                            .tracking(0.8)
                    }
                    
                    Text(formatCurrency(summary.totalExpenses))
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
        .background(
            ZStack {
                // Base gradient - teal/blue
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.6, blue: 0.9),   // Deep blue
                        Color(red: 0.4, green: 0.8, blue: 0.75),  // Teal
                        Color(red: 0.3, green: 0.7, blue: 0.85)   // Sky blue
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle gyroscope reflection overlay
                RadialGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.4),
                        .white.opacity(0.2),
                        .clear
                    ]),
                    center: UnitPoint(
                        x: 0.5 + motionManager.roll * 0.15,
                        y: 0.5 + motionManager.pitch * 0.15
                    ),
                    startRadius: 30,
                    endRadius: 250
                )
                .blendMode(.overlay)
                
                // Glassmorphism overlay
                LinearGradient(
                    colors: [.white.opacity(0.15), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(24)
        .shadow(color: Color(red: 0.4, green: 0.8, blue: 0.75).opacity(0.3), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .rotation3DEffect(
            .degrees(motionManager.pitch * 2),
            axis: (x: 1, y: 0, z: 0)
        )
        .rotation3DEffect(
            .degrees(motionManager.roll * 2),
            axis: (x: 0, y: 1, z: 0)
        )
        .scaleEffect(animateCard ? 1.0 : 0.9)
        .opacity(animateCard ? 1.0 : 0.0)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onAppear {
            motionManager.startMonitoring()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateCard = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                animateNumbers = true
            }
        }
        .onDisappear {
            motionManager.stopMonitoring()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Formatted month text
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: summary.month)
    }
    
    // MARK: - Helper Methods
    
    /// Format decimal value as currency
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        let nsDecimal = value as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "$0.00"
    }
}

// MARK: - Motion Manager

class MotionManager: ObservableObject {
    private var motionManager: CMMotionManager
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
    
    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, error == nil else { return }
            
            withAnimation(.easeOut(duration: 0.1)) {
                self?.pitch = motion.attitude.pitch
                self?.roll = motion.attitude.roll
            }
        }
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
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
