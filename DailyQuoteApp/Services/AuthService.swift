//
//  AuthService.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import Foundation
import Supabase
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published var userSession: Session?
    
    init() {
        // Check if user is already logged in when app starts
        Task {
            do {
                self.userSession = try await supabase.auth.session
            } catch {
                print("No session found")
            }
        }
    }
    
    // Sign Up Function
    
    func signUp(email: String, password: String, fullName: String) async throws {
        // Create the metadata dictionary
        let metadata: [String: AnyJSON] = ["full_name": .string(fullName)]
        
        try await supabase.auth.signUp(
            email: email,
            password: password,
            data: metadata
        )
    }
    
    // Sign In Function
    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        await MainActor.run {
            self.userSession = session
        }
    }
    
    // Sign Out Function
    func signOut() async throws {
        try await supabase.auth.signOut()
        await MainActor.run {
            self.userSession = nil
        }
    }
    func sendPasswordReset(email: String) async throws {
        // This triggers the standard Supabase reset email
        try await supabase.auth.resetPasswordForEmail(email)
    }
    func handleIncomingURL(_ url: URL) async throws {
        // This passes the deep link (password reset/email confirm) to Supabase
        try await supabase.auth.session(from: url)
    }
    
    func updateUserFullName(_ name: String) async throws {
        let updates = UserAttributes(data: ["full_name": .string(name)])
        
        // FIX: Use 'update' instead of 'updateUser'
        try await supabase.auth.update(user: updates)
    }
}
