//
//  LoginView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

//import SwiftUI
//
//struct LoginView: View {
//    @StateObject private var authService = AuthService.shared
//    @State private var email = ""
//    @State private var password = ""
//    @State private var errorMessage: String?
//    @State private var isLoading = false
//    @State private var isSignUp = false // Toggle between Login and Sign Up
//    
//    var body: some View {
//        ZStack {
//            // Background
//            Color(hex: "#f6f8f7").ignoresSafeArea()
//            
//            VStack(spacing: 24) {
//                // Logo / Title
//                VStack(spacing: 12) {
//                    Image(systemName: "quote.bubble.fill")
//                        .font(.system(size: 60))
//                        .foregroundColor(Color(hex: "#13ec92"))
//                    
//                    Text("QuoteVault")
//                        .font(.system(size: 32, weight: .bold))
//                        .foregroundColor(Color(hex: "#10221a"))
//                    
//                    Text("Daily wisdom, collected.")
//                        .foregroundColor(.gray)
//                }
//                .padding(.bottom, 32)
//                
//                // Fields
//                VStack(spacing: 16) {
//                    TextField("Email", text: $email)
//                        .textContentType(.emailAddress)
//                        .autocapitalization(.none)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
//                    
//                    SecureField("Password", text: $password)
//                        .textContentType(.password)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
//                }
//                .padding(.horizontal)
//                
//                // Error Message
//                if let error = errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//                
//                // Action Button
//                Button(action: handleAuthAction) {
//                    if isLoading {
//                        ProgressView()
//                            .tint(.white)
//                    } else {
//                        Text(isSignUp ? "Create Account" : "Sign In")
//                            .fontWeight(.bold)
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//                .padding()
//                .background(Color(hex: "#10221a"))
//                .foregroundColor(.white)
//                .cornerRadius(12)
//                .padding(.horizontal)
//                
//                // Toggle Mode
//                Button(action: { isSignUp.toggle() }) {
//                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
//                        .foregroundColor(.gray)
//                        .font(.subheadline)
//                }
//            }
//            .padding()
//        }
//    }
//    
//    func handleAuthAction() {
//        isLoading = true
//        errorMessage = nil
//        
//        Task {
//            do {
//                if isSignUp {
//                    try await authService.signUp(email: email, password: password)
//                    // Auto sign-in after sign up logic can go here if Supabase doesn't auto-session
//                    // For now, we assume successful signup allows login
//                    errorMessage = "Account created! Please sign in."
//                    isSignUp = false
//                } else {
//                    try await authService.signIn(email: email, password: password)
//                }
//            } catch {
//                errorMessage = error.localizedDescription
//            }
//            isLoading = false
//        }
//    }
//}
import SwiftUI

struct LoginView: View {
    // Input State
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = "" // 🆕 Added Name Field
    
    // Visibility State
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    // Mode State
    @State private var isSignUp = false
    
    // UI Feedback
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    // Forgot Password State
    @State private var showForgotPassword = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
                .onTapGesture { hideKeyboard() }
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    Spacer(minLength: 60)
                    
                    // Logo
                    VStack(spacing: 15) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.accentColor)
                        
                        Text("QuoteVault")
                            .font(.system(size: 40, weight: .heavy, design: .serif))
                            .foregroundColor(.primary)
                        
                        Text(isSignUp ? "Create an account" : "Welcome back")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 30)
                    
                    // Inputs
                    VStack(spacing: 20) {
                        
                        // 🆕 Full Name Field (Only in Sign Up Mode)
                        if isSignUp {
                            TextField("Full Name (e.g. Rahul Sharma)", text: $fullName)
                                .textContentType(.name)
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                                .foregroundColor(.primary)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Email Field
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                        
                        // Password Field
                        VStack(spacing: 5) {
                            HStack {
                                if showPassword {
                                    TextField("Password", text: $password).autocapitalization(.none)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            
                            if !isSignUp {
                                Button(action: { showForgotPassword = true }) {
                                    Text("Forgot Password?")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.top, 5)
                            }
                        }
                        
                        // Confirm Password (Sign Up Only)
                        if isSignUp {
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm Password", text: $confirmPassword).autocapitalization(.none)
                                } else {
                                    SecureField("Confirm Password", text: $confirmPassword)
                                }
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Action Button
                    Button(action: handleAction) {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isSignUp ? "Sign Up" : "Log In")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    // Toggle Mode Button
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            errorMessage = nil
                            password = ""
                            confirmPassword = ""
                        }
                    }) {
                        HStack {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.secondary)
                            Text(isSignUp ? "Log In" : "Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Account Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                withAnimation {
                    isSignUp = false
                    password = ""
                    confirmPassword = ""
                    fullName = ""
                }
            }
        } message: {
            Text("Your account has been created successfully. Please log in.")
        }
    }
    
    // MARK: - Logic
    
    func handleAction() {
        hideKeyboard()
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        if isSignUp {
            if fullName.isEmpty {
                errorMessage = "Please enter your full name."
                return
            }
            if password != confirmPassword {
                errorMessage = "Passwords do not match."
                return
            }
        }
        
        isLoading = true
        
        Task {
            do {
                if isSignUp {
                    // 🆕 Pass fullName to the updated signUp function
                    try await AuthService.shared.signUp(email: email, password: password, fullName: fullName)
                    showSuccessAlert = true
                } else {
                    try await AuthService.shared.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
