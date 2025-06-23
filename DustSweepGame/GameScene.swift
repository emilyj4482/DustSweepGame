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
    
    private var hasClearSoundPlayed: Bool = false
}

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // calculate the range of current duster's location >> to check if user started touching correct location
        let xRange: ClosedRange<CGFloat> = dusterImage.position.x - dusterImage.size.width / 2 ... dusterImage.position.x + dusterImage.size.width / 2
        let yRange: ClosedRange<CGFloat> = dusterImage.position.y - dusterImage.size.height * 0.2 ... dusterImage.position.y + dusterImage.size.height * 0.3
        
        isDusterTouched = xRange.contains(location.x) && yRange.contains(location.y)
        
        // play sweep sound only when duster image is touched
        if isDusterTouched {
            addChild(sweepSound)
            sweepSound.run(SKAction.changeVolume(to: 1.0, duration: 0.1))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if isDusterTouched {
            let moveAction = SKAction.move(to: location, duration: 0.07)
            dusterImage.run(moveAction)
            cleanDusts()
            
            // when all dusts get cleared, stop sweep sound and play clear sound
            if scene?.children.filter({ $0.name == "dust" }).count == 0 && !hasClearSoundPlayed {
                playClearSound()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDusterTouched = false
        
        // sweep sound has to stop when not sweeping
        if sweepSound.parent != nil {   // there's posibility the node got removed during touchesMoved
            let fadeOutAction = SKAction.changeVolume(to: 0.0, duration: 0.3)
            let removeAction = SKAction.removeFromParent()
            sweepSound.run(SKAction.sequence([fadeOutAction, removeAction]))
        }
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
    
    private func playClearSound() {
        // clear sound should play only once
        hasClearSoundPlayed = true
        
        // 1. fadeOut sweep sound
        let fadeOutAction = SKAction.changeVolume(to: 0.0, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        
        let sweepSoundSequence = SKAction.sequence([fadeOutAction, removeAction])
        
        sweepSound.run(sweepSoundSequence) { [weak self] in
            let clearSound = SKAudioNode(fileNamed: Assets.clearSound)
            clearSound.autoplayLooped = false
            self?.addChild(clearSound)
            
            // turn down clear sound since sweep sound's originally quiet
            let setVolumeAction = SKAction.changeVolume(to: 0.3, duration: 0.0)
            let playAction = SKAction.play()
            // wait 2 seconds(play time) before removing node from parent
            let waitAction = SKAction.wait(forDuration: 2.0)
            
            let sequence = SKAction.sequence([setVolumeAction, playAction,waitAction, removeAction])
            
            clearSound.run(sequence)
        }
    }
}

#Preview {
    ContentView()
}
