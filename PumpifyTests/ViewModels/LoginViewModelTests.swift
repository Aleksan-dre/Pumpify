//
//  LoginViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import Combine
import FirebaseAuth
@testable import Pumpify

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    var viewModel: LoginViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = LoginViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        cancellables = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initialization
    
    func testInitialState() {
        // Then
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertTrue(viewModel.isEmailValid)
        XCTAssertTrue(viewModel.isPasswordValid)
        XCTAssertTrue(viewModel.isEmailCorrect)
        XCTAssertTrue(viewModel.isPasswordCorrect)
        XCTAssertFalse(viewModel.isButtonActive)
        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssert(viewModel.emailErrorMessage == .empty)
        XCTAssert(viewModel.passwordErrorMessage == .empty)
    }
    
    // MARK: - Test Email Validation
    
    func testEmailValidation_ValidEmail() {
        // When
        viewModel.email = "test@example.com"
        
        // Then
        XCTAssertTrue(viewModel.isEmailValid)
    }
    
    func testEmailValidation_InvalidEmail() {
        // When
        viewModel.email = "invalid-email"
        
        // Then
        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertEqual(viewModel.emailErrorMessage, "Email has incorrect format")
    }
    
    func testEmailValidation_EmptyEmail() {
        // When
        viewModel.email = ""
        
        // Then
        XCTAssertTrue(viewModel.isEmailValid) // Empty email is considered valid initially
    }
    
    // MARK: - Test Button State
    
    func testButtonState_ValidCredentials() {
        // When
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        // Give some time for the binding to update
        let expectation = expectation(description: "Button state should update")
        
        viewModel.$isButtonActive
            .sink { isActive in
                if isActive {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.viewModel.isButtonActive)
        }
    }
    
    func testButtonState_EmptyEmail() {
        // When
        viewModel.email = ""
        viewModel.password = "password123"
        
        // Then
        XCTAssertFalse(viewModel.isButtonActive)
    }
    
    func testButtonState_EmptyPassword() {
        // When
        viewModel.email = "test@example.com"
        viewModel.password = ""
        
        // Then
        XCTAssertFalse(viewModel.isButtonActive)
    }
    
    func testButtonState_InvalidEmail() {
        // When
        viewModel.email = "invalid-email"
        viewModel.password = "password123"
        
        // Then
        XCTAssertFalse(viewModel.isButtonActive)
    }
    
    func testLoginWithGoogle_DoesNotCrash() {
        // Given/When/Then
        // This test ensures the method exists and doesn't crash
        // Real testing would require mocking Google Sign-In
        XCTAssertNoThrow(viewModel.loginWithGoogle())
    }
    
    // MARK: - Test Property Updates
    
    func testEmailPropertyUpdate() {
        // Given
        let testEmail = "newemail@example.com"
        
        // When
        viewModel.email = testEmail
        
        // Then
        XCTAssertEqual(viewModel.email, testEmail)
    }
    
    func testPasswordPropertyUpdate() {
        // Given
        let testPassword = "newpassword123"
        
        // When
        viewModel.password = testPassword
        
        // Then
        XCTAssertEqual(viewModel.password, testPassword)
    }
    
    // MARK: - Test Error Handling
    
    func testErrorState_EmailError() {
        // When
        viewModel.email = "bad-email"
        
        // Then
        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertNotNil(viewModel.emailErrorMessage)
        XCTAssertEqual(viewModel.emailErrorMessage, "Email has incorrect format")
    }
    
    // MARK: - Test Reactive Bindings
    
    func testReactiveEmailValidation() {
        // Given
        let expectation = expectation(description: "Email validation should update")
        var validationResults: [Bool] = []
        
        viewModel.$isEmailValid
            .sink { isValid in
                validationResults.append(isValid)
                if validationResults.count == 3 { // Initial + 2 changes
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.email = "test@example.com" // Valid
        viewModel.email = "invalid-email" // Invalid
        
        // Then
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(validationResults.count, 3)
            XCTAssertTrue(validationResults[0]) // Initial state
            XCTAssertTrue(validationResults[1]) // Valid email
            XCTAssertFalse(validationResults[2]) // Invalid email
        }
    }
}
