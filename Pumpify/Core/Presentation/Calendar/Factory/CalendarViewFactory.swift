//
//  CalendarViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 06.07.25.
//

import SwiftUI
import SwiftData

@MainActor
struct CalendarViewFactory {
    static func make(repository: any DataRepositoryProtocol) -> some View {
        let viewModel = CalendarViewModel(repository: repository)
        return CalendarView(viewModel: viewModel)
    }
}
