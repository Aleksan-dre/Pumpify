//
//  GeneralButton.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

struct GeneralButton: View {
    private let title: String
    private let action: () -> Void
    private let isEnabled: Bool
    private let color: Color
    
    init(
        title: String,
        isEnabled: Bool = true,
        color: Color = .orange,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.action = action
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? color : color.opacity(0.95))
                .clipShape(.rect(cornerRadius: 16))
                .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    GeneralButton(title: "Confirm", isEnabled: true) {
        print("Button got tapped")
    }
    GeneralButton(title: "Disabled", isEnabled: false) {
        print("Button should not be tapped")
    }
}
