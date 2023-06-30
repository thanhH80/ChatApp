//
//  StorageManager.swift
//  ChatApp
//
//  Created by Thagion Jack on 15/06/2023.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadImageCompletion = (Result<String , Error>) -> Void
    
}

extension StorageManager {
    /// upload user's profile picture to Firebase and get download URL
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadImageCompletion ) {
        storage.child("\(DatabasePath.images.dto)/\(fileName)").putData(data, metadata: nil) { _ , uploadError in
            guard uploadError == nil else {
                print("Failed to upload images")
                // failed
                completion(.failure(StorageErorr.failedToUpload))
                return
            }
            
            self.storage.child("\(DatabasePath.images.dto)/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErorr.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("Downloaded url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public func fetchDownloadURL(for path: String, completion: @escaping (Result<URL, StorageErorr>) -> Void ) {
        let ref = storage.child(path)
        ref.downloadURL { url, error in
            guard let url = url else {
                completion(.failure(.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
}
