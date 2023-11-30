//
//  WatchTwich.swift
//  WatchTwich
//
//  Created by 양윤석 on 11/15/23.
//

import AppIntents

struct WatchTwich: AppIntent {
    static var title: LocalizedStringResource = "WatchTwich"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
