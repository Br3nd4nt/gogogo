//
//  Stone.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//

enum Stone: Int {
    case empty = 0
    case black = 1
    case white = 2
    case offboard = 7
    case liberty = 8
    
    var opposite: Stone {
        switch self {
        case .black: return .white
        case .white: return .black
        default: return .empty
        }
    }
}
