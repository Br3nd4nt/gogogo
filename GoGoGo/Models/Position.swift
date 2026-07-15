//
//  Position.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//


struct Position: Hashable {
    let row: Int
    let col: Int
    
    var description: String {
        "(\(row) \(col)"
    }
}

extension Position {
    func neighbors(boardSize: Int) -> [Position] {
        var result: [Position] = []
        if row > 0 { result.append(Position(row: row - 1, col: col)) }
        if row < boardSize - 1 { result.append(Position(row: row + 1, col: col)) }
        if col > 0 { result.append(Position(row: row, col: col - 1)) }
        if col < boardSize - 1 { result.append(Position(row: row, col: col + 1)) }
        return result
    }
}
