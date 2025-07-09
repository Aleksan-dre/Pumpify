//
//  Stopwatch.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import SwiftUI
import SwiftData

struct Stopwatch: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: StopwatchViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(colorScheme == .light ? Color.black.opacity(0.09) : Color.white.opacity(0.09), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .padding()
                    
                    if (viewModel.elapsedPeriods < 1 || viewModel.totalElapsedTime.truncatingRemainder(dividingBy: 1) > 0.3) {
                        Circle()
                            .trim(from: 0, to: min(viewModel.elapsedPeriods, 1.0))
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .padding()
                    }

                    Text(viewModel.timeElapsed)
                        .font(.largeTitle)
                        .padding()
                }
                
                HStack {
                    if viewModel.isRunning {
                        Button(action: viewModel.stop) {
                            Text("Pause")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: viewModel.start) {
                            Text("Start")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    if viewModel.hasStarted {
                        Button(action: {
                            Task {
                                let success = await viewModel.save()
                                if success {
                                    dismiss()
                                }
                            }
                        }) {
                            Text("Finish")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Show reset button if there's existing data or current session has started
                    if viewModel.previousElapsedTime > 0 || viewModel.hasStarted {
                        Button(action: {
                            Task {
                                let success = await viewModel.resetStopwatchData()
                                if success {
                                    // Reset the UI state after successful reset
                                    viewModel.hasStarted = false
                                }
                            }
                        }) {
                            Text("Reset")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
                
                if viewModel.allowsManualEntry {
                    VStack(spacing: 16) {
                        Text("Did you complete the workout already?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                DatePicker("Start Time", selection: $viewModel.manualStartDate, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("End Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                DatePicker("End Time", selection: $viewModel.manualEndDate, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                            }
                        }
                        .padding(.horizontal)
                        
                        Button("Add manually") {
                            Task {
                                let success = await viewModel.saveManual()
                                if success {
                                    dismiss()
                                }
                            }
                        }
                        .disabled(viewModel.manualStartDate.withoutSeconds() >= viewModel.manualEndDate.withoutSeconds())
                        .padding()
                        .background(viewModel.manualStartDate.withoutSeconds() >= viewModel.manualEndDate.withoutSeconds() ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
            }
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
    }
}
