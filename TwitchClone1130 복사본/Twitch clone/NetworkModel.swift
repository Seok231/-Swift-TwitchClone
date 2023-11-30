//
//  UserInfoModel.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/17.
//

import Foundation
import UIKit

class ImageCachManager {
    static let shared = NSCache<NSString, UIImage>()
}

class LiveResult {
    func hlsURL (hls: String) -> URL {
        switch hls.count {
        case 0...15:
            let makeURL = "http://diddbstjr55.shop/hls/\(hls).m3u8"
            let url = URL(string: makeURL)
            return url!

        default:
            let url = URL(string: hls)
                
            return url!
        }
    }
}

struct LiveList {
    static var result = LiveList()
    var liveList: [LiveListModel] = []
    
}

struct UserInfoModel {
    static var user = UserInfoModel()
    var userName: String = ""
    var userEmail: String = ""
    var userEmailSplit: String = ""
    var userPhotoURL: URL?
    var fcmToken: String = ""
    
}

struct FirstTree: Codable {
    let liveListModel: [LiveListModel]
    
}

struct CategoryModelList {
    static var result = CategoryModelList()
    var list: [CategoryModel] = []
    var userFollowingList: [CategoryModel] = []
}

struct UserFollowingList: Codable {
    let host: [UserFollowing]
    let category: [CategoryModel]
}

struct CategoryModel: Codable {
    let name: String
    let url: String
}

struct UserFollowing: Codable {
    let name: String?
    let following: Bool?
}


struct LiveListModel: Codable {
    let title: String
    let hls: String
    let date: Double
    let hostName: String
    let streamInfo: String?
    let streamCategory: String
    let imageURL: String
    let hostImage: String
}



struct saveImage {
    static var img = saveImage()
    var thumbnail: [UIImage] = []
}
