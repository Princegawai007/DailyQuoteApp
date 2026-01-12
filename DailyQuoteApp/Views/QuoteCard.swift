//
//  QuoteCard.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import SwiftUI

struct QuoteCard: View {
    let quote: Quote
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Favorite button
            HStack {
                Spacer()
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? Color(hex: "#13ec92") : Color.gray.opacity(0.3))
                        .font(.system(size: 20))
                }
            }
            .padding(.top, 8)
            .padding(.trailing, 24)
            
            // Quote text with decorative quote mark
            ZStack(alignment: .topLeading) {
                Text("\"")
                    .font(.system(size: 48, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "#13ec92").opacity(0.2))
                    .offset(x: -12, y: -16)
                
                Text(quote.text)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#0d1b16"))
                    .lineSpacing(8)
                    .padding(.leading, 8)
                    .padding(.trailing, 32)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            
            // Author section
            Divider()
                .background(Color.gray.opacity(0.1))
                .padding(.top, 16)
            
            HStack {
                // Author avatar
                Circle()
                    .fill(Color(hex: "#13ec92").opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(initials(from: quote.author))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "#13ec92"))
                    )
                
                Text(quote.author)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.5))
                
                Spacer()
                
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Color.gray.opacity(0.4))
                        .font(.system(size: 20))
                }
            }
            .padding(.top, 16)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
        )
    }
    
    private func initials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        } else if !components.isEmpty {
            return String(components[0].prefix(2))
        }
        return "??"
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
