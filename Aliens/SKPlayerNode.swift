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
        self.fireRate = 0.5
    }
    
    public required init?(coder aDecoder: NSCoder) {
        moveSpeed = 625
        super.init(coder: aDecoder)
        self.fireRate = 0.5
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
    
    internal override func fireLaser() {
        let laser = createLaser(imageNamed: "Laser")
        self.parent?.addChild(laser)
        run(SKAction.playSoundFileNamed("Laser_Shoot.mp3", waitForCompletion: false))
        laser.run(SKAction.sequence([SKAction.moveBy(x: CGFloat(0), y: CGFloat(1200), duration: 1),
                                     SKAction.removeFromParent()]), withKey: "enemyMove")
    }
    
    internal override func autoFire() {
        timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true, block: { (nil) in
            self.fireLaser()
        })
    }
    
    internal override func createLaser(imageNamed: String) -> SKWeaponNode {
        let laser = super.createLaser(imageNamed: imageNamed)
        laser.setDamage(to: 25)
        laser.position = CGPoint(x: position.x, y: position.y + 100)
        return laser
    }
    
}
