//
//  SKCoinNode.swift
//  
//
//  Created by Ibrahim Syed on 7/31/17.
//
//

import SpriteKit
import simd

class SKCoinNode: SKSpriteNode {
    
    public var value: Int!
    
    public func initCoin() {
        value = Int(arc4random_uniform(12))
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GamePhysicsDelegate.ITEM_CAT
        self.physicsBody?.collisionBitMask = GamePhysicsDelegate.PLAYER_CAT
        self.physicsBody?.contactTestBitMask = GamePhysicsDelegate.PLAYER_CAT
        self.physicsBody?.fieldBitMask = 0b1 << 6
    }
    
    // Just overriding two initializer functions in order to satisfy the superclass
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
