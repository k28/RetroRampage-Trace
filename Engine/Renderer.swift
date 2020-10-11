//
//  Renderer.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/21.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct Renderer {
    public private(set) var bitmap: Bitmap
    private let textures: Textures
    private let fizzle = (0 ..< 10000).shuffled()
    
    public init(width: Int, height: Int, textures: Textures) {
        self.bitmap = Bitmap(width: width, height: height, color: .black)
        self.textures = textures
    }
}

public extension Renderer {
    mutating func draw(_ world: World) {
        // Draw view plane
        let focalLength = 1.0   // 焦点距離
        let viewWidth = Double(bitmap.width) / Double(bitmap.height)
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2

        // Sort sprites by distance
        var spritesByDistance: [(distance: Double, sprite: Billboard)] = []
        for sprite in world.sprites {
            let spriteDistance = (sprite.start - world.player.position).length
            spritesByDistance.append((distance: spriteDistance, sprite: sprite))
        }
        spritesByDistance.sort { $0.distance > $1.distance }    // 後ろの物から描画するために遠い順にソートする
        
        // Cast rays
        let columns = bitmap.width
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart
        for x in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)   // このループで注目するRay
            let end = world.map.hitTest(ray)
            let wallDistance = (end - ray.origin).length    // 壁までの距離
            
            // Draw wall
            let wallHeight = 1.0
            let distanceRatio = viewPlaneDistance / focalLength
            let perpendicular = wallDistance / distanceRatio
            let height = wallHeight * focalLength / perpendicular * Double(bitmap.height)
            
            let wallTexture: Bitmap
            let wallX: Double
            let tile = world.map.tile(at: end, from: ray.direction)
            if end.x.rounded(.down) == end.x {
                wallTexture = textures[tile.textures[0]]
                wallX = end.y - end.y.rounded(.down)
            } else {
                wallTexture = textures[tile.textures[1]]
                wallX = end.x - end.x.rounded(.down)
            }
            let textureX = Int(wallX * Double(wallTexture.width))
            let wallStart = Vector(x: Double(x), y: (Double(bitmap.height) - height) / 2 - 0.001)
            bitmap.drawColumn(textureX, of: wallTexture, at: wallStart, height: height)
            
            // Draw floor and ceiling
            var floorTile: Tile!
            var floorTexture, ceilingTexture: Bitmap!
            let floorStart = Int(wallStart.y + height) + 1
            for y in min(floorStart, bitmap.height) ..< bitmap.height {
                let normalizedY = (Double(y) / Double(bitmap.height)) * 2 - 1
                let perpendicular = wallHeight * focalLength / normalizedY
                let distance = perpendicular * distanceRatio
                let mapPosition = ray.origin + ray.direction * distance
                let tileX = mapPosition.x.rounded(.down), tileY = mapPosition.y.rounded(.down)
                let tile = world.map[Int(tileX), Int(tileY)]
                if tile != floorTile {
                    floorTexture = textures[tile.textures[0]]
                    ceilingTexture = textures[tile.textures[1]]
                    floorTile = tile
                }
                let textureX = mapPosition.x - tileX, textureY = mapPosition.y - tileY
                bitmap[x, y] = floorTexture[normalized: textureX, textureY]
                bitmap[x, bitmap.height - 1 - y] = ceilingTexture[normalized: textureX, textureY]
            }
            
            // Draw sprites
            for (_, sprite) in spritesByDistance {
                guard let hit = sprite.hitTest(ray) else {
                    continue
                }
                let spriteDistance = (hit - ray.origin).length
                if spriteDistance > wallDistance {
                    continue
                }
                let perpendicular = spriteDistance / distanceRatio
                let height = wallHeight / perpendicular * Double(bitmap.height)
                let spriteX = (hit - sprite.start).length / sprite.length
                let spriteTexture = textures[sprite.texture]
                let textureX = min(Int(spriteX * Double(spriteTexture.width)), spriteTexture.width - 1)
                let start = Vector(x: Double(x), y: (Double(bitmap.height) - height) / 2 + 0.001)
                bitmap.drawColumn(textureX, of: spriteTexture, at: start, height: height)
            }
            
            columnPosition += step
        }
        
        // Player weapon
        let screenHeight = Double(bitmap.height)
        bitmap.drawImage(
            textures[world.player.animation.texture],
            at: Vector(x: Double(bitmap.width) / 2 - screenHeight / 2, y: 0),
            size: Vector(x: screenHeight, y: screenHeight))
        
        // Effects
        for effect in world.effects {
            switch effect.type {
            case .fadeIn:
                bitmap.tint(with: effect.color, opacity: 1 - effect.progress)
            case .fadeOut:
                bitmap.tint(with: effect.color, opacity: effect.progress)
            case .fizzleOut:
                let threshold = Int(effect.progress * Double(fizzle.count))
                for x in 0 ..< bitmap.width {
                    for y in 0 ..< bitmap.height {
                        let granularity = 4
                        let index = y / granularity * bitmap.width + x / granularity
                        let fizzledIndex = fizzle[index % fizzle.count]
                        if fizzledIndex <= threshold {
                            bitmap[x, y] = effect.color
                        }
                    }
                }
            }
        }
    }
    
    /// 2Dのマップを描画していた頃のdrawメソッド
    /// - Parameter world: world
    mutating func draw2D(_ world: World) {
        // calculate relative scale between world units and pixcels
        let scale = Double(bitmap.height) / world.size.y
        
        // Draw map
        for y in 0 ..< world.map.height {
            for x in 0 ..< world.map.width where world.map[x, y].isWall {
                let rect = Rect(
                    min: Vector(x: Double(x), y: Double(y)) * scale,
                    max: Vector(x: Double(x + 1), y: Double(y + 1)) * scale
                )
                bitmap.fill(rect: rect, color: .white)
            }
        }
        
        // Draw player
        var rect = world.player.rect
        rect.min *= scale
        rect.max *= scale
        bitmap.fill(rect: rect, color: .blue)
        
        // Draw line of sight
        // let ray = Ray(origin: world.player.position, direction: world.player.direction)
        // let end = world.map.hitTest(ray)
        // bitmap.drawLine(from: world.player.position * scale, to: end * scale, color: .green)
        
        // Draw view plane
        let focalLength = 1.0   // 焦点距離
        let viewWidth = 1.0
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2
        let viewEnd = viewStart + viewPlane
        bitmap.drawLine(from: viewStart * scale, to: viewEnd * scale, color: .red)
        
        // Cast rays
        let columns = 10
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart
        for _ in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)
            var end = world.map.hitTest(ray)
            for splite in world.sprites {
                guard let hit = splite.hitTest(ray) else {
                    continue
                }
                let spliteDistance = (hit - ray.origin).length
                if spliteDistance > (end - ray.origin).length {
                    continue
                }
                end = hit
            }
            bitmap.drawLine(from: ray.origin * scale, to: end * scale, color: .green)
            columnPosition += step
        }
        
        // Draw sprites
        for line in world.sprites {
            bitmap.drawLine(from: line.start * scale, to: line.end * scale, color: .green)
        }
    }
}
