//
//  DailyQuoteAppApp.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.

import SwiftUI

@main
struct DailyQuoteAppApp: App {
    @StateObject private var authService = AuthService.shared
    
    // State to trigger the alert
    @State private var showResetNotImplementedAlert = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.userSession != nil {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            // 1. Catch the Deep Link
            .onOpenURL { url in
                print("App opened via URL: \(url)")
                
                // 2. Trigger the Alert immediately
                showResetNotImplementedAlert = true
            }
            // 3. Show the Alert
            .alert("Reset Password", isPresented: $showResetNotImplementedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Password reset functionality is currently under development.")
            }
        }
    }
}
