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
        Text("Google Sign In Button")
    }
}

#Preview {
    GoogleSignInButton {
        print("You just pressed the google button!")
    }
}
