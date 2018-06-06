//
//  SKBossNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 6/6/18.
//  Copyright © 2018 Ibrahim Syed. All rights reserved.
//

import Foundation
import SpriteKit

class SKBossNode: SKCharacterNode {
    
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
        run(SKAction.repeatForever(SKAction.animate(with: animations, timePerFrame: 0.1)))
//        autoFire()
    }
    
    public override func autoFire() {
        print("Autofiring")
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
