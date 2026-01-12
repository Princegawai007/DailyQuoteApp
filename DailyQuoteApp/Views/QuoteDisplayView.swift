//
//  QuoteDisplayView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import SwiftUI
import UIKit

struct QuoteDisplayView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @State private var currentDate = Date()
    @State private var gradientOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Gradient with animation
            AnimatedGradientView()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top Bar / Header
                    HStack {
                        // Date Indicator
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TODAY")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .tracking(2)
                                .foregroundColor(Color(hex: "#ec1337").opacity(0.8))
                            
                            Text(dateFormatter.string(from: currentDate))
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color.gray.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        // Settings Icon
                        Button(action: {}) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.6))
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.05))
                                )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                    
                    // Main Content: Quote
                    Spacer(minLength: 100)
                    
                    VStack(spacing: 0) {
                        // Quote Icon Decorative
                        Image(systemName: "quote.opening")
                            .font(.system(size: 48))
                            .foregroundColor(Color.gray.opacity(0.2))
                            .padding(.bottom, 24)
                        
                        // Quote Text
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            if #available(iOS 16.0, *) {
                                Text("\"\(viewModel.currentQuote.text)\"")
                                    .font(.system(size: 36, weight: .regular, design: .serif))
                                    .lineSpacing(8)
                                    .tracking(-0.5)
                                    .foregroundColor(Color(hex: "#1b0d10"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        
                        // Separator
                        Rectangle()
                            .fill(Color(hex: "#ec1337").opacity(0.4))
                            .frame(width: 48, height: 1)
                            .padding(.vertical, 32)
                        
                        // Author
                        Text("- \(viewModel.currentQuote.author)")
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                    
                    Spacer(minLength: 100)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
            .refreshable {
                await viewModel.refreshQuote()
            }
            
            VStack {
                Spacer()
                
                // Actions Bar (Bottom)
                HStack {
                    // Share Action
                    VStack(spacing: 8) {
                        Button(action: {
                            shareQuote(viewModel.currentQuote)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "#1b0d10"))
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("Share")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Navigation Pills (Optional Visual Detail)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray.opacity(0.8))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.4))
                    )
                    .opacity(0) // Hidden on small screens as per design
                    
                    Spacer()
                    
                    // Favorite Action
                    VStack(spacing: 8) {
                        Button(action: {
                            viewModel.toggleFavorite(viewModel.currentQuote)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: viewModel.isFavorite(viewModel.currentQuote) ? "heart.fill" : "heart")
                                    .font(.system(size: 24))
                                    .foregroundColor(viewModel.isFavorite(viewModel.currentQuote) ? Color(hex: "#ec1337") : Color(hex: "#1b0d10"))
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("Favorite")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                }
                .padding(.horizontal, 32)
//                .padding(.bottom, 32)
                .padding(.bottom, 100)
                .padding(.top, 16)
            }
        }
        .onAppear {
            // Refresh quote when view appears
            Task {
                await viewModel.refreshQuote()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }
    
    private func shareQuote(_ quote: Quote) {
        let text = "\"\(quote.text)\" - \(quote.author)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AnimatedGradientView: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#FFF5F0"),
                Color(hex: "#FDF2EC"),
                Color(hex: "#FAE8E0")
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 15)
                    .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}
