//
//  World.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/22.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct World {
    public let map: Tilemap
    public var player: Player!
    
    public init(map: Tilemap) {
        self.map = map
        
        // オブジェクトの位置を初期化
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let position = Vector(x: Double(x) + 0.5, y: Double(y) + 0.5)
                let thing = map.things[y * map.width + x]
                switch thing {
                case .nothing:
                    break
                case .player:
                    self.player = Player(position: position)
                }
            }
        }
    }
}

public extension World {
    var size: Vector {
        return map.size
    }
    
    mutating func update(timeStep: Double, input: Input) {
        player.velocity = input.velocity * player.speed
        player.position += player.velocity * timeStep
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }
}
