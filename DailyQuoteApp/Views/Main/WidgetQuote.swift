//
//  WidgetQuote.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 14/01/26.
//

import Foundation

// Model for Widget
struct WidgetQuote: Decodable {
    let content: String
    let author: String
    // Note: If your daily_wisdom table returns a nested 'quotes' object,
    // we may need to adjust the select query below.
}
