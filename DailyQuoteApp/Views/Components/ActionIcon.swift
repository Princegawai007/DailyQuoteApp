//
//  ActionIcon.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import SwiftUI

struct ActionIcon: View {
    let name: String
    let label: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color(uiColor: .systemBackground).opacity(0.9))
                .frame(width: 56, height: 56)
                .overlay(Image(systemName: name).foregroundColor(.primary))
                .shadow(radius: 4)
            Text(label).font(.caption).foregroundColor(.secondary)
        }
    }
}
