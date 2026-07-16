//
//  ContentView.swift
//  GoGoGo
//
//  Created by br3nd4nt on 28.06.2026.
//

import UIKit
import SpriteKit
import SwiftUI

final class GameViewController: UIViewController {
    var game = GoGame()
    private var skView: SKView = SKView(frame: .zero)
    private var gameScene: GoGameScene = GoGameScene(size: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        skView.backgroundColor = .clear
        skView.isOpaque = false
        
        // Create and present scene
        gameScene.size = view.bounds.size
        gameScene.scaleMode = .resizeFill
        gameScene.backgroundColor = .clear
        
        skView.presentScene(gameScene)
        skView.ignoresSiblingOrder = true
        //        skView.showsFPS = true
        //        skView.showsNodeCount = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleResetGame),
            name: .resetGame,
            object: nil
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.gameScene.size = size
    }
    
    func updateUI() {
        gameScene.setGame(game)
        gameScene.updateAllStones()
    }
    
    @objc private func handleResetGame() {
        game = GoGame(size: 9)
        gameScene.setGame(game)
        gameScene.updateAllStones()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var game: GoGame
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    func makeUIViewController(context: Context) -> GameViewController {
        let vc = GameViewController()
        vc.game = game
        return vc
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        uiViewController.game = game
        uiViewController.updateUI()
    }
}
