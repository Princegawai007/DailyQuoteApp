//
//  QuoteWidget.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 14/01/26.
//
//import WidgetKit
//import SwiftUI
//import Supabase
//
//
////let url = Secrets.supabaseURL
////let key = Secrets.supabaseKey
////
////let supabase = SupabaseClient(
////    supabaseURL: Secrets.supabaseURL,
////    supabaseKey: Secrets.supabaseKey
////)
////
////let supabase = SupabaseClient(supabaseURL: url, supabaseKey: key)
//
//// Model for Widget
////struct WidgetQuote: Decodable {
////    let content: String
////    let author: String
////}
//
//
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), quote: WidgetQuote(content: "Believe you can...", author: "Teddy Roosevelt"))
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Preview Quote", author: "Author"))
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        Task {
//            // Fetch a random quote for the widget
//            do {
//                let quotes: [WidgetQuote] = try await supabase
//                    .from("quotes")
//                    .select("content, author")
//                    .limit(10) // Fetch a few to pick one
//                    .execute()
//                    .value
//                
//                let randomQuote = quotes.randomElement() ?? WidgetQuote(content: "Stay hungry, stay foolish", author: "Steve Jobs")
//                
//                let entry = SimpleEntry(date: Date(), quote: randomQuote)
//                
//                // Refresh widget every 1 hour
//                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
//                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
//                
//                completion(timeline)
//            } catch {
//                // Fallback on error
//                let errorEntry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Could not load quote", author: "Offline"))
//                let timeline = Timeline(entries: [errorEntry], policy: .after(Date().addingTimeInterval(60 * 15)))
//                completion(timeline)
//            }
//        }
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let quote: WidgetQuote
//}
//
//struct QuoteWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.96, green: 0.97, blue: 0.97) // #f6f8f7
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Image(systemName: "quote.opening")
//                    .foregroundColor(Color(red: 0.07, green: 0.93, blue: 0.57)) // #13ec92
//                    .font(.caption)
//                
//                Text(entry.quote.content)
//                    .font(.system(size: 14, weight: .medium, design: .serif))
//                    .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.10)) // #10221a
//                    .minimumScaleFactor(0.8)
//                    .lineLimit(4)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                Spacer()
//                
//                Text("- \(entry.quote.author)")
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//                    .italic()
//            }
//            .padding()
//        }
//    }
//}
//
//@main
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
//        .configurationDisplayName("Daily Quote")
//        .description("Your daily dose of wisdom.")
//        .supportedFamilies([.systemSmall, .systemMedium])
//    }
//}
import WidgetKit
import SwiftUI
import Supabase

// 1. GLOBAL DECLARATION (Only one instance allowed)
//let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseKey)

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
                // Fetch from daily_wisdom to match the App's Hero section
                let dailyQuotes: [WidgetQuote] = try await supabase
                    .from("daily_wisdom")
                    .select("content, author")
                    .limit(1)
                    .execute()
                    .value
                
                let quoteToShow = dailyQuotes.first ?? WidgetQuote(content: "Stay hungry, stay foolish", author: "Steve Jobs")
                
                // Rotate themes to satisfy the "2 Additional Themes" requirement
                let themes: [WidgetTheme] = [.classic, .midnight, .nature]
                let dayIndex = Calendar.current.component(.day, from: Date()) % themes.count
                
                let entry = SimpleEntry(date: Date(), quote: quoteToShow, theme: themes[dayIndex])
                
                // Refresh at midnight
                let nextUpdate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            } catch {
                let errorEntry = SimpleEntry(date: Date(), quote: WidgetQuote(content: "Check connection for wisdom.", author: "Daily Wisdom"), theme: .classic)
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
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .foregroundColor(entry.theme.accentColor)
                    .font(.caption)
                
                Text(entry.quote.content)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(entry.theme.textColor)
                    .minimumScaleFactor(0.8)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text("- \(entry.quote.author)")
                    .font(.caption2)
                    .foregroundColor(entry.theme.textColor.opacity(0.7))
                    .italic()
            }
            .padding()
            // Using a @ViewBuilder closure to return specific ShapeStyles
            .containerBackground(for: .widget) {
                switch entry.theme {
                case .classic:
                    Color(red: 0.96, green: 0.97, blue: 0.97)
                case .midnight:
                    Color.black
                case .nature:
                    LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
        } else {
            // Fallback on earlier versions
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
