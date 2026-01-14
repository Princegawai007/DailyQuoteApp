//
//  ThemeManager.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 14/01/26.
//

import Foundation
import SwiftUI

enum AppAccentColor: String, CaseIterable {
    case green, blue, purple, gold
    
    var color: Color {
        switch self {
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .gold: return Color(hex: "D4AF37")
        }
    }
}
