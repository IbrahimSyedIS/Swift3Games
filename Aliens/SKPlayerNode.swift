//
//  SKPlayerNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 8/2/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit

class SKPlayerNode: SKCharacterNode {
    
    private var moveSpeed: Int
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        moveSpeed = 625
        super.init(texture: texture, color: color, size: size)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        moveSpeed = 625
        super.init(coder: aDecoder)
    }
    
    public func getMoveSpeed() -> Int {
        return moveSpeed
    }
    
    public func coinGravity() {
        let gravityNode = SKFieldNode.radialGravityField()
        gravityNode.categoryBitMask = 0b1 << 6
        addChild(gravityNode)
        physicsBody?.fieldBitMask = 0
    }
    
    public func die() {
        removeAllChildren()
        removeAllActions()
        isPaused = true
    }
    
}
