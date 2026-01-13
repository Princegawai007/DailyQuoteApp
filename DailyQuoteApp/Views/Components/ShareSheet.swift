//
//  ShareSheet.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
// Add this at the bottom of ShareSheet.swift
struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
