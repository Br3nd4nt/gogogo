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
//        gameScene = GoGameScene(size: view.bounds.size)
        gameScene.size = view.bounds.size
        gameScene.scaleMode = .resizeFill
        gameScene.backgroundColor = .clear
        
        skView.presentScene(gameScene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}
struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = GameViewController
    
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
    }
}
