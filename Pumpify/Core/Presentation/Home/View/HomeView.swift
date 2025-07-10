//
//  HomeView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.shouldShowHint {
                    hintSection
                }
                
                HStack {
                    Text("Today's Activities")
                        .font(.title)
                        .padding(.leading, 16)
                    Spacer()
                }
                .padding(.top, 12)
                
                ExerciseDetailsViewFactory.make(date: Date(), repository: viewModel.repository)
                    .padding(.horizontal)
            }
            .navigationTitle(viewModel.welcomeTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
    }
    
    private var hintSection: some View {
        Group {
            HStack {
                Image(systemName: "info.circle.fill")
                VStack(alignment: .leading) {
                    Text("Hint")
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                    Text("Consider tapping the Settings icon in the top right corner to customize the application, set your name or enable notifications")
                }
            }
            .padding()
            .background(Color.accentColor.opacity(0.4))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .stroke(Color.accentColor.opacity(0.6), lineWidth: 1)
            )
            .padding()
        }
    }
}
