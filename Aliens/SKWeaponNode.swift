//
//  SKWeaponNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 5/31/18.
//  Copyright © 2018 Ibrahim Syed. All rights reserved.
//

import Foundation
import SpriteKit

class SKWeaponNode: SKSpriteNode {
    
    private var damage: Float = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    public func setDamage(to dam: Float) {
        damage = dam
    }
    
    public func getDamage() -> Float {
        return damage
    }
    
}
