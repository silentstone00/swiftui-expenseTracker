//
//  AppColors.swift
//  expense_tracker
//
//  Semantic color tokens — adapt automatically to dark / light mode.
//

import SwiftUI

extension Color {

    // MARK: - Backgrounds

    /// Main screen background  (dark: #0D0D0D  |  light: systemBackground)
    static let appBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
            : .systemBackground
    })

    /// Sunken field surface — darker than appBackground  (dark: #050505  |  light: systemGray5)
    static let fieldBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
            : .systemGray5
    })

    /// Card / list-row surface  (dark: #171717  |  light: secondarySystemBackground)
    static let cardBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
            : .secondarySystemBackground
    })

    /// Input field / control surface  (dark: #1F1F1F  |  light: tertiarySystemBackground)
    static let inputBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
            : .tertiarySystemBackground
    })

    /// Slightly elevated control (quick-amount buttons, etc.)  (dark: #262626  |  light: systemGray6)
    static let elevatedBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
            : .systemGray6
    })

    // MARK: - Chart / Stat Card Gradients

    /// Top stop of dark stat cards  (dark: white 0.115  |  light: white 0.99)
    static let statCardTop = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.115, alpha: 1)
            : UIColor(white: 0.99, alpha: 1)
    })

    /// Bottom stop of dark stat cards  (dark: white 0.075  |  light: white 0.95)
    static let statCardBottom = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.075, alpha: 1)
            : UIColor(white: 0.95, alpha: 1)
    })

    // MARK: - Text

    /// Primary text  (dark: white  |  light: label)
    static let primaryText = Color(UIColor { t in
        t.userInterfaceStyle == .dark ? .white : .label
    })

    /// Secondary text  (dark: systemGray  |  light: secondaryLabel)
    static let secondaryText = Color(UIColor { t in
        t.userInterfaceStyle == .dark ? .systemGray : .secondaryLabel
    })

    /// Tertiary / caption text  (dark: white 0.45  |  light: tertiaryLabel)
    static let tertiaryText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.45, alpha: 1)
            : .tertiaryLabel
    })

    /// Quaternary / very dim  (dark: white 0.30  |  light: quaternaryLabel)
    static let quaternaryText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.30, alpha: 1)
            : .quaternaryLabel
    })
}
