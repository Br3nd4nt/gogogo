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
}
