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
                }
                
                Spacer()
                
                if !viewModel.hasStarted && viewModel.allowsManualEntry {
                    VStack {
                        Spacer()
                        
                        Text("Did you complete the workout already?")
                        
                        Form {
                            DatePicker("Start Time", selection: $viewModel.manualStartDate, displayedComponents: .hourAndMinute)
                            DatePicker("End Time", selection: $viewModel.manualEndDate, displayedComponents: .hourAndMinute)
                        }
                        
                        Button("Add manually") {
                            Task {
                                let success = await viewModel.saveManual()
                                if success {
                                    dismiss()
                                }
                            }
                        }
                        .disabled(viewModel.manualStartDate.withoutSeconds() == viewModel.manualEndDate.withoutSeconds())
                    }
                    .padding(.vertical)
                }
            }
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
    }
}
