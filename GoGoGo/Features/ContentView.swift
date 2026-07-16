//
//  ContentView.swift
//  GoGoGo
//
//  Created by br3nd4nt on 16.07.2026.
//

import SwiftUI

struct ContentView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject private var game = GoGame(size: 9)
    @State private var showGameOverAlert = false
    @State private var gameOverMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if isLandscape {
                    HStack(spacing: 12) {
                        GameViewControllerRepresentable(game: game, showAlert: $showGameOverAlert, alertMessage: $gameOverMessage)
                            .frame(maxWidth: .infinity)
                            .padding(.leading, 8)
                        
                        ControlPanelView(game: game, showAlert: $showGameOverAlert, alertMessage: $gameOverMessage)
                            .frame(width: 240)
                            .padding(.trailing, 16)
                            .padding(.vertical, 16)
                    }
                    .padding(.horizontal, 8)
                    
                } else {
                    VStack(spacing: 8) {
                        GameViewControllerRepresentable(game: game, showAlert: $showGameOverAlert, alertMessage: $gameOverMessage)
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.7)
                            .padding(.top, 8)
                        
                        ControlPanelView(game: game, showAlert: $showGameOverAlert, alertMessage: $gameOverMessage)
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.25)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .alert("Game Over", isPresented: $showGameOverAlert) {
            Button("New Game") {
                game.reset()
                // Notify scene to reset
                NotificationCenter.default.post(name: .resetGame, object: nil)
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(gameOverMessage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameOver)) { notification in
            if let message = notification.userInfo?["message"] as? String {
                gameOverMessage = message
                showGameOverAlert = true
            }
        }
    }
}

extension Notification.Name {
    static let resetGame = Notification.Name("resetGame")
    static let gameOver = Notification.Name("gameOver")
}
