//
//  ThemeViewModel.swift
//  expense_tracker
//
//  ViewModel managing theme state and preferences
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ThemeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isDarkMode: Bool {
        didSet {
            // Save preference when isDarkMode changes
            themePreference = isDarkMode ? "dark" : "light"
        }
    }
    
    // MARK: - AppStorage Properties
    
    @AppStorage("userThemePreference") private var themePreference: String = "dark"
    
    // MARK: - Initialization
    
    init() {
        // Initialize isDarkMode based on saved preference
        let savedPreference = UserDefaults.standard.string(forKey: "userThemePreference") ?? "dark"
        self.isDarkMode = (savedPreference == "dark")
        
        // Load saved theme preference on initialization
        loadThemePreference()
    }
    
    // MARK: - Theme Operations
    
    /// Toggle between light and dark mode
    func toggleTheme() {
        isDarkMode.toggle()
        
        // Save the new preference
        let newPreference: ThemePreference = isDarkMode ? .dark : .light
        saveThemePreference(newPreference)
    }
    
    /// Apply a specific theme preference
    func applyTheme(_ theme: ThemePreference) {
        switch theme {
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        case .system:
            // Use system color scheme
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
        
        saveThemePreference(theme)
    }
    
    // MARK: - Private Methods
    
    private func loadThemePreference() {
        guard let preference = ThemePreference(rawValue: themePreference) else {
            // Default to system preference if invalid
            applyTheme(.system)
            return
        }
        
        applyTheme(preference)
    }
    
    private func saveThemePreference(_ preference: ThemePreference) {
        themePreference = preference.rawValue
    }
}

// MARK: - Theme Preference Enum

enum ThemePreference: String {
    case light
    case dark
    case system
}
