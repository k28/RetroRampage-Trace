//
//  Player.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/22.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public enum PlayerState {
    case idle
    case firing
}

/// Act as our abator in the game
public struct Player: Actor {
    public let speed: Double = 3
    public let turningSpeed: Double = .pi
    public let radius: Double = 0.25
    public var position: Vector
    public var velocity: Vector
    public var direction: Vector
    public var health: Double
    public var state: PlayerState = .idle
    public var animation: Animation = .pistolIdle
    public var attackCoolDown: Double = 0.25
    
    
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
    
    var canFire: Bool {
        switch state {
        case .idle:
            return true
        case .firing:
            return animation.time >= attackCoolDown
        }
    }
    
    mutating func update(with input: Input, in world: inout World) {
        direction = direction.rotated(by: input.rotation)
        velocity = direction * input.speed * speed
        
        if input.isFiring, canFire {
            state = .firing
            animation = .pistolFire
            let ray = Ray(origin: position, direction: direction)
            if let index = world.pickMoster(ray) {
                world.hurtMonster(at: index, damage: 10)
            }
        }

        switch state {
        case .idle:
            break
        case .firing:
            if animation.isCompleted {
                state = .idle
                animation = .pistolIdle
            }
        }
    }
}
