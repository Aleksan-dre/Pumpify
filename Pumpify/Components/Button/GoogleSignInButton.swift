//
//  GoogleSignInButton.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

struct GoogleSignInButton: View {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image("google-icon")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(.circle)
                Text("Sign in with Google")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
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
    GoogleSignInButton {
        print("You just pressed the google button!")
    }
}
