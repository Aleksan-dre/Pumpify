//
//  FirebaseService.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 06.07.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

final class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // MARK: - Generic CRUD Operations
    
    /// Save a model to Firebase
    func save<T: Codable>(_ model: T, to collection: String, documentId: String? = nil) async throws -> String {
        guard let userId = currentUserId else {
            throw FirebaseError.userNotAuthenticated
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(model)
        let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        let userCollection = db.collection("users").document(userId).collection(collection)
        
        if let documentId = documentId {
            try await userCollection.document(documentId).setData(dictionary, merge: true)
            return documentId
        } else {
            let documentRef = try await userCollection.addDocument(data: dictionary)
            return documentRef.documentID
        }
    }
    
    /// Fetch a specific model from Firebase
    func fetch<T: Codable>(_ type: T.Type, from collection: String, documentId: String) async throws -> T {
        guard let userId = currentUserId else {
            throw FirebaseError.userNotAuthenticated
        }
        
        let document = try await db.collection("users").document(userId).collection(collection).document(documentId).getDocument()
        
        guard let data = document.data() else {
            throw FirebaseError.documentNotFound
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(type, from: jsonData)
    }
    
    /// Fetch all models from a collection
    func fetchAll<T: Codable>(_ type: T.Type, from collection: String) async throws -> [T] {
        guard let userId = currentUserId else {
            throw FirebaseError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection("users").document(userId).collection(collection).getDocuments()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try snapshot.documents.compactMap { document in
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            return try decoder.decode(type, from: jsonData)
        }
    }
    
    /// Delete a document from Firebase
    func delete(from collection: String, documentId: String) async throws {
        guard let userId = currentUserId else {
            throw FirebaseError.userNotAuthenticated
        }
        
        try await db.collection("users").document(userId).collection(collection).document(documentId).delete()
    }
    
    /// Listen to real-time updates for a collection
    func listen<T: Codable>(to collection: String, type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(FirebaseError.userNotAuthenticated))
            return nil
        }
        
        return db.collection("users").document(userId).collection(collection).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let models = try documents.compactMap { document -> T? in
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    return try decoder.decode(type, from: jsonData)
                }
                completion(.success(models))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Firebase Errors
enum FirebaseError: LocalizedError {
    case userNotAuthenticated
    case documentNotFound
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .documentNotFound:
            return "Document not found"
        case .encodingError:
            return "Failed to encode data"
        case .decodingError:
            return "Failed to decode data"
        }
    }
}
