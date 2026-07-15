//
//  Stone.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//

import UIKit

enum Stone: Int {
    case empty = 0
    case black = 1
    case white = 2
    case marker = 4
    case offboard = 7
    case liberty = 8
    
    var opposite: Stone {
        switch self {
        case .black: return .white
        case .white: return .black
        default: return .empty
        }
    }
    
    var fillColor: UIColor {
        switch self {
        case .black: return .black
        case .white: return .white
        default: return .clear
        }
    }
    
    var strokeColor: UIColor {
        switch self {
        case .black: return .gray
        case .white: return .lightGray
        default: return .clear
        }
    }
    
    var description: String {
        switch self {
        case .black: return "B"
        case .white: return "W"
        default: return "."
        }
    }
}
