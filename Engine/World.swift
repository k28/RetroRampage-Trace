//
//  World.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/22.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

/// ゲームの世界を管理するクラス
public struct World {
    public let map: Tilemap
    public var player: Player!
    public var monsters: [Monster]
    
    public init(map: Tilemap) {
        self.map = map
        self.monsters = []
        
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
                case .monster:
                    self.monsters.append(Monster(position: position))
                }
            }
        }
    }
}

public extension World {
    var size: Vector {
        return map.size
    }
    
    /// 状態を更新する
    /// - Parameters:
    ///   - timeStep: 時間の経過
    ///   - input: 操作の入力
    mutating func update(timeStep: Double, input: Input) {
        player.direction = player.direction.rotated(by: input.rotation)
        player.velocity = player.direction * input.speed * player.speed
        player.position += player.velocity * timeStep
        
        // Update monsters
        for i in 0 ..< monsters.count {
            var monster = monsters[i]
            monster.update(in: self)
            monster.position += monster.velocity * timeStep
            monster.animation.time += timeStep
            monsters[i] = monster
        }

        // Handle collisions
        for i in monsters.indices {
            var monster = monsters[i]
            if let intersection = player.intersection(with: monster) {
                player.position -= intersection / 2
                monster.position += intersection / 2
            }
            
            for j in i + 1 ..< monsters.count {
                if let intersection = monster.intersection(with: monsters[j]) {
                    monster.position -= intersection / 2
                    monsters[j].position += intersection / 2
                }
            }
            
            // Monsterが壁にめり込まないようにする
            while let intersection = monster.intersection(with: map) {
                monster.position -= intersection
            }
            
            monsters[i] = monster
        }

        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }
    
    var sprites: [Billboard] {
        let spritePlane = player.direction.orthogonal
        return monsters.map { monster in
            Billboard(
                start: monster.position - spritePlane / 2,
                direction: spritePlane,
                length: 1,
                texture: monster.animation.texture
            )
        }
    }
}
