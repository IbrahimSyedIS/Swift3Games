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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        preparePhysicsBody()
        run(SKAction.repeatForever(SKAction.animate(with: [getText("Gold_21"), getText("Gold_22"), getText("Gold_23"), getText("Gold_24"),
                                                           getText("Gold_25"), getText("Gold_26"), getText("Gold_27"), getText("Gold_28"),
                                                           getText("Gold_29"), getText("Gold_30")], timePerFrame: 0.1)))
        value = Int(arc4random_uniform(12))
    }
    
    private func getText(_ name: String) -> SKTexture {
        return SKTexture(imageNamed: name)
    }
    
    private func preparePhysicsBody() {
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GamePhysicsDelegate.itemCat
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = GamePhysicsDelegate.playerCat
        self.physicsBody?.fieldBitMask = 0b1 << 6
    }
    
}
