//
//  SKSpriteSheet.swift
//  Aliens
//
//  Created by Ibrahim Syed on 8/1/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit

class SKSpriteSheet {
    
    private var spriteSheet: SKTexture!
    private var helperFileName: String!
    
    public init(named texture: SKTexture, with helper: String) {
        spriteSheet = texture
        helperFileName = helper
    }
    
}
