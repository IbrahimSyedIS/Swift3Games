/*
 
  SKEnemyNode.swift
  Aliens

  Created by Ibrahim Syed on 7/29/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

import SpriteKit
import simd

class SKEnemyNode: SKSpriteNode {
    
    private var healthBar: SKShapeNode!
    private var timer: Timer!
    public var health: Int = 100
    public var fireRate = Double(arc4random_uniform(17) + 15) / Double(10)
    
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
        healthBar.position = CGPoint(x: 0, y: 275)
        addChild(healthBar)
    }
    
    private func createHealthBar(width: Float) {
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: CGFloat(width), height: 10))
        newHealthBar.fillColor = UIColor.green
        newHealthBar.position = CGPoint(x: 0, y: 275)
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
    
    public func autoFire() {
        timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true, block: { (nil) in
            self.fireLaser()
        })
    }
    
    public func pauseEnemy() {
        timer.invalidate()
    }
    
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
            laser.run(laserActionSequence, withKey: "laserShoot")
        }
    }
    
}
