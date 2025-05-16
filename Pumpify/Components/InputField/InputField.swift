//
//  InputField.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

fileprivate enum Constants {
    enum SymbolNames {
        static let xmark = "xmark"
        static let eye = "eye"
        static let eyeSlash = "eye.slash"
    }
}

// MARK: - InputFieldType
enum InputFieldType: Equatable {
    case email
    case password
    case number
    case custom(UIKeyboardType)
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .number:
            return .numberPad
        case .password, .custom:
            return .default
        }
    }
    
    var isSecure: Bool {
        return self == .password
    }
}

// MARK: - CustomInputField
struct InputField: View {
    @Binding var text: String
    @Binding var isInputValid: Bool
    @Binding var isInputCorrect: Bool
    @Binding var errorMessage: String?
    @State private var isSecure: Bool = true
    private var isEnabled: Bool

    let placeholder: String
    private let type: InputFieldType
    private var keyboardType: UIKeyboardType = .default
    private var isPassword: Bool = false
    
    init(
        text: Binding<String>,
        type: InputFieldType = .custom(.default),
        placeholder: String,
        isInputValid: Binding<Bool> = .constant(true),
        isInputCorrect: Binding<Bool> = .constant(true),
        errorMessage: Binding<String?> = .constant(nil),
        isEnabled: Bool = true
    ) {
        self._text = text
        self.type = type
        self.placeholder = placeholder
        self._isInputValid = isInputValid
        self._isInputCorrect = isInputCorrect
        self._errorMessage = errorMessage
        self.isEnabled = isEnabled
        
        switch type {
        case .email:
            keyboardType = .emailAddress
        case .number:
            keyboardType = .numberPad
        case .password:
            isPassword = true
            isSecure = true
        case .custom:
            keyboardType = .default
        }
    }
    
    private var isValidInput: Bool {
        isInputValid && isInputCorrect
    }
    
    var body: some View {
        let borderColor: Color = isEnabled ? (isValidInput ? .gray : .systemError) : .gray
        
        return VStack(alignment: .leading, spacing: .assets.xs4) {
            HStack {
                if isPassword && isSecure {
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundStyle(.graySecondary)
                        }
                        
                        SecureField(String.empty, text: $text)
                            .foregroundStyle(.neutralBlack)
                            .disabled(!isEnabled)
                            .keyboardType(type.keyboardType)
                            .frame(height: .assets.xl2)
                            .autocorrectionDisabled(true)
                    }
                } else {
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundStyle(.graySecondary)
                        }
                        
                        TextField(String.empty, text: $text)
                            .foregroundStyle(.neutralBlack)
                            .disabled(!isEnabled)
                            .keyboardType(keyboardType)
                            .frame(height: .assets.xl2)
                            .autocorrectionDisabled(true)
                    }
                }
                
                InputFieldActionButton(text: $text, isPassword: isPassword, isSecure: $isSecure)
                    .disabled(!isEnabled)
            }
            .padding(.horizontal, .assets.sm)
            .padding(.vertical, .assets.sm)
            .overlay(
                RoundedRectangle(cornerRadius: .assets.sm)
                    .stroke(borderColor, lineWidth: 0.8)
            )
            
            if (!isValidInput) && isEnabled {
                ErrorLabelView(errorMessage: errorMessage)
            }
        }
    }
}

// MARK: - CustomInputFieldButton
private struct InputFieldActionButton: View {
    var text: Binding<String>
    let isPassword: Bool
    var isSecure: Binding<Bool>
    
    var body: some View {
        if isPassword {
            HStack {
                clearButton
                eyeButton
            }
        } else {
            clearButton
        }
    }
}

private extension InputFieldActionButton {
    @ViewBuilder
    var clearButton: some View {
        if !text.wrappedValue.isEmpty {
            Button(action: { text.wrappedValue = .empty }) {
                Image(systemName: Constants.SymbolNames.xmark)
                    .foregroundStyle(.graySecondary)
                    .padding(.trailing, .assets.xs3)
            }
        }
    }
    
    var eyeButton: some View {
        Button(action: { isSecure.wrappedValue.toggle() })
        {
            Image(systemName: isSecure.wrappedValue ? Constants.SymbolNames.eyeSlash : Constants.SymbolNames.eye)
                .foregroundColor(.graySecondary)
        }
        .padding(.trailing, .assets.xs4)
    }
}

// MARK: - InputFieldBorder
private struct InputFieldBorder: View {
    let isValidInput: Bool
    let isEnabled: Bool
    
    var body: some View {
        if isEnabled {
            Rectangle()
                .frame(height: .assets.xs5)
                .foregroundStyle(isValidInput ? .grayTertiary : .systemError)
        } else {
            Rectangle()
                .frame(height: .assets.xs5)
                .foregroundStyle(.grayTertiary)
        }
    }
}
