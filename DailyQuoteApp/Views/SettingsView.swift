//
//  SettingsView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//
//import SwiftUI
//import UserNotifications
//internal import Auth
//
//struct SettingsView: View {
//    // Services
//    @ObservedObject var authService = AuthService.shared
//    
//    // 1. Profile State
//    @State private var fullName: String = ""
//    @State private var email: String = ""
//    @State private var isSavingProfile = false
//    @State private var showSaveAlert = false
//    @State private var alertMessage = ""
//    
//    // 2. App Settings State (Local)
//    @AppStorage("fontSize") private var fontSize: Double = 36.0
//    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = false
//    
//    // Default to 9:00 AM
//    @State private var notificationTime: Date = {
//        if let saved = UserDefaults.standard.object(forKey: "dailyQuoteTime") as? Date {
//            return saved
//        }
//        var components = DateComponents()
//        components.hour = 9
//        components.minute = 0
//        return Calendar.current.date(from: components) ?? Date()
//    }()
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                // MARK: - SECTION 1: PROFILE
//                Section(header: Text("Profile")) {
//                    // Header with Avatar
//                    HStack {
//                        Spacer()
//                        VStack(spacing: 10) {
//                            ZStack {
//                                Circle()
//                                    .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
//                                    .frame(width: 70, height: 70)
//                                
//                                Text(getInitials(name: fullName))
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.white)
//                            }
//                            
//                            Text(email)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                    }
//                    .listRowBackground(Color.clear) // Transparent background for avatar
//                    .padding(.bottom, 10)
//                    
//                    // Name Input
//                    TextField("Enter Full Name", text: $fullName)
//                        .textContentType(.name)
//                    
//                    // Save Button
//                    if !fullName.isEmpty {
//                        Button(action: updateProfile) {
//                            if isSavingProfile {
//                                ProgressView()
//                            } else {
//                                Text("Update Name")
//                                    .foregroundColor(.accentColor)
//                            }
//                        }
//                    }
//                }
//                
//                // MARK: - SECTION 2: APPEARANCE
//                Section(header: Text("Appearance")) {
//                    VStack(alignment: .leading) {
//                        Text("Font Size: \(Int(fontSize))")
//                        Slider(value: $fontSize, in: 20...50, step: 1)
//                    }
//                    .padding(.vertical, 4)
//                }
//                
//                // MARK: - SECTION 3: NOTIFICATIONS
//                Section(header: Text("Notifications")) {
//                    Toggle("Daily Quote Notification", isOn: $isNotificationsEnabled)
//                        .onChange(of: isNotificationsEnabled) { enabled in
//                            if enabled {
//                                requestNotificationPermission()
//                                scheduleDailyNotification(at: notificationTime)
//                            } else {
//                                cancelNotifications()
//                            }
//                        }
//                    
//                    if isNotificationsEnabled {
//                        DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
//                            .onChange(of: notificationTime) { newTime in
//                                scheduleDailyNotification(at: newTime)
//                            }
//                    }
//                }
//                
//                // MARK: - SECTION 4: ACCOUNT
//                Section {
//                    Button(action: {
//                        Task { try? await authService.signOut() }
//                    }) {
//                        Text("Sign Out")
//                            .foregroundColor(.red)
//                    }
//                }
//            }
//            .navigationTitle("Settings")
//            .onAppear(perform: loadUserData)
//            .alert(isPresented: $showSaveAlert) {
//                Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//    
//    // MARK: - Profile Logic
//    
//    func loadUserData() {
//        guard let user = authService.userSession?.user else { return }
//        self.email = user.email ?? ""
//        
//        let metadata = user.userMetadata
//        if let jsonValue = metadata["full_name"],
//           case .string(let storedName) = jsonValue {
//            self.fullName = storedName
//        }
//    }
//    
//    func updateProfile() {
//        isSavingProfile = true
//        Task {
//            do {
//                try await authService.updateUserFullName(fullName)
//                alertMessage = "Name updated successfully!"
//                showSaveAlert = true
//            } catch {
//                alertMessage = "Failed: \(error.localizedDescription)"
//                showSaveAlert = true
//            }
//            isSavingProfile = false
//        }
//    }
//    
//    // MARK: - Helper for Initials
//        func getInitials(name: String) -> String {
//            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
//            if trimmed.isEmpty { return "U" }
//            
//            // 1. Use Apple's built-in formatter to handle names intelligently
//            let formatter = PersonNameComponentsFormatter()
//            if let components = formatter.personNameComponents(from: trimmed) {
//                formatter.style = .abbreviated
//                return formatter.string(from: components)
//            }
//            
//            // 2. Fallback: Split by spaces manually if formatter fails
//            let parts = trimmed.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
//            if parts.count >= 2, let first = parts.first, let last = parts.last {
//                return "\(first.prefix(1))\(last.prefix(1))".uppercased()
//            }
//            
//            // 3. Last Resort: Just the first letter
//            return String(trimmed.prefix(1)).uppercased()
//        }
//    
//    // MARK: - Notification Logic (Same as before)
//    
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                DispatchQueue.main.async {
//                    scheduleDailyNotification(at: notificationTime)
//                }
//            } else {
//                DispatchQueue.main.async { isNotificationsEnabled = false }
//            }
//        }
//    }
//    
//    func scheduleDailyNotification(at date: Date) {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        let content = UNMutableNotificationContent()
//        content.title = "Daily Wisdom"
//        content.body = "Your daily quote is ready."
//        content.sound = .default
//        
//        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
//        
//        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { _ in }
//        
//        UserDefaults.standard.set(date, forKey: "dailyQuoteTime")
//    }
//    
//    func cancelNotifications() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//    }
//}



//MARK: THIS CODE IS WORKING FINE


//import SwiftUI
//import UserNotifications
//internal import Auth
//
//struct SettingsView: View {
//    // Services
//    @ObservedObject var authService = AuthService.shared
//    
//    // 1. Profile State
//    @State private var fullName: String = ""
//    @State private var email: String = ""
//    @State private var isSavingProfile = false
//    @State private var showSaveAlert = false
//    @State private var alertMessage = ""
//    
//    // 2. App Settings State (Local)
//    @AppStorage("fontSize") private var fontSize: Double = 36.0
//    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = false
//    
//    // Default to 9:00 AM
//    @State private var notificationTime: Date = {
//        if let saved = UserDefaults.standard.object(forKey: "dailyQuoteTime") as? Date {
//            return saved
//        }
//        var components = DateComponents()
//        components.hour = 9
//        components.minute = 0
//        return Calendar.current.date(from: components) ?? Date()
//    }()
//    
//    var body: some View {
//        NavigationView {
//            if #available(iOS 16.0, *) {
//                ZStack {
//                    // 1. Unified Gradient Background
//                    AnimatedGradientView()
//                        .ignoresSafeArea()
//                    
//                    ScrollView {
//                        VStack(spacing: 20) {
//                            
//                            // MARK: - SECTION 1: PROFILE CARD
//                            VStack(spacing: 15) {
//                                // Avatar
//                                ZStack {
//                                    Circle()
//                                        .fill(Color.black)
//                                        .frame(width: 80, height: 80)
//                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//                                    
//                                    Text(getInitials(name: fullName))
//                                        .font(.title)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.white)
//                                }
//                                .padding(.top, 10)
//                                
//                                // Email Display
//                                Text(email)
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                                
//                                Divider()
//                                
//                                // Name Edit Field
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text("Full Name")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                        .fontWeight(.medium)
//                                    
//                                    TextField("Enter Full Name", text: $fullName)
//                                        .padding()
//                                        .background(Color(uiColor: .secondarySystemBackground))
//                                        .cornerRadius(10)
//                                }
//                                
//                                // Save Button
//                                Button(action: updateProfile) {
//                                    HStack {
//                                        if isSavingProfile {
//                                            ProgressView()
//                                                .tint(.white)
//                                        } else {
//                                            Text("Save Changes")
//                                                .fontWeight(.semibold)
//                                        }
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(Color.black)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(12)
//                                }
//                                .disabled(fullName.isEmpty || isSavingProfile)
//                                .opacity(fullName.isEmpty ? 0.6 : 1.0)
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // MARK: - SECTION 2: APPEARANCE CARD
//                            VStack(alignment: .leading, spacing: 15) {
//                                Text("Appearance")
//                                    .font(.headline)
//                                    .foregroundColor(.black)
//                                
//                                Divider()
//                                
//                                VStack(alignment: .leading) {
//                                    HStack {
//                                        Text("Font Size")
//                                            .foregroundColor(.gray)
//                                        Spacer()
//                                        Text("\(Int(fontSize))")
//                                            .fontWeight(.bold)
//                                            .foregroundColor(.black)
//                                    }
//                                    
//                                    Slider(value: $fontSize, in: 20...50, step: 1)
//                                        .accentColor(.black)
//                                }
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // MARK: - SECTION 3: NOTIFICATIONS CARD
//                            VStack(alignment: .leading, spacing: 15) {
//                                Text("Notifications")
//                                    .font(.headline)
//                                    .foregroundColor(.black)
//                                
//                                Divider()
//                                
//                                Toggle("Daily Quote", isOn: $isNotificationsEnabled)
//                                    .toggleStyle(SwitchToggleStyle(tint: .black))
//                                    .onChange(of: isNotificationsEnabled) { enabled in
//                                        if enabled {
//                                            requestNotificationPermission()
//                                            scheduleDailyNotification(at: notificationTime)
//                                        } else {
//                                            cancelNotifications()
//                                        }
//                                    }
//                                
//                                if isNotificationsEnabled {
//                                    Divider()
//                                    HStack {
//                                        Text("Time")
//                                            .foregroundColor(.gray)
//                                        Spacer()
//                                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
//                                            .labelsHidden()
//                                            .onChange(of: notificationTime) { newTime in
//                                                scheduleDailyNotification(at: newTime)
//                                            }
//                                    }
//                                }
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // MARK: - SECTION 4: ACCOUNT CARD
//                            VStack(spacing: 0) {
//                                Button(action: {
//                                    Task { try? await authService.signOut() }
//                                }) {
//                                    HStack {
//                                        Image(systemName: "rectangle.portrait.and.arrow.right")
//                                        Text("Sign Out")
//                                            .fontWeight(.medium)
//                                    }
//                                    .foregroundColor(.red)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .padding()
//                                }
//                            }
//                            .background(Color.white)
//                            .cornerRadius(16)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // Bottom Padding for Tab Bar
//                            Spacer(minLength: 40)
//                        }
//                        .padding()
//                    }
//                }
//                .navigationTitle("Settings")
//                .navigationBarTitleDisplayMode(.inline)
//                // Hide default nav background to let gradient show
//                .toolbarBackground(.hidden, for: .navigationBar)
//                .onAppear(perform: loadUserData)
//                .alert(isPresented: $showSaveAlert) {
//                    Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//                }
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//    
//    // MARK: - Profile Logic (Unchanged)
//    
//    func loadUserData() {
//        guard let user = authService.userSession?.user else { return }
//        self.email = user.email ?? ""
//        
//        let metadata = user.userMetadata
//        if let jsonValue = metadata["full_name"],
//           case .string(let storedName) = jsonValue {
//            self.fullName = storedName
//        }
//    }
//    
//    func updateProfile() {
//        isSavingProfile = true
//        Task {
//            do {
//                try await authService.updateUserFullName(fullName)
//                alertMessage = "Name updated successfully!"
//                showSaveAlert = true
//            } catch {
//                alertMessage = "Failed: \(error.localizedDescription)"
//                showSaveAlert = true
//            }
//            isSavingProfile = false
//        }
//    }
//    
//    func getInitials(name: String) -> String {
//        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        if trimmed.isEmpty { return "U" }
//        
//        let formatter = PersonNameComponentsFormatter()
//        if let components = formatter.personNameComponents(from: trimmed) {
//            formatter.style = .abbreviated
//            return formatter.string(from: components)
//        }
//        
//        let parts = trimmed.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
//        if parts.count >= 2, let first = parts.first, let last = parts.last {
//            return "\(first.prefix(1))\(last.prefix(1))".uppercased()
//        }
//        return String(trimmed.prefix(1)).uppercased()
//    }
//    
//    // MARK: - Notification Logic (Unchanged)
//    
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                DispatchQueue.main.async {
//                    scheduleDailyNotification(at: notificationTime)
//                }
//            } else {
//                DispatchQueue.main.async { isNotificationsEnabled = false }
//            }
//        }
//    }
//    
//    func scheduleDailyNotification(at date: Date) {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        let content = UNMutableNotificationContent()
//        content.title = "Daily Wisdom"
//        content.body = "Your daily quote is ready."
//        content.sound = .default
//        
//        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
//        
//        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { _ in }
//        
//        UserDefaults.standard.set(date, forKey: "dailyQuoteTime")
//    }
//    
//    func cancelNotifications() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//    }
//}

//MARK: ABOVE CODE IS WORKING FINE

//
//import SwiftUI
//import UserNotifications
//internal import Auth
//
//struct SettingsView: View {
//    @ObservedObject var authService = AuthService.shared
//    
//    @State private var fullName: String = ""
//    @State private var email: String = ""
//    @State private var isSavingProfile = false
//    @State private var showSaveAlert = false
//    @State private var alertMessage = ""
//    
//    // Connected to same storage key
//    @AppStorage("fontSize") private var fontSize: Double = 21.0
//    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = false
//    
//    @State private var notificationTime: Date = {
//        if let saved = UserDefaults.standard.object(forKey: "dailyQuoteTime") as? Date {
//            return saved
//        }
//        var components = DateComponents()
//        components.hour = 9
//        components.minute = 0
//        return Calendar.current.date(from: components) ?? Date()
//    }()
//    
//    var body: some View {
//        NavigationView {
//            if #available(iOS 16.0, *) {
//                ZStack {
//                    AnimatedGradientView()
//                        .ignoresSafeArea()
//                    
//                    ScrollView {
//                        VStack(spacing: 20) {
//                            
//                            // MARK: - SECTION 1: PROFILE
//                            VStack(spacing: 15) {
//                                ZStack {
//                                    Circle()
//                                        .fill(Color.black)
//                                        .frame(width: 80, height: 80)
//                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//                                    
//                                    Text(getInitials(name: fullName))
//                                        .font(.system(.title, design: .serif)) // Serif
//                                        .fontWeight(.bold)
//                                        .foregroundColor(.white)
//                                }
//                                .padding(.top, 10)
//                                
//                                Text(email)
//                                    .font(.system(.subheadline, design: .serif)) // Serif
//                                    .foregroundColor(.gray)
//                                
//                                Divider()
//                                
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text("Full Name")
//                                        .font(.system(.caption, design: .serif)) // Serif
//                                        .foregroundColor(.gray)
//                                        .fontWeight(.medium)
//                                    
//                                    TextField("Enter Full Name", text: $fullName)
//                                        .font(.system(.body, design: .serif)) // Serif Input
//                                        .padding()
//                                        .background(Color(uiColor: .secondarySystemBackground))
//                                        .cornerRadius(10)
//                                }
//                                
//                                Button(action: updateProfile) {
//                                    HStack {
//                                        if isSavingProfile {
//                                            ProgressView().tint(.white)
//                                        } else {
//                                            Text("Save Changes")
//                                                .font(.system(.body, design: .serif)) // Serif
//                                                .fontWeight(.semibold)
//                                        }
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(Color.black)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(12)
//                                }
//                                .disabled(fullName.isEmpty || isSavingProfile)
//                                .opacity(fullName.isEmpty ? 0.6 : 1.0)
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // MARK: - SECTION 2: APPEARANCE
//                            VStack(alignment: .leading, spacing: 15) {
//                                Text("Appearance")
//                                    .font(.system(.headline, design: .serif)) // Serif
//                                    .foregroundColor(.black)
//                                
//                                Divider()
//                                
//                                VStack(alignment: .leading) {
//                                    HStack {
//                                        Text("Font Size")
//                                            .font(.system(.body, design: .serif)) // Serif
//                                            .foregroundColor(.gray)
//                                        Spacer()
//                                        Text("\(Int(fontSize))")
//                                            .font(.system(.body, design: .serif)) // Serif
//                                            .fontWeight(.bold)
//                                            .foregroundColor(.black)
//                                    }
//                                    
//                                    // Slider adjusts the global fontSize variable
//                                    Slider(value: $fontSize, in: 16...40, step: 1)
//                                        .accentColor(.black)
//                                }
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // MARK: - SECTION 3: NOTIFICATIONS
//                            VStack(alignment: .leading, spacing: 15) {
//                                Text("Notifications")
//                                    .font(.system(.headline, design: .serif)) // Serif
//                                    .foregroundColor(.black)
//                                
//                                Divider()
//                                
//                                Toggle("Daily Quote", isOn: $isNotificationsEnabled)
//                                    .font(.system(.body, design: .serif)) // Serif
//                                    .toggleStyle(SwitchToggleStyle(tint: .black))
//                                    .onChange(of: isNotificationsEnabled) { enabled in
//                                        if enabled {
//                                            requestNotificationPermission()
//                                            scheduleDailyNotification(at: notificationTime)
//                                        } else {
//                                            cancelNotifications()
//                                        }
//                                    }
//                                
//                                if isNotificationsEnabled {
//                                    Divider()
//                                    HStack {
//                                        Text("Time")
//                                            .font(.system(.body, design: .serif)) // Serif
//                                            .foregroundColor(.gray)
//                                        Spacer()
//                                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
//                                            .labelsHidden()
//                                            .onChange(of: notificationTime) { newTime in
//                                                scheduleDailyNotification(at: newTime)
//                                            }
//                                    }
//                                }
//                            }
//                            .padding(20)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            // MARK: - SECTION 4: ACCOUNT
//                            VStack(spacing: 0) {
//                                Button(action: {
//                                    Task { try? await authService.signOut() }
//                                }) {
//                                    HStack {
//                                        Image(systemName: "rectangle.portrait.and.arrow.right")
//                                        Text("Sign Out")
//                                            .font(.system(.body, design: .serif)) // Serif
//                                            .fontWeight(.medium)
//                                    }
//                                    .foregroundColor(.red)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .padding()
//                                }
//                            }
//                            .background(Color.white)
//                            .cornerRadius(16)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            
//                            Spacer(minLength: 40)
//                        }
//                        .padding()
//                    }
//                }
//                .navigationTitle("Settings")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbarBackground(.hidden, for: .navigationBar)
//                .onAppear(perform: loadUserData)
//                .alert(isPresented: $showSaveAlert) {
//                    Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//                }
//            } else {
//                Text("Requires iOS 16+")
//            }
//        }
//    }
//    
//    // (Logic functions remain exactly the same as before)
//    func loadUserData() {
//        guard let user = authService.userSession?.user else { return }
//        self.email = user.email ?? ""
//        let metadata = user.userMetadata
//        if let jsonValue = metadata["full_name"], case .string(let storedName) = jsonValue {
//            self.fullName = storedName
//        }
//    }
//    
//    func updateProfile() {
//        isSavingProfile = true
//        Task {
//            do {
//                try await authService.updateUserFullName(fullName)
//                alertMessage = "Name updated successfully!"
//                showSaveAlert = true
//            } catch {
//                alertMessage = "Failed: \(error.localizedDescription)"
//                showSaveAlert = true
//            }
//            isSavingProfile = false
//        }
//    }
//    
//    func getInitials(name: String) -> String {
//        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        if trimmed.isEmpty { return "U" }
//        let formatter = PersonNameComponentsFormatter()
//        if let components = formatter.personNameComponents(from: trimmed) {
//            formatter.style = .abbreviated
//            return formatter.string(from: components)
//        }
//        let parts = trimmed.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
//        if parts.count >= 2, let first = parts.first, let last = parts.last {
//            return "\(first.prefix(1))\(last.prefix(1))".uppercased()
//        }
//        return String(trimmed.prefix(1)).uppercased()
//    }
//    
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                DispatchQueue.main.async { scheduleDailyNotification(at: notificationTime) }
//            } else {
//                DispatchQueue.main.async { isNotificationsEnabled = false }
//            }
//        }
//    }
//    
//    func scheduleDailyNotification(at date: Date) {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        let content = UNMutableNotificationContent()
//        content.title = "Daily Wisdom"
//        content.body = "Your daily quote is ready."
//        content.sound = .default
//        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
//        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { _ in }
//        UserDefaults.standard.set(date, forKey: "dailyQuoteTime")
//    }
//    
//    func cancelNotifications() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//    }
//}

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
