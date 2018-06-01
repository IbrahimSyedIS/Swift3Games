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
    
    // Required by Swift
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        let coinAnimationTextures = [SKTexture(imageNamed: "Gold_21"), SKTexture(imageNamed: "Gold_22"), SKTexture(imageNamed: "Gold_23"),
                                     SKTexture(imageNamed: "Gold_24"), SKTexture(imageNamed: "Gold_25"), SKTexture(imageNamed: "Gold_26"),
                                     SKTexture(imageNamed: "Gold_27"), SKTexture(imageNamed: "Gold_28"), SKTexture(imageNamed: "Gold_29"),
                                     SKTexture(imageNamed: "Gold_30")]
        let coinAnimation = SKAction.repeatForever(SKAction.animate(with: coinAnimationTextures, timePerFrame: 0.1))
        run(coinAnimation)
        value = Int(arc4random_uniform(12))
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GamePhysicsDelegate.itemCat
        self.physicsBody?.collisionBitMask = GamePhysicsDelegate.playerCat
        self.physicsBody?.contactTestBitMask = GamePhysicsDelegate.playerCat
        self.physicsBody?.fieldBitMask = 0b1 << 6
    }
    
}
