//
//  QuoteWidget.swift
//  QuoteWidget
//
//  Created by Prince Gawai on 13/01/26.
//

//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), emoji: "😀")
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), emoji: "😀")
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, emoji: "😀")
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//
////    func relevances() async -> WidgetRelevances<Void> {
////        // Generate a list containing the contexts this widget is relevant in.
////    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let emoji: String
//}
//
//struct QuoteWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            Text("Time:")
//            Text(entry.date, style: .time)
//
//            Text("Emoji:")
//            Text(entry.emoji)
//        }
//    }
//}
//
//struct QuoteWidget: Widget {
//    let kind: String = "QuoteWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            if #available(iOS 17.0, *) {
//                QuoteWidgetEntryView(entry: entry)
//                    .containerBackground(.fill.tertiary, for: .widget)
//            } else {
//                QuoteWidgetEntryView(entry: entry)
//                    .padding()
//                    .background()
//            }
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//#Preview(as: .systemSmall) {
//    QuoteWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}

import WidgetKit
import SwiftUI
import Supabase

// 1. Config (Same as your main app)
let widgetSupabaseUrl = URL(string: "https://ennmukyueddpkjtaijyv.supabase.co")!
let widgetSupabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVubm11a3l1ZWRkcGtqdGFpanl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyODE4MjksImV4cCI6MjA4Mzg1NzgyOX0.Xm9CTVxkhdaLzdtQMdLjCUC5301JuJEPLEuMVbAsofU" // <--- PASTE YOUR KEY HERE AGAIN
let supabase = SupabaseClient(supabaseURL: widgetSupabaseUrl, supabaseKey: widgetSupabaseKey)

// Model for Widget
struct WidgetQuote: Decodable {
    let content: String
    let author: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: WidgetQuote(content: "Believe you can...", author: "Teddy Roosevelt"))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Preview Quote", author: "Author"))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            // Fetch a random quote for the widget
            do {
                let quotes: [WidgetQuote] = try await supabase
                    .from("quotes")
                    .select("content, author")
                    .limit(10) // Fetch a few to pick one
                    .execute()
                    .value
                
                let randomQuote = quotes.randomElement() ?? WidgetQuote(content: "Stay hungry, stay foolish", author: "Steve Jobs")
                
                let entry = SimpleEntry(date: Date(), quote: randomQuote)
                
                // Refresh widget every 1 hour
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                
                completion(timeline)
            } catch {
                // Fallback on error
                let errorEntry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Could not load quote", author: "Offline"))
                let timeline = Timeline(entries: [errorEntry], policy: .after(Date().addingTimeInterval(60 * 15)))
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: WidgetQuote
}

struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.97) // #f6f8f7
            
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .foregroundColor(Color(red: 0.07, green: 0.93, blue: 0.57)) // #13ec92
                    .font(.caption)
                
                Text(entry.quote.content)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.10)) // #10221a
                    .minimumScaleFactor(0.8)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text("- \(entry.quote.author)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .italic()
            }
            .padding()
        }
    }
}

@main
struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                QuoteWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                QuoteWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Daily Quote")
        .description("Your daily dose of wisdom.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
