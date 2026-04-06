//
//  Theme.swift
//  expense_tracker
//
//  Theme colors and styles matching Figma design
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    
    /// Pure black background for dark mode
    static let background = Color(red: 0.05, green: 0.05, blue: 0.05)
    
    /// Card background color
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    /// Primary accent color (teal/cyan)
    static let primaryAccent = Color(red: 0.4, green: 0.8, blue: 0.75)
    
    /// Secondary accent color (peach/beige)
    static let secondaryAccent = Color(red: 0.95, green: 0.85, blue: 0.75)
    
    /// Text colors
    static let primaryText = Color.white
    static let secondaryText = Color.gray
    
    // MARK: - Gradients
    
    /// Balance card gradient (peach to teal)
    static let balanceCardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.95, green: 0.85, blue: 0.75),  // Peach/beige
            Color(red: 0.4, green: 0.8, blue: 0.75)     // Teal/cyan
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Chart gradient (teal)
    static let chartGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.8, blue: 0.75),
            Color(red: 0.3, green: 0.7, blue: 0.65)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Corner Radius
    
    static let cardCornerRadius: CGFloat = 20
    static let buttonCornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    
    // MARK: - Spacing
    
    static let padding: CGFloat = 16
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
}
