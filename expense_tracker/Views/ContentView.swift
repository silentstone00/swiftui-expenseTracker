//
//  ContentView.swift
//  expense_tracker
//
//  Created by Aviral Saxena on 4/7/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    
    var body: some View {
        MainTabView()
            .preferredColorScheme(themeViewModel.isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
