//
//  GoGameScene.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//
import SpriteKit
import GameplayKit

class GoGameScene: SKScene {
    private var game: GoGame = GoGame()
    private var boardNode: SKNode = SKNode()
    
    private let boardSize: Int = 9
    private var cellSize: CGFloat = 10
    private let stoneRadius: CGFloat = 18
    private let boardPadding: CGFloat = 10
    
    private var verticalLines: [SKShapeNode] = []
    private var horizontalLines: [SKShapeNode] = []
    private var starPoints: [SKShapeNode] = []
    private var elementsCreated = false
    
    // MARK: - Initialization
    override init(size: CGSize) {
        super.init(size: size)
        game = GoGame(size: boardSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        game = GoGame(size: boardSize)
    }
    
    // MARK: - Scene Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()
        setupBoardIfNeeded()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupBoardIfNeeded()
    }
    
    private func setupBoardIfNeeded() {
        guard !elementsCreated else { return }
        
        // Add board node if not already added
        if boardNode.parent == nil {
            addChild(boardNode)
        }
        
        createBoardElements()
        layoutBoard()
    }
    
    // MARK: - Create Board Elements (called once)
    private func createBoardElements() {
        guard !elementsCreated else { return }
        elementsCreated = true
        
        // vertical lines
        for _ in 0..<boardSize {
            let vLine = SKShapeNode()
            vLine.strokeColor = .black
            vLine.lineWidth = 1.5
            boardNode.addChild(vLine)
            verticalLines.append(vLine)
        }
        
        // horizontal lines
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
            setupBoardIfNeeded()
        } else {
            layoutBoard()
        }
    }
    
    // MARK: - Layout
    private func layoutBoard() {
        guard elementsCreated else { return }
        
        let minDimension = min(size.width, size.height)
        let availableSize = minDimension - boardPadding * 2
        cellSize = max(availableSize / CGFloat(boardSize), 10)
        
        repositionBoard()
    }
    
    private func repositionBoard() {
        let boardSide = CGFloat(boardSize - 1) * cellSize
        let startX = (size.width - boardSide) / 2
        let startY = (size.height - boardSide) / 2
        
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
}
