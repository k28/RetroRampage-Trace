//
//  Tile.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/23.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public enum Tile: Int, Decodable {
        // Floors
        case floor = 0
        case crackFloor = 4
        
        // Walls
        case wall = 1
        case crackWall = 2
        case slimeWall = 3
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall, .crackWall, .slimeWall:
            return true
        case .floor, .crackFloor:
            return false
        }
    }
    
    var textures: [Texture] {
        switch self {
        case .floor:
            return [.floor, .ceiling]
        case .crackFloor:
            return [.crackFloor, .ceiling]
        case .wall:
            return [.wall, .wall2]
        case .crackWall:
            return [.crackWall, .crackWall2]
        case .slimeWall:
            return [.slimeWall, .slimeWall2]
        }
    }
}
