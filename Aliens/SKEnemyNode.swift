/*
 
  SKEnemyNode.swift
  Aliens

  Created by Ibrahim Syed on 7/29/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

import SpriteKit
import simd

class SKEnemyNode: SKCharacterNode {
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(imageNamed: String, animations: [SKTexture]) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        updateHealthBar()
        preparePhysicsBody(texture: texture)
        if animations.count > 0 { run(SKAction.repeatForever(SKAction.animate(with: animations, timePerFrame: 0.1))) }
        autoFire()
    }
    
    public func startMoving() {
        run(SKAction.sequence([SKAction.move(to: CGPoint(x: self.position.x, y: CGFloat(-750)), duration: 23),
                               SKAction.removeFromParent()]), withKey: "enemyMove")
    }
    
    private func preparePhysicsBody(texture: SKTexture) {
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = GamePhysicsDelegate.enemyCat
        self.physicsBody?.collisionBitMask = GamePhysicsDelegate.enemyMask
        self.physicsBody?.contactTestBitMask = GamePhysicsDelegate.enemyMask
        self.physicsBody?.fieldBitMask = 0
    }
    
}
