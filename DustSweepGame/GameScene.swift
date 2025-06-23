//
//  GameScene.swift
//  DustSweepGame
//
//  Created by EMILY on 19/06/2025.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    private let backgroundImage = SKSpriteNode(imageNamed: Assets.woodenfloor.rawValue)
    
    private let boxImage = SKSpriteNode(imageNamed: Assets.box.rawValue)
    
    private let dusterImage = SKSpriteNode(imageNamed: Assets.duster.rawValue)
    
    private let sweepSound: SKAudioNode = {
        let node = SKAudioNode(fileNamed: Assets.sweepSound)
        
        node.autoplayLooped = true
        node.isPositional = true
        
        return node
    }()
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        
        addBackgroundImage()
        addBoxImage()
        addDusterImage()
        
        for _ in 1...200 {
            addDustImages()
        }
    }
    
    private func addBackgroundImage() {
        backgroundImage.size = size
        backgroundImage.anchorPoint = .zero
        backgroundImage.zPosition = -1
        
        addChild(backgroundImage)
    }
    
    private func addBoxImage() {
        let width = size.width - 50
        
        boxImage.size = CGSize(width: width, height: width)
        boxImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        boxImage.zPosition = 1
        
        addChild(boxImage)
    }
    
    private func addDusterImage() {
        let width = boxImage.size.width / 4
        let height = width * 1.3
        
        dusterImage.size = CGSize(width: width, height: height)
        dusterImage.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        dusterImage.position = CGPoint(x: size.width - (width / 2) - 25, y: size.height - (height / 2) - 90)
        dusterImage.zPosition = 3
        
        addChild(dusterImage)
    }
    
    private func addDustImages() {
        let randomDust = Dust.allCases.randomElement() ?? .fourth
        
        let xRange: ClosedRange<CGFloat> = 55...(size.width - 55)
        let yOffset = (size.height - boxImage.size.width) / 2
        let yRange: ClosedRange<CGFloat> = (yOffset + 30)...(yOffset + boxImage.size.height - 30)
    
        let x = CGFloat.random(in: xRange)
        let y = CGFloat.random(in: yRange)
        
        let dust = DustImageNode(dust: randomDust)
        dust.position = CGPoint(x: x, y: y)
        
        addChild(dust)
    }
    
    private var isDusterTouched: Bool = false
}

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // calculate the range of current duster's location >> to check if user started touching correct location
        let xRange: ClosedRange<CGFloat> = dusterImage.position.x - dusterImage.size.width / 2 ... dusterImage.position.x + dusterImage.size.width / 2
        let yRange: ClosedRange<CGFloat> = dusterImage.position.y - dusterImage.size.height * 0.2 ... dusterImage.position.y + dusterImage.size.height * 0.3
        
        isDusterTouched = xRange.contains(location.x) && yRange.contains(location.y)
        
        if isDusterTouched {
            addChild(sweepSound)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if isDusterTouched {
            let moveAction = SKAction.move(to: location, duration: 0.07)
            dusterImage.run(moveAction)
            cleanDusts()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDusterTouched = false
        sweepSound.removeFromParent()
    }
    
    private func cleanDusts() {
        let x = dusterImage.position.x
        let y = dusterImage.position.y - dusterImage.size.height * 0.2
        let point = CGPoint(x: x, y: y)
        
        for node in nodes(at: point) where (node as? DustImageNode) != nil {
            
            let moveAction = SKAction.move(to: point, duration: 0.05)
            let fadeAction = SKAction.fadeAlpha(to: 0, duration: 0.7)
            let removeAction = SKAction.removeFromParent()
            let sequenceAction = SKAction.sequence([moveAction, fadeAction, removeAction])
            node.run(sequenceAction)
        }
    }
}

#Preview {
    ContentView()
}
