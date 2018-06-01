/*
 
  SKEnemyNode.swift
  Aliens

  Created by Ibrahim Syed on 7/29/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

import SpriteKit
import simd

class SKEnemyNode: SKCharacterNode {
    
    private var timer: Timer!
    public var fireRate = Double(arc4random_uniform(17) + 15) / Double(10)
    
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
            let laser = createLaser()
            self.parent?.addChild(laser)
            let distance = laser.position.y > 0 ? laser.position.y + 750 : 750 - abs(laser.position.y)
            let laserActionSequence = SKAction.sequence([SKAction.move(to: CGPoint(x: laser.position.x, y: -750), duration: TimeInterval(distance / 250)), SKAction.removeFromParent()])
            laser.run(laserActionSequence, withKey: "laserShoot")
        }
    }
    
    private func createLaser() -> SKWeaponNode {
        let laser = SKWeaponNode(imageNamed: "LaserDown", damage: 2)
        laser.position = CGPoint(x: self.position.x, y: self.position.y - 100)
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.allowsRotation = false
        laser.physicsBody?.categoryBitMask = GamePhysicsDelegate.enemyLaserCat
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.contactTestBitMask = GamePhysicsDelegate.playerCat
        laser.physicsBody?.fieldBitMask = 0
        return laser
    }
    
}
