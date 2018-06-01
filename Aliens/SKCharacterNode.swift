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
    
    public var health: Int = 100
    private var healthBar: SKShapeNode!
    
    internal var timer: Timer!
    
    internal var fireRate = Double(arc4random_uniform(17) + 15) / Double(10)
    
    // Required by Swift
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func createHealthBar() {
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 10))
        healthBar.fillColor = UIColor.green
        healthBar.position = CGPoint(x: 0, y: -175)
        addChild(healthBar)
    }
    
    private func createHealthBar(width: Float) {
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: CGFloat(width), height: 10))
        newHealthBar.fillColor = UIColor.green
        newHealthBar.position = CGPoint(x: 0, y: -175)
        healthBar.removeFromParent()
        healthBar = newHealthBar
        addChild(healthBar)
    }
    
    public func takeDamage(_ damage: Int) {
        health -= damage
        if health <= 0 {
            healthBar.removeFromParent()
        } else {
            let percent = Float(health) / 100.0
            createHealthBar(width: 200.0 * percent)
        }
    }
    
    internal func pause() {
        timer.invalidate()
    }
    
    internal func autoFire() {
        timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true, block: { (nil) in
            self.fireLaser()
        })
    }
    
    internal func fireLaser() {
        if self.parent != nil && self.health > 0 {
            let laser = createLaser(imageNamed: "LaserDown")
            self.parent?.addChild(laser)
            let distance = laser.position.y > 0 ? laser.position.y + 750 : 750 - abs(laser.position.y)
            let laserActionSequence = SKAction.sequence([SKAction.move(to: CGPoint(x: laser.position.x, y: -750), duration: TimeInterval(distance / 250)), SKAction.removeFromParent()])
            laser.run(laserActionSequence, withKey: "laserShoot")
        }
    }
    
    public func getHealth() -> Int {
        return health
    }
    
    internal func createLaser(imageNamed: String) -> SKWeaponNode {
        let laser = SKWeaponNode(imageNamed: imageNamed)
        laser.setDamage(to: 2)
        laser.position = CGPoint(x: position.x, y: position.y - 100)
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.allowsRotation = false
        laser.physicsBody?.categoryBitMask = GamePhysicsDelegate.laserCat
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.contactTestBitMask = GamePhysicsDelegate.playerCat
        laser.physicsBody?.fieldBitMask = 0
        return laser
    }
    
    public func die() {
        
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
        
        // Make sure its a game scene
        if let gameScene = self.parent as? GameScene {
            
            // Update score
            gameScene.score += 100
            gameScene.gameViewController.updateScoreLabel()
        }
    }
}
