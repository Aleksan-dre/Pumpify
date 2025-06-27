//
//  ExerciseDetails.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    var date: Date
    var maxViewDayCnt = 1 // use for count maxViewDate
    
    @Environment(\.modelContext) var context
    
    @State var showRestartStopwatchConfirmation = false
    @State var navigatingToStopwatch = false
    @State var continuingStopwatchDatum: StopwatchData?
    
    @Query var stopwatchData: [StopwatchData]
    @Query var projects: [Workout]
    private var allExercises: [Exercise] {
        projects.flatMap { $0.exercises }
    }
    private var ExercisesToday: [Exercise] {
        let componentsOfDate = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return allExercises.filter { Exercise in
            if Exercise.startDate > Calendar.current.date(byAdding: .day, value: 1, to: date)! {
                // Exercise starts after today, therefore we're not interested
                return false
            }
            
            let componentsOfExercise = Calendar.current.dateComponents([.day, .month, .year], from: Exercise.startDate)
            if componentsOfDate == componentsOfExercise {
                // If the Exercise starts today, then it is okay
                return true
            }
            
            var weekdayOfDate = (Calendar.current.dateComponents([.weekday], from: date).weekday! + 6) % 7
            if weekdayOfDate == 0 { weekdayOfDate = 7 }
            let weekday = DayOfWeek(rawValue: weekdayOfDate)!
            if Exercise.repeatDays.contains(weekday) {
                // The Exercise repeats today, so it's okay
                return true
            }
            
            // The Exercise doesn't repeat today, don't use it
            return false
        }
    }
    
    init(date: Date) {
        self.date = date
        let viewDateComponents = Calendar.current.dateComponents(
            [.day, .month, .year],
            from: date
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(ExercisesToday.indices, id: \.self) { index in
                exerciseItemView(ExercisesToday[index])
            }
            
            if ExercisesToday.isEmpty {
                Spacer()
                
                Text("No Exercises for this day")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }

    private func exerciseItemView(_ item: Exercise) -> some View {
        let stopwatchDatum = stopwatchData.filter { $0.exerciseId == item.id && Calendar.current.isDate($0.completionDate, inSameDayAs: date) }.first
        
        let label = VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                }
                Spacer()
                if let stopwatchDatum = stopwatchDatum {
                    Text(String(format: "Time: %@", stopwatchDatum.totalInterval.formattedTime()))
                        .padding([.horizontal])
                }
                Image(systemName: stopwatchDatum != nil ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(stopwatchDatum != nil ? .green : .gray)
            }
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        
        if stopwatchDatum == nil {
            return AnyView(
                NavigationLink(
                    destination:  StopwatchViewFactory.make(
                        exerciseId: item.id,
                        date: date
                    )
                ) {
                    label
                }
            )
        }
        else {
            return AnyView(
                Button {
                    showRestartStopwatchConfirmation = true
                } label: {
                    label
                        .confirmationDialog(
                            "Do you want to restart or continue the tracking?",
                            isPresented: $showRestartStopwatchConfirmation,
                            titleVisibility: .visible) {
                                Button(role: .destructive) {
                                    discardStopwatchData(for: item)
                                    navigateToStopwatch()
                                } label: {
                                    Text("Discard data and restart")
                                }
                                Button {
                                    navigateToStopwatch(continuingWith: stopwatchDatum)
                                } label: {
                                    Text("Continue tracking")
                                }
                            }
                }.navigationDestination(isPresented: $navigatingToStopwatch) {
                    StopwatchViewFactory.make(
                        exerciseId: item.id,
                        date: date,
                        updating: continuingStopwatchDatum
                    )
                }
            )
        }
    }
    
    private func discardStopwatchData(for exercise: Exercise) {
        let stopwatchDataForExercise = stopwatchData.filter { $0.exerciseId == exercise.id }
        for datum in stopwatchDataForExercise {
            context.delete(datum)
        }
    }
    private func navigateToStopwatch(continuingWith stopwatchData: StopwatchData? = nil) {
        continuingStopwatchDatum = stopwatchData
        navigatingToStopwatch = true
    }
}

