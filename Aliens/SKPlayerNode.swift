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
    private var healthBar: SKShapeNode!
    public var gameScene: GameScene!
    public var gameSceneViewController: UIViewController!

    // Required by Swift
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
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
        removeAllChildren()
        removeAllActions()
        isPaused = true
    }
    
    public func createHealthBar() {
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 10))
        
        // TODO: Make smaller on health loss
        healthBar.fillColor = UIColor.green
        healthBar.position = CGPoint(x: 0, y: -175)
        addChild(healthBar)
    }
    
    private func createHealthBar(width: Float) {
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: CGFloat(width), height: 10))
        
        // TODO: Change size on health loss
        newHealthBar.fillColor = UIColor.green
        newHealthBar.position = CGPoint(x: 0, y: -175)
        addChild(newHealthBar)
        healthBar.removeFromParent()
        healthBar = newHealthBar
    }
    
    public func takeDamage(_ damage: Int) {
        health -= damage
        if health > 0 {
            let percent = Float(health) / 100
            createHealthBar(width: Float(200) * percent)
        } else if health <= 0 {
            healthBar.removeFromParent()
        }
    }
    
}
