//
//  DustImageNode.swift
//  DustSweepGame
//
//  Created by EMILY on 20/06/2025.
//

import SpriteKit

class DustImageNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: Assets.dust.rawValue)
        let size = CGSize(width: 50, height: 25)
        super.init(texture: texture, color: .clear, size: size)
        zPosition = 2
        name = "dust"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
