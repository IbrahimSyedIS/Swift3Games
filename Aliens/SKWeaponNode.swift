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
    
    // Required by XCode
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setDamage(to dam: Float) {
        damage = dam
    }
    
    public func getDamage() -> Float {
        return damage
    }
    
}
