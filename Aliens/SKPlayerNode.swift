//
//  SKPlayerNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 8/2/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit

class SKPlayerNode: SKSpriteNode {
    
    public var health: Int = 100
    
    // Just overriding two initializer functions in order to satisfy the superclass
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    // See above
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func coinGravity() {
        let gravityNode = SKFieldNode.radialGravityField()
        gravityNode.categoryBitMask = 0b1 << 6
        addChild(gravityNode)
        physicsBody?.fieldBitMask = 0
    }
    
    public func die() {
        if health > 0  {
            return
        }
    }
    
}
