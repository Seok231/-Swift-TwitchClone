//
//  Firebase.swift
//  TwitchClone
//
//  Created by 양윤석 on 10/9/23.
//

import UIKit
import FirebaseStorage
import Firebase

class FirebaseStorageManager {
    static func uploadImage(image: UIImage, imageName: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let imageName = imageName
        
        let firebaseReference = Storage.storage().reference().child("Thumbnail/\(imageName)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    static func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(1 * 1024 * 1024)
        storageReference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
    
    static func deleteImage(imageName: String) {
        // Create a reference to the file to delete
        let desertRef = Storage.storage().reference().child("Thumbnail/\(imageName)")
        // Delete the file
        desertRef.delete { error in
          if let error = error {
              print("deleteImage error", error)
          } else {
            // File deleted successfully
          }
        }
    }
}
