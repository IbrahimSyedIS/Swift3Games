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
        removeAllChildren()
        removeAllActions()
        isPaused = true
    }
    
    // Function for creating the health bar of the SKEnemyNode
    public func createHealthBar() {
        // Creating a health bar for the enemy
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 10))
        
        // Filling it green **COME BACK HERE TO UPDATE HEALTH BAR SIZE WHEN HEALTH GOES DOWN**
        healthBar.fillColor = UIColor.green
        
        // Putting the health bar at the position of the enemys
        healthBar.position = CGPoint(x: 0, y: -175)
        
        // Adding the health bar as a child of the enemy
        addChild(healthBar)
    }
    
    private func createHealthBar(width: Float) {
        
        // Creating a health bar for the enemy
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: CGFloat(width), height: 10))
        
        // Filling it green **COME BACK HERE TO UPDATE HEALTH BAR SIZE WHEN HEALTH GOES DOWN**
        newHealthBar.fillColor = UIColor.green
        
        // Putting the health bar at the position of the enemys
        newHealthBar.position = CGPoint(x: 0, y: -175)
        
        // Adding the health bar as a child of the enemy
        addChild(newHealthBar)
        
        // Removing old health bar
        healthBar.removeFromParent()
        
        // Updating the instance variable
        healthBar = newHealthBar
    }
    
    // Function for updating the size of the health bar after damage has been taken
    public func takeDamage(_ damage: Int) {
        
        // Updating health
        health -= damage
        
        // As long as health is above zero...
        if health > 0 {
            
            // ...Calculate the percent of the health bar remaning, and then...
            let percent = Float(health) / 100
            
            // ...Create a new health bar with a new size adjusted for the new health
            createHealthBar(width: Float(200) * percent)
        } else if health <= 0 {
            healthBar.removeFromParent()
        }
    }
    
}
