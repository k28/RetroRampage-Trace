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
    public private(set) var player: Player!
    public private(set) var monsters: [Monster]
    public private(set) var effects: [Effect]
    
    public init(map: Tilemap) {
        self.map = map
        self.monsters = []
        self.effects = []
        // オブジェクトの位置を初期化
        reset()
    }
}

public extension World {
    var size: Vector {
        return map.size
    }
    
    mutating func reset() {
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
    
    /// 状態を更新する
    /// - Parameters:
    ///   - timeStep: 時間の経過
    ///   - input: 操作の入力
    mutating func update(timeStep: Double, input: Input) {
        // Update effects
        effects = effects.compactMap { effect in
            if effect.isCompleted {
                return nil
            }
            var effect = effect
            effect.time += timeStep
            return effect
        }
        
        // Update player
        if player.isDead == false {
            var player = self.player!   // playerのupdateメソッドでworldを渡す為に、playerをコピーしてそれを使う
            player.animation.time += timeStep
            player.update(with: input, in: &self)
            player.position += player.velocity * timeStep
            self.player = player
        } else if effects.isEmpty {
            reset()
            effects.append(Effect(type: .fadeIn, color: .red, duration: 0.5))
            return
        }
        
        // Update monsters
        for i in 0 ..< monsters.count {
            var monster = monsters[i]
            monster.animation.time += timeStep
            monster.update(in: &self)
            monster.position += monster.velocity * timeStep
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
        let ray = Ray(origin: player.position, direction: player.direction)
        return monsters.map { $0.billboard(for: ray) }
    }
    
    mutating func hurtPlayer(_ damage: Double) {
        if player.isDead {
            return
        }
        
        let color = Color(r: 255, g: 0, b: 0, a: 191)   // 191 is 75% opacity (255 * 0.75)
        effects.append(Effect(type: .fadeIn, color: color, duration: 0.2))
        player.health -= damage
        player.velocity = Vector(x: 0, y: 0)
        
        if player.isDead {
            effects.append(Effect(type: .fizzleOut, color: .red, duration: 2))
        }
    }
    
    mutating func hurtMonster(at index: Int, damage: Double) {
        var monster = monsters[index]
        if monster.isDead {
            return
        }
        
        monster.health -= damage
        monster.velocity = Vector(x: 0, y: 0)
        if monster.isDead {
            monster.state = .dead
            monster.animation = .monsterDeath
        } else {
            monster.state = .hurt
            monster.animation = .monsterHurt
        }
        monsters[index] = monster   // 最後にオブジェクトを更新する(structなので)
    }
    
    func hitTest(_ ray: Ray) -> Int? {
        let wallHit = map.hitTest(ray)
        var distance = (wallHit - ray.origin).length
        
        var result: Int? = nil
        for i in monsters.indices {
            guard let hit = monsters[i].hitTest(ray) else {
                continue
            }
            let hitDistance = (hit - ray.origin).length
            guard hitDistance < distance else {
                continue
            }
            result = i
            distance = hitDistance
        }
        return result
    }
}
