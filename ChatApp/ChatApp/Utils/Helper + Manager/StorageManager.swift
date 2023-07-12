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
    
    public typealias UploadCompletion = (Result<String , Error>) -> Void
    
}

extension StorageManager {
    /// upload user's profile picture to Firebase and get download URL
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadCompletion ) {
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
    
    /// upload photo message
    public func uploadPhotoMessage(with data: Data, fileName: String, completion: @escaping UploadCompletion ) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] _ , uploadError in
            guard uploadError == nil else {
                print("Failed to upload images")
                // failed
                completion(.failure(StorageErorr.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
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
    
    ///  Upload video to firebase
    public func uploadVideoMessage(with fileURL: URL, fileName: String, completion: @escaping UploadCompletion ) {
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        guard let videoData = NSData(contentsOf: fileURL) as Data? else { return }
        storage.child("message_videos/\(fileName)").putData(videoData, metadata: metadata) { [weak self] metadata , uploadError in
            guard uploadError == nil else {
                print("Failed to upload video")
                // failed
                completion(.failure(StorageErorr.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
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
    
    public func downloadWithURL(for path: String, completion: @escaping (Result<URL, StorageErorr>) -> Void ) {
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
