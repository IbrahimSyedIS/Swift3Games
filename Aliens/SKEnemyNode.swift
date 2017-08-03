/*
 
  SKEnemyNode.swift
  Aliens

  Created by Ibrahim Syed on 7/29/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

//Importing the essentials
import SpriteKit
import simd

// I had to make my own SKSpriteNode in order to get health working in the game, this is literally the only function of this file, Health
class SKEnemyNode: SKSpriteNode {
    
    // Private variable that holds the shape node for the health bar
    private var healthBar: SKShapeNode!
    private var timer: Timer!
    
    // This is the variable that holds the health value of the SKEnemyNode at hand
    public var health: Int = 100
    
    public var fireRate = Double(arc4random_uniform(17) + 15) / Double(10)
    
    // Just overriding two initializer functions in order to satisfy the superclass
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    // See above
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Function for creating the health bar of the SKEnemyNode
    public func createHealthBar() {
        // Creating a health bar for the enemy
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 10))
        
        // Filling it green **COME BACK HERE TO UPDATE HEALTH BAR SIZE WHEN HEALTH GOES DOWN**
        healthBar.fillColor = UIColor.green
        
        // Putting the health bar at the position of the enemys
        healthBar.position = CGPoint(x: 0, y: 275)
        
        // Adding the health bar as a child of the enemy
        addChild(healthBar)
    }
    
    private func createHealthBar(width: Float) {
        
        // Creating a health bar for the enemy
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: CGFloat(width), height: 10))
        
        // Filling it green **COME BACK HERE TO UPDATE HEALTH BAR SIZE WHEN HEALTH GOES DOWN**
        newHealthBar.fillColor = UIColor.green
        
        // Putting the health bar at the position of the enemys
        newHealthBar.position = CGPoint(x: 0, y: 275)
        
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
    
    public func autoFire() {
        timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true, block: { (nil) in
            
            // The function that tells the ship to fire is called
            self.fireLaser()
        })
    }
    
    public func pauseEnemy() {
        timer.invalidate()
    }
    
    // Function for enemy to fire laser
    private func fireLaser() {
        if self.parent != nil && self.health > 0 {
            let laser = SKSpriteNode(imageNamed: "LaserDown")
            laser.position = CGPoint(x: self.position.x, y: self.position.y - 100)
            laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
            laser.physicsBody?.affectedByGravity = false
            laser.physicsBody?.allowsRotation = false
            laser.physicsBody?.categoryBitMask = GamePhysicsDelegate.ENEMY_LASER_CAT
            laser.physicsBody?.collisionBitMask = 0
            laser.physicsBody?.contactTestBitMask = GamePhysicsDelegate.PLAYER_CAT
            laser.physicsBody?.fieldBitMask = 0
            self.parent?.addChild(laser)
            let distance = laser.position.y > 0 ? laser.position.y + 750 : 750 - abs(laser.position.y)
            let laserActionSequence = SKAction.sequence([SKAction.move(to: CGPoint(x: laser.position.x, y: -750), duration: TimeInterval(distance / 250)), SKAction.removeFromParent()])
            laser.run(laserActionSequence)
        }
    }
    
}
