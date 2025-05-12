//
//  ErrorLabelView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

struct ErrorLabelView: View {
    let errorMessage: String?
    
    var body: some View {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            Text(errorMessage)
                .font(.system(size: 12))
                .foregroundStyle(.systemError)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.leading, .assets.xs5)
        }
    }
}
