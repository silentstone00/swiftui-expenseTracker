//
//  AnimatedPieChart.swift
//  expense_tracker
//
//  Animated pie chart component for category spending visualization
//

import SwiftUI

struct AnimatedPieChart: View {
    let data: [PieSliceData]
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, slice in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: slice.color
                    )
                    .scaleEffect(animationProgress)
                    .opacity(animationProgress)
                }
                
                // Center hole for donut effect
                Circle()
                    .fill(Color(red: 0.05, green: 0.05, blue: 0.05))
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                
                // Total in center
                VStack(spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(formatCurrency(totalAmount))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .opacity(animationProgress)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var totalAmount: Decimal {
        data.reduce(Decimal(0)) { $0 + $1.value }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousTotal = data.prefix(index).reduce(Decimal(0)) { $0 + $1.value }
        let ratio = CGFloat(truncating: previousTotal as NSNumber) / CGFloat(truncating: totalAmount as NSNumber)
        return .degrees(ratio * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let currentTotal = data.prefix(index + 1).reduce(Decimal(0)) { $0 + $1.value }
        let ratio = CGFloat(truncating: currentTotal as NSNumber) / CGFloat(truncating: totalAmount as NSNumber)
        return .degrees(ratio * 360 - 90)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

extension PieSlice: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        return self
    }
}

extension PieSlice {
    var body: some View {
        self.fill(color)
    }
}

struct PieSliceData: Identifiable {
    let id = UUID()
    let category: String
    let value: Decimal
    let color: Color
}
