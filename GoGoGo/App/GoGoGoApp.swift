//
//  GoGoGoApp.swift
//  GoGoGo
//
//  Created by br3nd4nt on 28.06.2026.
//

import SwiftUI

@main
struct GoGoGoApp: App {
    var body: some Scene {
        WindowGroup {
            HStack {
                GameViewControllerRepresentable()
            }
//            .background(Color.pink)
        }
    }
}
