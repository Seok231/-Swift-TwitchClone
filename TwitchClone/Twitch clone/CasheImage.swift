//
//  CasheImage.swift
//  TwitchClone
//
//  Created by 양윤석 on 11/7/23.
//

import Foundation
import UIKit

class CasheImage {
    static func hostImage(stringURL: String) -> UIImage {
        let hostCacheKey = NSString(string: stringURL)
        if let image = ImageCachManager.shared.object(forKey: hostCacheKey) {
            return image
        }else if let urlData = URL(string: stringURL), let data = try? Data(contentsOf: urlData), let image = UIImage(data: data){
            ImageCachManager.shared.setObject(image, forKey: hostCacheKey)
            return image
        }
        let loadingImage = UIImage(named: "loadingImage3")
        return loadingImage!
    }
    
    static func thumbnailImage(imageURL: String) -> UIImage {
        let cacheKey = NSString(string: imageURL)
        var setImage = UIImage(named: "loadingImage3")
        if let image = ImageCachManager.shared.object(forKey: cacheKey) {
            return image
        } else {
            FirebaseStorageManager.downloadImage(urlString: imageURL) { image in
                if let image = image {
                    ImageCachManager.shared.setObject(image, forKey: cacheKey)
                    setImage = image
                }
            }
            return setImage ?? UIImage(named: "loadingImage3")!
        }
    }
    
    static func thumbnailImage2(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: imageURL)
        if let image = ImageCachManager.shared.object(forKey: cacheKey) {
            completion(image)
        } else {
            FirebaseStorageManager.downloadImage(urlString: imageURL) { image in
                if let image = image {
                    ImageCachManager.shared.setObject(image, forKey: cacheKey)
                    completion(image)
                }
            }
        }
    }
    static func imageToDirectory(identifier: String, imageURL: String,  completion: @escaping (UIImage?) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory,in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(identifier, conformingTo: .jpeg)
    
        if fileManager.fileExists(atPath: fileURL.path) {
            completion(UIImage(contentsOfFile: fileURL.path))
            print("fileManager")
        } else {
            FirebaseStorageManager.downloadImage(urlString: imageURL) { image in
                if let img = image {
                    do {
                        if let imageData = image?.jpegData(compressionQuality: 1) {
                            try imageData.write(to: fileURL)
                            print("Image saved at: \(fileURL)")
                        }
                    } catch {
                        print("Failed to save images: \(error)")
                    }
                    completion(img)
                }
            }
        }
    }    
}


