//
//  DirtImageNode.swift
//  DustSweepGame
//
//  Created by EMILY on 20/06/2025.
//

import SpriteKit

class DirtImageNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: Assets.dirt.rawValue)
        let size = CGSize(width: 40, height: 40)
        super.init(texture: texture, color: .clear, size: size)
        zPosition = 2
        name = "dust"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
