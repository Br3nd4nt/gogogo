//
//  GoGoGoApp.swift
//  GoGoGo
//
//  Created by br3nd4nt on 28.06.2026.
//

import SwiftUI

@main
struct GoGoGoApp: App {
    init() {
        _ = DittoNetworking.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
