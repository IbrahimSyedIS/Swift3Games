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
}
