//
//  SharePreviewView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 14/01/26.
//

import SwiftUI

struct SharePreviewView: View {
    let quote: Quote
    @State private var selectedTheme: QuoteTheme = .minimal
    @Environment(\.dismiss) var dismiss
    @Binding var shareItem: ShareableImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // The Visual Preview
                renderView(for: quote, theme: selectedTheme)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .scaleEffect(0.7) // Scale down to fit screen
                    .frame(height: 350)
                
                // Theme Selector
                // --- THE THEME PICKER ---
                HStack(spacing: 25) {
                    // REMOVE THE $ FROM QuoteTheme.allCases
                    ForEach(QuoteTheme.allCases) { theme in
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            selectedTheme = theme
                        }) {
                            Circle()
                            // Use theme directly, not $theme
                                .fill(LinearGradient(colors: theme.backgroundColors, startPoint: .top, endPoint: .bottom))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedTheme == theme ? 3 : 0)
                                        .padding(-4)
                                )
                        }
                    }
                }
                
                Button(action: { if #available(iOS 16.0, *) {
                    generateImage()
                } else {
                    // Fallback on earlier versions
                } }) {
                    Text("Share Image")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .navigationTitle("Pick a Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    @available(iOS 16.0, *)
    @MainActor
    private func generateImage() {
        let renderer = ImageRenderer(content: renderView(for: quote, theme: selectedTheme))
        renderer.scale = 3.0 // High quality
        if let image = renderer.uiImage {
            self.shareItem = ShareableImage(image: image)
            dismiss()
        }
    }
    
    // Reuse your renderView logic here
    private func renderView(for quote: Quote, theme: QuoteTheme) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.opening").font(.largeTitle)
            Text("“\(quote.content)”")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
            Text("- \(quote.author)").font(.headline).italic()
        }
        .padding(40)
        .frame(width: 400, height: 500)
        .foregroundColor(theme.textColor)
        .background(LinearGradient(colors: theme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
