//
//  ZobristHashing.swift
//  GoGoGo
//
//  Created by br3nd4nt on 15.07.2026.
//

struct ZobristHashing {
    private(set) var hash: UInt64 = 0
    private var hashTable: [UInt64] = []
    private let size: Int
    init(size: Int = 9) {
        self.size = size
        initialiseHashTable()
    }
    
    private mutating func initialiseHashTable() {
        let tableSize = size * size * 2
        for _ in 0..<tableSize {
            self.hashTable.append(UInt64.random(in: 0..<UInt64.max))
        }
    }
    
    mutating func updateHash(at position: Position, with stone: Stone) {
        // assuming that stone is either black (1) or white (2)
        let page = stone.rawValue - 1
        let index = page * size * size + position.row * size + position.col
        hash ^= hashTable[index]
    }
    
    // ?????
    mutating func setHash(_ hash: UInt64) {
        self.hash = hash
    }
    
    func copy() -> ZobristHashing {
        var copy = ZobristHashing(size: size)
        copy.hash = self.hash
        copy.hashTable = self.hashTable
        return copy
    }
}
