//
//  SKPlayerNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 8/2/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit

class SKPlayerNode: SKCharacterNode {
    
    private var moveSpeed: Int
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        moveSpeed = 625
        super.init(texture: texture, color: color, size: size)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        moveSpeed = 625
        super.init(coder: aDecoder)
    }
    
    public func getMoveSpeed() -> Int {
        return moveSpeed
    }
    
    public func coinGravity() {
        let gravityNode = SKFieldNode.radialGravityField()
        gravityNode.categoryBitMask = 0b1 << 6
        addChild(gravityNode)
        physicsBody?.fieldBitMask = 0
    }
    
    public override func die() {
        
        // Make an explosion
        let explosion = SKEmitterNode(fileNamed: "playerExplosion")!
        explosion.position = position
        let sequence = SKAction.sequence([SKAction.run({ self.parent?.addChild(explosion) }),
                                          SKAction.wait(forDuration: TimeInterval(CGFloat(explosion.numParticlesToEmit) * explosion.particleLifetime)),
                                          SKAction.run({ explosion.removeFromParent() })])
        self.parent?.run(sequence)
        removeAllChildren()
        removeAllActions()
        removeFromParent()
        isPaused = true
    }
    
    internal override func createLaser() -> SKWeaponNode {
        let laser: SKWeaponNode = SKWeaponNode(imageNamed: "Laser", damage: 25)
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.categoryBitMask = GamePhysicsDelegate.laserCat
        laser.physicsBody?.collisionBitMask = GamePhysicsDelegate.laserMask
        laser.physicsBody?.contactTestBitMask = GamePhysicsDelegate.laserMask
        laser.physicsBody?.fieldBitMask = 0
        return laser
    }
    
}
