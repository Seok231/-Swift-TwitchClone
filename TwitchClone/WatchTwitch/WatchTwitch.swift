//
//  WatchTwitch.swift
//  WatchTwitch
//
//  Created by 양윤석 on 11/15/23.
//

import AppIntents

struct WatchTwitch: AppIntent {
    static var title: LocalizedStringResource = "WatchTwitch"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
