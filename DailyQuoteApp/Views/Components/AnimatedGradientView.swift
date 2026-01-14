//
//  AnimatedGradientView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import SwiftUI

struct AnimatedGradientView: View {
    @State private var animateGradient = false
    @Environment(\.colorScheme) var colorScheme // Auto-detect Dark Mode
    
    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [Color.black, Color(red: 0.1, green: 0.1, blue: 0.1)]
            : [Color(red: 1.0, green: 0.96, blue: 0.94), // #FFF5F0
               Color(red: 0.99, green: 0.95, blue: 0.93), // #FDF2EC
               Color(red: 0.98, green: 0.91, blue: 0.88)], // #FAE8E0
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
