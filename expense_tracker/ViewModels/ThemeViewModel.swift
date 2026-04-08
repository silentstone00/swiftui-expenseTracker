//
//  ThemeViewModel.swift
//  expense_tracker
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ThemeViewModel: ObservableObject {

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            applyWindowStyle()
        }
    }

    init() {
        // Default to dark mode if no preference saved yet
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "isDarkMode")
        applyWindowStyle()
    }

    /// Sets UIKit window style so UIColor(dynamicProvider:) and SwiftUI both agree
    func applyWindowStyle() {
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
