//
//  expense_trackerApp.swift
//  expense_tracker
//
//  Created by Aviral Saxena on 4/7/26.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var showFAB: Bool = true
}

@main
struct expense_trackerApp: App {
    // Initialize Core Data stack on app launch
    let dataManager = DataManager.shared
    
    // Create shared ViewModels as StateObjects
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var themeViewModel = ThemeViewModel()
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.viewContext)
                .environmentObject(transactionViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(themeViewModel)
                .environmentObject(appState)
                .task {
                    // Load data on app launch
                    await transactionViewModel.loadTransactions()
                    await categoryViewModel.loadCategories()
                }
        }
    }
}
