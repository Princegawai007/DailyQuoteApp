//
//  SettingsView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import SwiftUI
import UserNotifications
internal import Auth

struct SettingsView: View {
    @ObservedObject var authService = AuthService.shared
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var isSavingProfile = false
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    
    // Connected to same storage key
    @AppStorage("fontSize") private var fontSize: Double = 21.0
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = false
    
    @State private var notificationTime: Date = {
        if let saved = UserDefaults.standard.object(forKey: "dailyQuoteTime") as? Date {
            return saved
        }
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                ZStack {
                    AnimatedGradientView()
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // MARK: - SECTION 1: PROFILE
                            VStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primary) // Adaptive Black/White
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    
                                    // Use system background color for text inside the filled circle
                                    Text(getInitials(name: fullName))
                                        .font(.system(.title, design: .serif))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(uiColor: .systemBackground))
                                }
                                .padding(.top, 10)
                                
                                Text(email)
                                    .font(.system(.subheadline, design: .serif))
                                    .foregroundColor(.gray)
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Full Name")
                                        .font(.system(.caption, design: .serif))
                                        .foregroundColor(.gray)
                                        .fontWeight(.medium)
                                    
                                    TextField("Enter Full Name", text: $fullName)
                                        .font(.system(.body, design: .serif))
                                        .padding()
                                        .background(Color(uiColor: .secondarySystemBackground))
                                        .cornerRadius(10)
                                }
                                
                                Button(action: updateProfile) {
                                    HStack {
                                        if isSavingProfile {
                                            ProgressView().tint(Color(uiColor: .systemBackground))
                                        } else {
                                            Text("Save Changes")
                                                .font(.system(.body, design: .serif))
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primary) // Adaptive Black/White
                                    .foregroundColor(Color(uiColor: .systemBackground)) // Text inverse
                                    .cornerRadius(12)
                                }
                                .disabled(fullName.isEmpty || isSavingProfile)
                                .opacity(fullName.isEmpty ? 0.6 : 1.0)
                            }
                            .padding(20)
                            // CHANGED: Uses systemBackground (Black in Dark Mode, White in Light Mode)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            // MARK: - SECTION 2: APPEARANCE
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Appearance")
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(.primary) // Adaptive Text
                                
                                Divider()
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Font Size")
                                            .font(.system(.body, design: .serif))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(Int(fontSize))")
                                            .font(.system(.body, design: .serif))
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary) // Adaptive Text
                                    }
                                    
                                    // Slider adjusts the global fontSize variable
                                    Slider(value: $fontSize, in: 16...40, step: 1)
                                        .tint(.primary) // Adaptive Tint
                                }
                            }
                            .padding(20)
                            // CHANGED: Uses systemBackground (Black in Dark Mode)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            // MARK: - SECTION 3: NOTIFICATIONS
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Notifications")
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(.primary) // Adaptive Text
                                
                                Divider()
                                
                                Toggle("Daily Quote", isOn: $isNotificationsEnabled)
                                    .font(.system(.body, design: .serif))
                                    .tint(.green) // Green looks good in both modes
                                    .onChange(of: isNotificationsEnabled) { enabled in
                                        if enabled {
                                            requestNotificationPermission()
                                            scheduleDailyNotification(at: notificationTime)
                                        } else {
                                            cancelNotifications()
                                        }
                                    }
                                
                                if isNotificationsEnabled {
                                    Divider()
                                    HStack {
                                        Text("Time")
                                            .font(.system(.body, design: .serif))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .onChange(of: notificationTime) { newTime in
                                                scheduleDailyNotification(at: newTime)
                                            }
                                    }
                                }
                            }
                            .padding(20)
                            // CHANGED: Uses systemBackground (Black in Dark Mode)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            // MARK: - SECTION 4: ACCOUNT
                            VStack(spacing: 0) {
                                Button(action: {
                                    Task { try? await authService.signOut() }
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Sign Out")
                                            .font(.system(.body, design: .serif))
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                }
                            }
                            // CHANGED: Uses systemBackground (Black in Dark Mode)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .onAppear(perform: loadUserData)
                .alert(isPresented: $showSaveAlert) {
                    Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            } else {
                Text("Requires iOS 16+")
            }
        }
    }
    
    // (Logic functions remain exactly the same as before)
    func loadUserData() {
        guard let user = authService.userSession?.user else { return }
        self.email = user.email ?? ""
        let metadata = user.userMetadata
        if let jsonValue = metadata["full_name"], case .string(let storedName) = jsonValue {
            self.fullName = storedName
        }
    }
    
    func updateProfile() {
        isSavingProfile = true
        Task {
            do {
                try await authService.updateUserFullName(fullName)
                alertMessage = "Name updated successfully!"
                showSaveAlert = true
            } catch {
                alertMessage = "Failed: \(error.localizedDescription)"
                showSaveAlert = true
            }
            isSavingProfile = false
        }
    }
    
    func getInitials(name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "U" }
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: trimmed) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        let parts = trimmed.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if parts.count >= 2, let first = parts.first, let last = parts.last {
            return "\(first.prefix(1))\(last.prefix(1))".uppercased()
        }
        return String(trimmed.prefix(1)).uppercased()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async { scheduleDailyNotification(at: notificationTime) }
            } else {
                DispatchQueue.main.async { isNotificationsEnabled = false }
            }
        }
    }
    
    func scheduleDailyNotification(at date: Date) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let content = UNMutableNotificationContent()
        content.title = "Daily Wisdom"
        content.body = "Your daily quote is ready."
        content.sound = .default
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
        UserDefaults.standard.set(date, forKey: "dailyQuoteTime")
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
