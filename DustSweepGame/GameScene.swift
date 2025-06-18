//
//  GameScene.swift
//  DustSweepGame
//
//  Created by EMILY on 19/06/2025.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        
        let background = SKSpriteNode(color: .white, size: size)
        background.anchorPoint = .zero
        background.zPosition = -1
        background.name = "background"
        addChild(background)
        
        let dustParticle = SKShapeNode(circleOfRadius: 3)
        dustParticle.fillColor = .gray
        dustParticle.strokeColor = .darkGray
        dustParticle.alpha = 0.3
        dustParticle.name = "dust"
        dustParticle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dustParticle.zPosition = 1
        
        let rectDust = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 4, height: 2))
        rectDust.fillColor = .gray
        rectDust.strokeColor = .darkGray
        rectDust.alpha = 0.3
        rectDust.name = "dust2"
        rectDust.position = CGPoint(x: size.width / 2 - 10, y: size.height / 2)
        rectDust.zPosition = 1
        
        let ovalDust = SKShapeNode(ellipseOf: CGSize(width: 5, height: 3))
        ovalDust.fillColor = .gray
        ovalDust.strokeColor = .darkGray
        ovalDust.alpha = 0.3
        ovalDust.name = "dust3"
        ovalDust.position = CGPoint(x: size.width / 2 + 10, y: size.height / 2)
        ovalDust.zPosition = 1
        
        addChild(dustParticle)
        addChild(rectDust)
        addChild(ovalDust)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes where node.name != "background" {
                node.run(SKAction.fadeOut(withDuration: 0.3)) {
                    node.removeFromParent()
                }
            }
        }
    }
}
