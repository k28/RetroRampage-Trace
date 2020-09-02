//
//  Textures.swift
//  Engine
//
//  Created by K.Hatano on 2020/09/01.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public enum Texture: String, CaseIterable {
    case wall, wall2
    case crackWall, crackWall2
    case slimeWall, slimeWall2
    case floor
    case crackFloor
    case ceiling
}

public struct Textures {
    private let textures: [Texture: Bitmap]
}

public extension Textures {
    init(loader: (String) -> Bitmap) {
        var textures = [Texture: Bitmap]()
        for texture in Texture.allCases {
            textures[texture] = loader(texture.rawValue)
        }
        self.init(textures: textures)
    }
    
    subscript(_ texture: Texture) -> Bitmap {
        return textures[texture]!
    }
}
