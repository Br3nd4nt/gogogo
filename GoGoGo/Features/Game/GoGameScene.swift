//
//  GoGameScene.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//

import SpriteKit
import GameplayKit
import Puppy
import SwiftUI

class GoGameScene: SKScene {
    private let logger: Puppy = Dependencies.shared.logger
    private var game: GoGame
    private var boardNode: SKNode = SKNode()
    private var stoneNodes: [Position: SKShapeNode] = [:]
    
    // Arrays to track board elements
    private var verticalLines: [SKShapeNode] = []
    private var horizontalLines: [SKShapeNode] = []
    private var starPoints: [SKShapeNode] = []
    
    private let boardSize: Int = 9
    private var cellSize: CGFloat = 10
    private var stoneRadius: CGFloat = 25
    private let boardPadding: CGFloat = 10
    private let deadZone: CGFloat = 0.3
    
    private var elementsCreated = false
    
    private var boardSide = CGFloat.zero
    private var startX = CGFloat.zero
    private var startY = CGFloat.zero
    
    // MARK: - Initialization
    override init(size: CGSize) {
        game = GoGame(size: boardSize)
        super.init(size: size)
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScene() {
        self.backgroundColor = .clear
        
        if boardNode.parent == nil {
            addChild(boardNode)
        }
        
        createBoardElements()
        layoutBoard()
        
        updateAllStones()
    }
    
    // MARK: - Scene Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()
        if !elementsCreated {
            createBoardElements()
            layoutBoard()
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        if !elementsCreated {
            createBoardElements()
            layoutBoard()
        }
    }
    
    // MARK: - Create Board Elements
    private func createBoardElements() {
        guard !elementsCreated else { return }
        elementsCreated = true
        
        // Clear any existing children
        boardNode.removeAllChildren()
        verticalLines.removeAll()
        horizontalLines.removeAll()
        starPoints.removeAll()
        
        // Create vertical lines
        for _ in 0..<boardSize {
            let vLine = SKShapeNode()
            vLine.strokeColor = .black
            vLine.lineWidth = 1.5
            boardNode.addChild(vLine)
            verticalLines.append(vLine)
        }
        
        // Create horizontal lines
        for _ in 0..<boardSize {
            let hLine = SKShapeNode()
            hLine.strokeColor = .black
            hLine.lineWidth = 1.5
            boardNode.addChild(hLine)
            horizontalLines.append(hLine)
        }
        
        // Create star points
        for _ in 0..<5 {
            let star = SKShapeNode(circleOfRadius: 4)
            star.fillColor = .black
            star.strokeColor = .clear
            boardNode.addChild(star)
            starPoints.append(star)
        }
    }
    
    // MARK: - Size Change Handling
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        if !elementsCreated {
            createBoardElements()
        }
        layoutBoard()
        
    }
    
    // MARK: - Layout
    private func layoutBoard() {
        guard elementsCreated else { return }
        
        let minDimension = min(size.width, size.height)
        let availableSize = minDimension - boardPadding * 2
        cellSize = max(availableSize / CGFloat(boardSize), 10)
        stoneRadius = cellSize / 2.5
        
        repositionBoard()
        repositionStones()
    }
    
    private func repositionBoard() {
        boardSide = CGFloat(boardSize - 1) * cellSize
        startX = (size.width - boardSide) / 2
        startY = (size.height - boardSide) / 2
        
        // Reposition vertical lines
        for i in 0..<boardSize {
            let vPath = CGMutablePath()
            let x = startX + CGFloat(i) * cellSize
            vPath.move(to: CGPoint(x: x, y: startY))
            vPath.addLine(to: CGPoint(x: x, y: startY + boardSide))
            verticalLines[i].path = vPath
        }
        
        // Reposition horizontal lines
        for i in 0..<boardSize {
            let hPath = CGMutablePath()
            let y = startY + CGFloat(i) * cellSize
            hPath.move(to: CGPoint(x: startX, y: y))
            hPath.addLine(to: CGPoint(x: startX + boardSide, y: y))
            horizontalLines[i].path = hPath
        }
        
        // Reposition star points
        let starPositions = [
            (2, 2), (2, 6), (6, 2), (6, 6), (4, 4)
        ]
        
        for (index, position) in starPositions.enumerated() {
            let x = startX + CGFloat(position.0) * cellSize
            let y = startY + CGFloat(position.1) * cellSize
            starPoints[index].position = CGPoint(x: x, y: y)
        }
    }
    
