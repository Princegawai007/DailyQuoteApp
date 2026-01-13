//
//  ForgotPasswordView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//
import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                    
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Input
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Action Button
                Button(action: sendResetLink) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Reset Link")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isLoading || email.isEmpty)
                
                Spacer()
            }
            .padding()
        }
        .alert("Status", isPresented: $showAlert) {
            Button("OK") {
                if !alertMessage.contains("Error") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    func sendResetLink() {
        isLoading = true
        Task {
            do {
                try await AuthService.shared.sendPasswordReset(email: email)
                alertMessage = "Check your email! We've sent you a password reset link."
                showAlert = true
            } catch {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }
}
