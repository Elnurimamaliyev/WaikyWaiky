//
//  WaikyApp.swift
//  Waiky
//
//  Created by Elnur Imamaliyev on 01.08.2026.
//

import SwiftUI

@main
struct WaikyApp: App {
    @AppStorage("userName") private var userName: String = ""
    @State private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if userName.isEmpty && !hasCompletedOnboarding {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
            } else {
                HomeView()
            }
        }
    }
}
