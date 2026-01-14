//
//  HomeQuoteCard.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 14/01/26.
//

import SwiftUI

enum QuoteTheme: String, CaseIterable, Identifiable {
    case minimal, midnight, nature
    var id: String { self.rawValue }
    
    // ENSURE THIS NAME MATCHES WHAT YOU CALL IN RENDERVIEW
    var backgroundColors: [Color] {
        switch self {
        case .minimal: return [.white, Color(uiColor: .systemGray6)]
        case .midnight: return [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]
        case .nature: return [Color.green.opacity(0.6), Color.blue.opacity(0.4)]
        }
    }
    
    var textColor: Color {
        self == .minimal ? .black : .white
    }
}


