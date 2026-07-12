//
//  GoGame.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//


import Foundation

class GoGame {
    let boardSize: Int
    var board: [[Stone]]
    var currentPlayer: Stone = .black
    var capturedStones: [Stone: Int] = [.black: 0, .white: 0]
    var moveHistory: [Position] = []
    var koPosition: Position?
    var lastMove: Position?
    var isGameOver: Bool = false
    
    init(size: Int = 9) {
        self.boardSize = size
        self.board = Array(repeating: Array(repeating: .empty, count: size), count: size)
    }
    
    init() {
        self.boardSize = 0
        self.board = []
        self.isGameOver = true
    }
    
    func placeStone(at position: Position) -> Bool {
        guard !isGameOver else { return false }
        guard board[position.row][position.col] == .empty else { return false }
        
        board[position.row][position.col] = currentPlayer
        moveHistory.append(position)
        currentPlayer = currentPlayer.opposite
        return true
    }
    
    func getStone(at position: Position) -> Stone {
        guard position.row >= 0 && position.row < boardSize,
              position.col >= 0 && position.col < boardSize else {
            return .empty
        }
        return board[position.row][position.col]
    }
}
