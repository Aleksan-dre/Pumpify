//
//  MainTabViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import SwiftUI
import SwiftData

struct MainTabViewFactory {
    static func make(context: ModelContext) -> some View {
        MainTabView(context: context)
    }
}
