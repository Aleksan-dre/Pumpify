//
//  CalendarView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 06.07.25.
//

import SwiftUI
import SwiftData

// MARK: - Control Panel Rectangle Definition

/// Represents the rectangle of a control panel button with an associated view index.
struct ControlPanelRect: Equatable {
    let viewIdx: Int
    let rect: CGRect
}

/// PreferenceKey to collect control panel rectangles.
struct ControlPanelRectKey: PreferenceKey {
    typealias Value = [ControlPanelRect]
    static var defaultValue: [ControlPanelRect] = []
    static func reduce(value: inout [ControlPanelRect], nextValue: () -> [ControlPanelRect]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - CalendarView Main View

struct CalendarView: View {
    @StateObject var viewModel: CalendarViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ControlPanelView(viewModel: viewModel)
                
                if viewModel.styleIdx == 1 {
                    CalendarListView(viewModel: viewModel)
                } else {
                    CalendarGridView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Control Panel View

struct ControlPanelView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var rects: [CGRect] = Array<CGRect>(repeating: CGRect(), count: 2)
    
    var body: some View {
        HStack {
            Button(action: { viewModel.changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text("\(viewModel.currentMonth, formatter: DateFormatter.monthAndYear)")
                .font(.headline)
            
            Spacer()
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.8))
                    .frame(width: rects[viewModel.styleIdx].size.width, height: rects[viewModel.styleIdx].size.height)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 5.0).foregroundColor(.accentColor)
                    )
                    .offset(x: rects[viewModel.styleIdx].minX, y: rects[viewModel.styleIdx].minY)
                    .animation(.easeInOut(duration: 0.35), value: viewModel.styleIdx)
                
                HStack {
                    ForEach(0...1, id: \.self) { col in
                        ControlPanelButtonView(viewModel: viewModel, idx: col)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .coordinateSpace(name: "controlPanelZStack")
            .onTapGesture { viewModel.toggleStyle() }
            
            Spacer()
            
            Button(action: { viewModel.changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .onPreferenceChange(ControlPanelRectKey.self) { preferences in
            for p in preferences {
                self.rects[p.viewIdx] = p.rect
            }
        }
    }
}

// MARK: - Control Panel Button View

struct ControlPanelButtonView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let idx: Int
    let viewStyle = ["Cal.", "List."]
    
    var body: some View {
        Text("\(viewStyle[idx])")
            .padding(3)
            .background(ControlPanelButtonGeometryView(idx: idx))
    }
}

struct ControlPanelButtonGeometryView: View {
    let idx: Int
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: ControlPanelRectKey.self,
                            value: [ControlPanelRect(viewIdx: self.idx, rect: geometry.frame(in: .named("controlPanelZStack")))])
        }
    }
}

// MARK: - Calendar Grid View

struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Days of the week header
            HStack(spacing: 2) {
                ForEach(viewModel.daysOfWeek, id: \.self) { day in
                    Text(day.shortString)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                    // Empty cells for the beginning of the month
                    let numberOfEmptyCells = viewModel.numberOfEmptyCells(at: viewModel.currentMonth)
                    ForEach(0..<numberOfEmptyCells, id: \.self) { _ in
                        VStack {
                            Text("")
                        }
                        .frame(height: 80)
                    }
                    
                    // Days of the month
                    ForEach(1...viewModel.daysInMonth(date: viewModel.currentMonth), id: \.self) { day in
                        let date = Calendar.current.date(byAdding: .day, value: day - 1, to: Calendar.current.dateInterval(of: .month, for: viewModel.currentMonth)?.start ?? viewModel.currentMonth) ?? viewModel.currentMonth
                        
                        CalendarDayView(
                            date: date,
                            exercises: viewModel.exercisesForDate(date),
                            viewModel: viewModel
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let exercises: [Exercise]
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        NavigationLink(destination: ExerciseDetailsViewFactory.make(date: date, repository: viewModel.repository)) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if !exercises.isEmpty {
                    let exercisesDone = exercises.filter { exercise in
                        viewModel.stopwatchDataFor(exerciseId: exercise.id, on: date) != nil
                    }
                    
                    // Show completion ratio (e.g., "2/5")
                    Text("\(exercisesDone.count)/\(exercises.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(exercisesDone.count == exercises.count ? .green : .orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(exercisesDone.count == exercises.count ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        )
                } else {
                    // Show a small dot to indicate no exercises
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
                
                Spacer()
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(exercises.isEmpty ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        exercises.isEmpty ? Color.gray.opacity(0.2) : Color.accentColor.opacity(0.3),
                        lineWidth: exercises.isEmpty ? 1 : 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Calendar List View

struct CalendarListView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack {
            // Search functionality
            HStack {
                TextField("Search by exercise name...", text: $viewModel.searchTerm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                
                Button(action: viewModel.togglePopover) {
                    Text("Filter")
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
            .padding([.bottom])
            
            if viewModel.isShowingPopover {
                FilterPopoverView(viewModel: viewModel)
            }
            
            // Content based on search state
            if viewModel.searchTerm.isEmpty {
                ExerciseListView(viewModel: viewModel)
            } else if !viewModel.searchResults.isEmpty {
                SearchResultsView(viewModel: viewModel)
            } else {
                Text("No results found")
            }
        }
    }
}

// MARK: - Filter Popover View

struct FilterPopoverView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("Tags:")
                .font(.headline)
            
            Picker(selection: $viewModel.searchTerm, label: Text("choice")) {
                if viewModel.tags.isEmpty {
                    Text("No tag exists").tag("")
                } else {
                    Text("Choose tag").tag("")
                    ForEach(viewModel.tags, id: \.name) { tag in
                        Text(tag.name).tag(tag.name)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Spacer()
            
            Button(action: viewModel.closePopover) {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Exercise List View

struct ExerciseListView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.exercisesInMonth(), id: \.0) { item in
                    let date = item.0
                    let exercises = item.1
                    CalendarListDayView(date: date, exercises: exercises, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Search Results View

struct SearchResultsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        List(viewModel.searchResults) { result in
            NavigationLink {
                WorkoutDetailsView(workout: result.workout, repository: viewModel.repository)
            } label: {
                WorkoutSearchResultView(result: result)
            }
        }
        .listStyle(InsetListStyle())
        .background(Color.white)
    }
}

// MARK: - Calendar List Day View

struct CalendarListDayView: View {
    let date: Date
    let exercises: [Exercise]
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(DateFormatter.mediumDate.string(from: date))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                let exercisesDone = exercises.filter { exercise in
                    viewModel.stopwatchDataFor(exerciseId: exercise.id, on: date) != nil
                }
                
                Text("\(exercisesDone.count)/\(exercises.count) completed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(exercisesDone.count == exercises.count ? .green : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(exercisesDone.count == exercises.count ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    )
            }
            
            NavigationLink(destination: ExerciseDetailsViewFactory.make(date: date, repository: viewModel.repository)) {
                VStack(spacing: 4) {
                    ForEach(exercises.prefix(3), id: \.id) { exercise in
                        let stopwatchData = viewModel.stopwatchDataFor(exerciseId: exercise.id, on: date)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                if !exercise.tags.isEmpty {
                                    Text(exercise.tags.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let stopwatchData = stopwatchData {
                                Text(String(format: "%@", stopwatchData.totalInterval.formattedTime()))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.green.opacity(0.2))
                                    )
                            }
                            
                            Image(systemName: stopwatchData != nil ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(stopwatchData != nil ? .green : .gray)
                                .font(.title3)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                    
                    if exercises.count > 3 {
                        Text("+ \(exercises.count - 3) more exercises")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Exercise Indicator View

struct ExerciseIndicatorView: View {
    let text: String
    let complete: Bool
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(3)
            .frame(maxWidth: .infinity)
            .background(complete ? Color.green.opacity(0.2) : Color.accentColor.opacity(0.2))
            .cornerRadius(5)
    }
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Workout.self, Settings.self, StopwatchData.self)
    let repository = DataRepository(modelContext: container.mainContext)
    return CalendarViewFactory.make(repository: repository)
}
