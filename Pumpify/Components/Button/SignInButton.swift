//
//  GoogleSignInButton.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

struct SignInButton: View {
    private let title: String
    private let icon: Image?
    private let action: () -> Void
    
    init(title: String,
         icon: Image? = nil,
         action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon {
                    icon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.leading, .assets.xl2)
                        //.clipShape(.circle)
                }
                
                Spacer()
                
                Text(title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
                    .padding(.trailing, .assets.xl2)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.black)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SignInButton(title: "Google Sign in") {
        print("You just pressed the google button!")
    }
}
