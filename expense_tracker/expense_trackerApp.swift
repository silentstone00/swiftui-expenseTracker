//
//  expense_trackerApp.swift
//  expense_tracker
//
//  Created by Aviral Saxena on 4/7/26.
//

import SwiftUI

@main
struct expense_trackerApp: App {
    // Initialize Core Data stack on app launch
    let dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.viewContext)
        }
    }
}
