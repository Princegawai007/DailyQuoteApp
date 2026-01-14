//
//  CollectionsListView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//
import SwiftUI

struct CollectionsListView: View {
    @StateObject var viewModel = CollectionsViewModel()
    @State private var showingAddAlert = false
    @State private var newCollectionName = ""
    
    // 1. Create the dismiss action
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            if let error = viewModel.errorMessage {
                Section {
                    Text("⚠️ " + error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            if viewModel.collections.isEmpty && !viewModel.isLoading {
                Text("No collections yet. Create one!")
                    .foregroundColor(.gray)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            ForEach(viewModel.collections) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.green)
                        Text(collection.title)
                    }
                }
            }
        }
        .navigationTitle("My Collections")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 2. Add the Leading "Done" button to go back
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss() // This closes the view and goes back to Home
                }
            }
            
            // 3. Keep your Trailing "Add" button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddAlert = true }) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.green)
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchCollections() }
        }
        .alert("New Collection", isPresented: $showingAddAlert) {
            TextField("Name", text: $newCollectionName)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                Task {
                    await viewModel.createCollection(title: newCollectionName)
                    newCollectionName = ""
                }
            }
        }
    }
}
