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
        
        // Cast rays
        let columns = bitmap.width
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart
        for x in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)
            let end = world.map.hitTest(ray)
            let wallDistance = (end - ray.origin).length
            
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
            columnPosition += step
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
            let end = world.map.hitTest(ray)
            bitmap.drawLine(from: ray.origin * scale, to: end * scale, color: .green)
            columnPosition += step
        }
    }
}
