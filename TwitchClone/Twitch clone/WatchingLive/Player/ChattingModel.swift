//
//  ChattingModel.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/17.
//

import Foundation

struct Chatting {
    let sender: String
    let body: String
}


struct ChattingUpdate: Codable {
    let sender: String
    let body: String
    let date: Double
}
