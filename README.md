# QuoteVault - Daily Wisdom iOS App

A native iOS application built with **SwiftUI** and **Supabase** that delivers daily quotes, supports user authentication, and syncs favorites across devices. Built using an AI-assisted workflow.

## 📱 Features
* **Daily Quotes:** Browse a curated collection of wisdom.
* **Cloud Sync:** Favorites are saved to a Postgres database (Supabase) and sync across devices instantly.
* **User Auth:** Secure Login/Sign Up via Email.
* **Home Screen Widget:** View quotes directly from the home screen using WidgetKit.
* **Social Sharing:** Generate beautiful quote cards to share on Instagram/WhatsApp using `ImageRenderer` (iOS 16+).

## 🛠 Tech Stack
* **Frontend:** SwiftUI, WidgetKit, Combine
* **Backend:** Supabase (PostgreSQL, Auth)
* **Architecture:** MVVM (Model-View-ViewModel)

## 🤖 The AI Workflow
This project was built to demonstrate how AI can accelerate native development.
1.  **Architecture Design:** AI helped structure the MVVM pattern and define the Supabase database schema.
2.  **Error Resolution:** Debugged complex "Purple warnings" (Main Thread issues) and Build errors using AI analysis of Xcode logs.
3.  **Code Generation:** Boilerplate for `ImageRenderer` and Supabase `AuthService` was generated to speed up implementation.
4.  **Refinement:** Implemented "Optimistic UI" for the Favorites button to ensure the app feels instant even on slow networks.

## 🚀 How to Run
1.  Clone the repository.
2.  Open `DailyQuoteApp.xcodeproj` in Xcode 15+.
3.  Add your Supabase URL and Key in `SupabaseConfig.swift`.
4.  Run on iPhone Simulator or Device (iOS 16.0+).
