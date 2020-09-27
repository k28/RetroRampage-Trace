//
//  Player.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/22.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

/// Act as our abator in the game
public struct Player: Actor {
    public let speed: Double = 3
    public let turningSpeed: Double = .pi
    public let radius: Double = 0.25
    public var position: Vector
    public var velocity: Vector
    public var direction: Vector
    public var health: Double
    
    public init(position: Vector) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
        self.direction = Vector(x: 1, y: 0)
        self.health = 100
    }
}

public extension Player {
    var isDead: Bool {
        return health <= 0
    }
}
