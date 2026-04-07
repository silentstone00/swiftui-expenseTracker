//
//  InnerShadowModifier.swift
//  expense_tracker
//
//  Custom inner shadow effect matching Figma design
//

import SwiftUI

struct InnerShadow: ViewModifier {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color, lineWidth: radius * 2)
                    .blur(radius: radius)
                    .offset(x: x, y: y)
                    .mask(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black, .black, .clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
    }
}

extension View {
    func innerShadow(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        self.modifier(InnerShadow(color: color, radius: radius, x: x, y: y))
    }
}