    // MARK: - Stone Management
    
    func updateAllStones() {
        removeAllStones()
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let position = Position(row: row, col: col)
                let stone = game.getStone(at: position)
                if stone != .empty {
                    drawStone(stone, at: position)
                }
            }
        }
        logger.debug("Updated all stones - \(stoneNodes.count) stones on board")
    }
    
    private func drawStone(_ stone: Stone, at position: Position) {
        removeStone(at: position)
        let stoneNode = SKShapeNode(circleOfRadius: stoneRadius)
        stoneNode.fillColor = stone.fillColor
        stoneNode.strokeColor = stone.strokeColor
        stoneNode.lineWidth = 0.5
        
        stoneNode.position = positionToPoint(position)
        boardNode.addChild(stoneNode)
        stoneNodes[position] = stoneNode
    }
    
    private func removeStone(at position: Position) {
        if let existingStone = stoneNodes[position] {
            existingStone.removeFromParent()
            stoneNodes.removeValue(forKey: position)
        }
    }
    
    private func removeAllStones() {
        for (_, stoneNode) in stoneNodes {
            stoneNode.removeFromParent()
        }
        stoneNodes.removeAll()
    }
    
    private func repositionStones() {
        let newRadius = stoneRadius
        let newPath = CGPath(ellipseIn: CGRect(
            x: -newRadius,
            y: -newRadius,
            width: newRadius * 2,
            height: newRadius * 2
        ), transform: nil)
        
        for (pos, node) in stoneNodes {
            // Update position
            node.position = positionToPoint(pos)
            // Update radius
            node.path = newPath
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let position = pointToPosition(touch.location(in: self)) else { return }
        if game.placeStone(at: position) {
            updateAllStones()
        }
    }
    
    private func pointToPosition(_ point: CGPoint) -> Position? {
        let normalizedX = point.x - startX
        let normalizedY = point.y - startY
        
        // Check if within board bounds
        let boardWidth = CGFloat(boardSize - 1) * cellSize
        let boardHeight = CGFloat(boardSize - 1) * cellSize
        
        guard normalizedX >= -cellSize/2 && normalizedX <= boardWidth + cellSize/2,
              normalizedY >= -cellSize/2 && normalizedY <= boardHeight + cellSize/2 else {
            return nil
        }
        
        let col = Int(round(normalizedX / cellSize))
        let row = Int(round(normalizedY / cellSize))
        
        guard row >= 0 && row < boardSize && col >= 0 && col < boardSize else {
            return nil
        }
        
        // Check dead zone
        let nearestX = CGFloat(col) * cellSize
        let nearestY = CGFloat(row) * cellSize
        let distanceX = abs(normalizedX - nearestX)
        let distanceY = abs(normalizedY - nearestY)
        let deadZonePixels = cellSize * deadZone
        
        if distanceX > deadZonePixels || distanceY > deadZonePixels {
            return nil
        }
        
        logger.debug("pressed at point \(row) \(col)")
        return Position(row: row, col: col)
    }
    
    private func positionToPoint(_ position: Position) -> CGPoint {
        CGPoint(x: CGFloat(position.col) * cellSize + startX,
                y: CGFloat(position.row) * cellSize + startY)
    }
    
    // MARK: - helpers
    
    func setGame(_ game: GoGame) {
        self.game = game
    }
}
