//
//  QuoteWidget.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 14/01/26.

import WidgetKit
import SwiftUI
import Supabase

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: WidgetQuote(content: "The conviction that we are loved.", author: "Victor Hugo"), theme: .classic)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Preview Quote", author: "Author"), theme: .classic)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                // 1. Fetch the exact same pool of quotes as the app
                let allQuotes: [WidgetQuote] = try await supabase
                    .from("quotes")
                    .select("content, author")
                    .execute()
                    .value
                
                if !allQuotes.isEmpty {
                    // 2. Use the EXACT same index logic as your ViewModel
                    let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
                    let index = dayOfYear % allQuotes.count
                    let quoteToShow = allQuotes[index]
                    
                    // 3. Create the entry with the synced quote
                    let entry = SimpleEntry(date: Date(), quote: quoteToShow, theme: .classic)
                    
                    // Refresh exactly at midnight to stay in sync
                    let nextUpdate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
                    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
                }
            } catch {
                let errorEntry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Refresh for today's wisdom.", author: "Daily Quote"), theme: .classic)
                completion(Timeline(entries: [errorEntry], policy: .after(Date().addingTimeInterval(3600))))
            }
        }
    }
}

// 2. Define Theme Properties
enum WidgetTheme {
    case classic, midnight, nature
    
    var textColor: Color {
        self == .classic ? Color(red: 0.06, green: 0.13, blue: 0.10) : .white
    }
    
    var accentColor: Color {
        self == .nature ? .white : Color(red: 0.07, green: 0.93, blue: 0.57)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: WidgetQuote
    let theme: WidgetTheme
}

struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack(alignment: .leading, spacing: 4) { // Reduced spacing
                Image(systemName: "quote.opening")
                    .foregroundColor(entry.theme.accentColor)
                    .font(.system(size: 10)) // Smaller icon
                
                Text(entry.quote.content)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(entry.theme.textColor)
                    .minimumScaleFactor(0.5) // 👈 Allows the font to shrink to fit the whole quote
                    .lineLimit(6)            // 👈 Allows more lines than the default
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 2)
                
                Text("- \(entry.quote.author)")
                    .font(.system(size: 10, weight: .bold)) // Smaller author text
                    .foregroundColor(entry.theme.textColor.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(12) // Slightly smaller padding to give text more room
            .containerBackground(for: .widget) {
                // ... your existing background code ...
            }
        }
    }
}

@main
struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Your daily dose of wisdom.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
