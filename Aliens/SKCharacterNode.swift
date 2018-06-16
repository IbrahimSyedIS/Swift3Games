//
//  SKCharacterNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 5/25/18.
//  Copyright © 2018 Ibrahim Syed. All rights reserved.
//

import Foundation
import SpriteKit

class SKCharacterNode: SKSpriteNode {
    
    private var health: Float!
    private var healthBar: SKShapeNode?
    private var moveSpeed: Int!
    private var fireRate: Double!
    
    internal var timer: Timer!
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setSpeed(to: 0)
        setHealth(to: 100)
        setFireRate(to: Double(arc4random_uniform(17) + 15) / Double(10))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setSpeed(to: 0)
        setHealth(to: 100)
        setFireRate(to: Double(arc4random_uniform(17) + 15) / Double(10))
    }
    
    public func setFireRate(to rate: Double) {
        fireRate = rate
    }
    
    public func getFireRate() -> Double {
        return fireRate
    }
    
    public func setSpeed(to speed: Int) {
        moveSpeed = speed
    }
    
    public func getMoveSpeed() -> Int {
        return moveSpeed
    }
    
    public func setHealth(to hp: Float) {
        health = hp
    }
    
    public func getHealth() -> Float {
        return health
    }
    
    /**
     # Health Bar
     
     Creates a health bar of a size based on the current health value
     
     - Postcondition: Health bar is added/updated to current size
     */
    public func updateHealthBar() {
        healthBar?.removeFromParent()
        if (getHealth() > 0) {
            healthBar = SKShapeNode(rectOf: CGSize(width: CGFloat(2.0 * getHealth()), height: 10))
            healthBar!.fillColor = UIColor.green
            healthBar!.position = CGPoint(x: 0, y: -size.height / 2)
            addChild(healthBar!)
        } else {
            die()
        }
    }
    
    /**
     # Take Damage
     
     Deducts from the character's health based on the given amount
     
     - Parameter damage: A Float value that is deducted from the health
     
     - Postcondition: Health is altered
     */
    public func takeDamage(_ damage: Float) {
        setHealth(to: getHealth() - damage)
        updateHealthBar()
    }
    
    /**
     # Pause
     
     Stops the autofire function of the character
     
     - Precondition: The character is active
     
     - Postcondition: The character is paused
     */
    internal func pause() {
        timer.invalidate()
        action(forKey: "enemyMove")?.speed = 0
        children.first?.action(forKey: "enemyMove")?.speed = 0
    }
    
    internal func autoFire() {
        timer = Timer.scheduledTimer(withTimeInterval: getFireRate(), repeats: true, block: { (nil) in
            self.fireLaser()
        })
    }
    
    internal func fireLaser() {
        if self.parent != nil && getHealth() > 0 {
            let laser = createLaser(imageNamed: "LaserDown")
            laser.xScale = 0.5
            laser.yScale = 0.5
            self.parent?.addChild(laser)
            let distance = laser.position.y > 0 ? laser.position.y + 750 : 750 - abs(laser.position.y)
            let laserActionSequence = SKAction.sequence([SKAction.move(to: CGPoint(x: laser.position.x, y: -750), duration: TimeInterval(distance / 250)),
                                                         SKAction.removeFromParent()])
            laser.run(laserActionSequence, withKey: "laserShoot")
        }
    }
    
    internal func createLaser(imageNamed: String) -> SKWeaponNode {
        let laser = SKWeaponNode(imageNamed: imageNamed)
        laser.setDamage(to: 15)
        laser.xScale = 0.5
        laser.yScale = 0.5
        laser.position = CGPoint(x: position.x, y: position.y - 100)
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
        laser.physicsBody!.affectedByGravity = false
        laser.physicsBody!.allowsRotation = false
        laser.physicsBody!.categoryBitMask = GamePhysicsDelegate.laserCat
        laser.physicsBody!.collisionBitMask = GamePhysicsDelegate.laserMask
        laser.physicsBody!.contactTestBitMask = GamePhysicsDelegate.laserMask
        laser.physicsBody!.fieldBitMask = 0
        return laser
    }
    
    public func die() {
        guard let gameScene = self.scene as! GameScene? else {
            return
        }
        // Make an explosion
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = position
        let sequence = SKAction.sequence([SKAction.run({ self.parent?.addChild(explosion) }),
                                          SKAction.wait(forDuration: TimeInterval(CGFloat(explosion.numParticlesToEmit) * explosion.particleLifetime)),
                                          SKAction.run({ explosion.removeFromParent() })])
        self.parent?.run(sequence)
        
        // Remove all the actions + parent
        removeAllActions()
        removeFromParent()
        
        // Update score
        gameScene.score += 100
        gameScene.gameViewController.updateScoreLabel()
    }
}
