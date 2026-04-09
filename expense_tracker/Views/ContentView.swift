//
//  ContentView.swift
//  expense_tracker
//
//  Created by Aviral Saxena on 4/7/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    @State private var showLaunch = true
    @State private var launchOpacity: Double = 1.0

    var body: some View {
        ZStack {
            MainTabView()
                .preferredColorScheme(themeViewModel.isDarkMode ? .dark : .light)

            if showLaunch {
                LaunchScreenView()
                    .opacity(launchOpacity)
                    .ignoresSafeArea()
                    .onAppear {
                        // Hold for 1.6s then fade out over 0.45s
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            withAnimation(.easeInOut(duration: 0.45)) {
                                launchOpacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showLaunch = false
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
