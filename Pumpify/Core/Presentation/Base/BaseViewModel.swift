//
//  BaseViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Base ViewModel

/**
 * BaseViewModel provides common functionality for all ViewModels in the MVVM architecture.
 * 
 * ## Purpose:
 * - **Error Handling**: Centralized error management with user-friendly alerts
 * - **Loading States**: Common loading indicators for async operations  
 * - **Repository Access**: Dependency injection for data operations
 * - **Reactive Programming**: Combine publishers for reactive updates
 * - **Code Reusability**: Common patterns shared across all ViewModels
 * 
 * ## Usage:
 * ```swift
 * class MyViewModel: BaseViewModel {
 *     @Published var data: [Model] = []
 *     
 *     override init(repository: DataRepositoryProtocol) {
 *         super.init(repository: repository)
 *         Task { await loadData() }
 *     }
 *     
 *     func loadData() async {
 *         await withErrorHandling {
 *             self.data = try await repository.fetchData()
 *         }
 *     }
 * }
 * ```
 * 
 * ## Key Features:
 * - Automatic error handling with user alerts
 * - Loading state management
 * - Repository dependency injection
 * - Combine subscription management
 * - Memory leak prevention with proper cleanup
 */
@MainActor
class BaseViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showingError = false
    
    // MARK: - Internal Properties (accessible by subclasses)
    // Note: Swift doesn't have 'protected' - using 'internal' for subclass access
    var cancellables = Set<AnyCancellable>()
    let repository: any DataRepositoryProtocol
    
    init(repository: any DataRepositoryProtocol) {
        self.repository = repository
        setupErrorHandling()
    }
    
    private func setupErrorHandling() {
        $error
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.showingError = true
            }
            .store(in: &cancellables)
    }
    
    func handleError(_ error: Error) {
        self.error = error
        isLoading = false
        print("Error in \(String(describing: type(of: self))): \(error.localizedDescription)")
    }
    
    func dismissError() {
        error = nil
        showingError = false
    }
    
    // MARK: - Error Handling Methods
    
    func withErrorHandling<T>(_ operation: @escaping () async throws -> T) async -> T? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await operation()
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func withErrorHandling(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await operation()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Error Alert Modifier

struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var viewModel: BaseViewModel
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error occurred")
            }
    }
}

extension View {
    func errorAlert(for viewModel: BaseViewModel) -> some View {
        self.modifier(ErrorAlertModifier(viewModel: viewModel))
    }
}

// MARK: - Loading Overlay Modifier

struct LoadingOverlayModifier: ViewModifier {
    @ObservedObject var viewModel: BaseViewModel
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                
                                Text("Loading...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.top, 8)
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                        }
                    }
                }
            )
    }
}

extension View {
    func loadingOverlay(for viewModel: BaseViewModel) -> some View {
        self.modifier(LoadingOverlayModifier(viewModel: viewModel))
    }
}
