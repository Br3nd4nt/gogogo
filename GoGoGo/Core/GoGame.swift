//
//  GoGame.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//

import Combine
import Puppy
import Foundation

class GoGame: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger
    
    @Published var boardSize: Int
    @Published var board: [[Stone]]
    @Published var currentPlayer: Stone = .black
    @Published var capturedStones: [Stone: Int] = [.black: 0, .white: 0]
    @Published var moveHistory: [Position] = []
    @Published var lastMove: Position?
    @Published var isGameOver: Bool = false
    @Published var previousTurnPass: Bool = false
    
    // State hashing for Ko detection
    private var hasher: ZobristHashing
    private var stateHistory: Set<UInt64> = []
    private var currentStateHash: UInt64 = 0
    
    init(size: Int = 9) {
        self.boardSize = size
        hasher = ZobristHashing(size: size)
        self.board = Array(repeating: Array(repeating: .empty, count: size), count: size)
        logger.info("game initialized (size: \(size)x\(size)")
        updateStateHistory()
    }
    
    init() {
        self.boardSize = 0
        self.board = []
        self.isGameOver = true
        hasher = ZobristHashing(size: 0)
    }
    
    // MARK: - Core Logic
    
    func placeStone(at position: Position) -> Bool {
        guard !isGameOver else { return false }
        guard isValidMove(at: position) else {
            logger.debug("move \(position) is invalid")
            return false
        }
        
        let previousBoard = board
        let previousCaptured = capturedStones
        let previousHasher = hasher // Save the hasher state
        let previousStateHash = currentStateHash
        
        setStone(at: position, to: currentPlayer)
        
        if isSuicideMove(at: position) {
            board = previousBoard
            capturedStones = previousCaptured
            hasher = previousHasher
            currentStateHash = previousStateHash
            return false
        }
        
        let capturedInMove = captureAdjesentStones(at: position)
        
        if checkKo() {
            logger.debug("move \(position) resulted in Ko")
            logger.debug("move hash: \(currentStateHash)")
            board = previousBoard
            capturedStones = previousCaptured
            hasher = previousHasher
            currentStateHash = previousStateHash
            return false
        }
        
        capturedStones[currentPlayer.opposite]? += capturedInMove.count
        
        moveHistory.append(position)
        changePlayer()
        updateStateHistory()
        previousTurnPass = false
        return true
    }
    
    private func isValidMove(at position: Position) -> Bool {
        return position.row >= 0 && position.row < boardSize && position.col >= 0 && position.col < boardSize && board[position.row][position.col] == .empty
    }
    
    private func isSuicideMove(at position: Position) -> Bool {
        // move is suicide when:
        // 1. played stone's group has no liberties
        // 2. AND while playing this move no opponent's stone was captured
        // we are assuming that the board currently have the move played (board[position] != empty)
        
        let group = getGroup(at: position)
        if hasLiberties(for: group) {
            logger.debug("\(position) has liberties")
            return false
        }
        
        let opponent = currentPlayer.opposite
        
        for neighbor in position.neighbors(boardSize: boardSize) {
            if getStone(at: neighbor) == opponent {
                if !hasLiberties(at: neighbor) {
                    logger.debug("move \(position) is capturing")
                    return false
                }
            }
        }
        logger.debug("move \(position) is suicide")
        return true
    }
    
    private func captureAdjesentStones(at position: Position) -> [Position] {
        let opponent = currentPlayer.opposite
        var captured: [Position] = []
        
        for neighbor in position.neighbors(boardSize: boardSize) {
            if getStone(at: neighbor) == opponent {
                let opponentGroup = getGroup(at: neighbor)
                if !hasLiberties(for: opponentGroup) {
                    captured.append(contentsOf: opponentGroup)
                }
            }
        }
        
        for pos in captured {
            let stone = board[pos.row][pos.col]
            hasher.updateHash(at: pos, with: stone)
            board[pos.row][pos.col] = .empty
        }
        
        return captured
    }
    
    private func changePlayer() {
        currentPlayer = currentPlayer.opposite
    }
    
    func pass() -> Bool {
        if !previousTurnPass {
            previousTurnPass = true
            changePlayer()
        } else {
            endGame()
        }
        
        return true
    }
    
    private func endGame() {
        isGameOver = true
    }
    
    func reset() {
        board = Array(repeating: Array(repeating: .empty, count: boardSize), count: boardSize)
        currentPlayer = .black
        capturedStones = [.black: 0, .white: 0]
        moveHistory = []
        lastMove = nil
        isGameOver = false
        previousTurnPass = false
        
        hasher = ZobristHashing(size: boardSize)
        stateHistory = []
        updateStateHistory()
        
        objectWillChange.send()
        
        logger.info("Game reset")
    }
    
    // MARK: - Group detection
    
    private func getGroup(at position: Position) -> [Position] {
        let stone = getStone(at: position)
        guard stone != .empty else { return [] }
        var group: [Position] = []
        var visited: Set<Position> = []
        var queue = [position]
        while !queue.isEmpty {
            let pos = queue.removeFirst()
            if visited.contains(pos) { continue }
            visited.insert(pos)
            group.append(pos)
            
            for neighbor in pos.neighbors(boardSize: boardSize) {
                if !visited.contains(neighbor) && getStone(at: neighbor) == stone {
                    queue.append(neighbor)
                }
            }
        }
        
        return group
    }
    
    private func getGroupWithColor(at position: Position, color: Stone) -> [Position] {
        guard board[position.row][position.col] == color else { return [] }
        return getGroup(at: position)
    }
    
    // MARK: - Liberty managment
    
    private func getLiberties(for group: [Position]) -> [Position] {
        var liberties: Set<Position> = []
        for pos in group {
            for neighbor in pos.neighbors(boardSize: boardSize) {
                if getStone(at: neighbor) == .empty {
                    liberties.insert(neighbor)
                }
            }
        }
        return Array(liberties)
    }
    
    private func hasLiberties(for group: [Position]) -> Bool {
        return !getLiberties(for: group).isEmpty
    }
    
    private func hasLiberties(at position: Position) -> Bool {
        let group = getGroup(at: position)
        return hasLiberties(for: group)
    }
    
    // MARK: - Scoring
    
    func calculateScore() -> [Stone: Int] {
        var result: [Stone: Int] = [
            .black: capturedStones[.white] ?? 0,
            .white: capturedStones[.black] ?? 0,
        ]
        var visited: Set<Position> = []
        
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let pos = Position(row: row, col: col)
                if visited.contains(pos) { continue }
                let stone = getStone(at: pos)
                if stone == .empty {
                    let territory = getTerritory(at: pos)
                    visited.formUnion(territory)
                    
                    let owner = getTerritoryOwner(territory)
                    if owner == .black {
                        result[.black]? += territory.count
                    } else if owner == .white {
                        result[.white]? += territory.count
                    }
                } else {
                    visited.insert(pos)
                    if stone == .black {
                        result[.black]? += 1
                    } else if stone == .white {
                        result[.white]? += 1
                    }
                }
            }
        }
        
        return result
    }
    
    func getTerritory(at position: Position) -> [Position] {
        guard getStone(at: position) == .empty else { return [] }
        
        var territory: [Position] = []
        var visited: Set<Position> = []
        var queue = [position]
        while !queue.isEmpty {
            let pos = queue.removeFirst()
            if visited.contains(pos) { continue }
            visited.insert(pos)
            territory.append(pos)
            
            for neighbor in pos.neighbors(boardSize: boardSize) {
                if !visited.contains(neighbor) && getStone(at: neighbor) == .empty {
                    queue.append(neighbor)
                }
            }
        }
        
        return territory
        
    }
    
    func getTerritoryOwner(_ territory: [Position]) -> Stone {
        var blackOwning = false
        var whiteOwning = false
        
        for pos in territory {
            for neighbor in pos.neighbors(boardSize: boardSize) {
                let stone = getStone(at: neighbor)
                if stone == .black {
                    blackOwning = true
                } else if stone == .white {
                    whiteOwning = true
                }
                
                if whiteOwning && blackOwning {
                    return .empty
                }
            }
        }
        if blackOwning {
            return .black
        }
        if whiteOwning {
            return .white
        }
        return .empty
    }
    
    // MARK: - Hashing
    
    private func getCurrentHash() -> UInt64 {
        hasher.hash
    }
    
    private func updateHasher(_ pos: Position) {
        let stone = currentPlayer
        hasher.updateHash(at: pos, with: stone)
    }
    
    private func checkKo() -> Bool {
        logger.debug("checking ko:")
        logger.debug("current hash: \(getCurrentHash())")
        logger.debug("hash history: \(stateHistory)")
        return isStateRepeated()
    }
    
    private func isStateRepeated() -> Bool {
        return stateHistory.contains(getCurrentHash())
    }
    
    private func updateStateHistory() {
        stateHistory.insert(getCurrentHash())
    }
    
    private func resetStateHistory() {
        stateHistory.removeAll()
    }
    
    // MARK: - Utility methods
    
    private func setStone(at position: Position, to stone: Stone) {
        let oldStone = self.board[position.row][position.col]
        if oldStone != stone {
            if oldStone != .empty {
                hasher.updateHash(at: position, with: oldStone)
            }
            
            board[position.row][position.col] = stone
            if stone != .empty {
                hasher.updateHash(at: position, with: stone)
            }
            currentStateHash = getCurrentHash()
        }
    }
    
    func getStone(at position: Position) -> Stone {
        guard position.row >= 0 && position.row < boardSize,
              position.col >= 0 && position.col < boardSize else {
            return .empty
        }
        return board[position.row][position.col]
    }
    
    private func printBoard() {
        print("  " + (0..<boardSize).map { String($0) }.joined(separator: " "))
        for row in (0..<boardSize).reversed() {
            var line = "\(row) "
            for col in 0..<boardSize {
                let stone = board[row][col]
                line += stone.description + " "
            }
            print(line)
        }
        print("Current player: \(currentPlayer)")
        print("Hash: \(getCurrentHash())")
        print("hash history: \(stateHistory)")
    }
}
