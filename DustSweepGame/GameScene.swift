//
//  GameScene.swift
//  DustSweepGame
//
//  Created by EMILY on 19/06/2025.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    private let backgroundImage = SKSpriteNode(imageNamed: Assets.background.rawValue)
    
    private var catFaceImage: SKSpriteNode!
    
    private var handImage = SKSpriteNode(imageNamed: Assets.hand.rawValue)
    
    private let restartImage = SKSpriteNode(imageNamed: Assets.restart.rawValue)
    
    private let purringSound: SKAudioNode = {
        let node = SKAudioNode(fileNamed: Assets.purringSound)
        
        node.autoplayLooped = true
        node.isPositional = true
        
        return node
    }()
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        
        addBackgroundImage()
        addCatFaceImage()
        addHandImage()
        setupRestartButton()
        
        addDusts()
    }
    
    private func addBackgroundImage() {
        backgroundImage.size = size
        backgroundImage.anchorPoint = .zero
        backgroundImage.zPosition = -1
        
        addChild(backgroundImage)
    }
    
    private func addCatFaceImage() {
        let imageName = Cat.allCases.randomElement()?.rawValue ?? Cat.cheese.rawValue
        catFaceImage = SKSpriteNode(imageNamed: imageName)
        
        let width = size.width - 50
        
        catFaceImage.size = CGSize(width: width, height: width)
        catFaceImage.position = CGPoint(x: frame.midX, y: frame.midY)
        catFaceImage.zPosition = 1
        
        addChild(catFaceImage)
    }
    
    private func addHandImage() {
        
            let width = catFaceImage.size.width / 4
            
            handImage.size = CGSize(width: width, height: width)
            
            handImage.anchorPoint = CGPoint(x: 0.5, y: 0.2)
            handImage.zPosition = 3
            setHandPosition()
            
            addChild(handImage)
        
    }
    
    private func setHandPosition() {
        handImage.position = CGPoint(x: size.width - (handImage.size.width / 2) - 25, y: size.height - (handImage.size.height / 2) - 90)
    }
    
    private func setupRestartButton() {
        restartImage.size = CGSize(width: 40, height: 40)
        restartImage.position = CGPoint(x: 40, y: size.height - 135)
    }
    
    private func addDustImage() {
        let xRange: ClosedRange<CGFloat> = 55...(size.width - 55)
        let yOffset = (size.height - catFaceImage.size.width) / 2
        let yRange: ClosedRange<CGFloat> = (yOffset + 30)...(yOffset + catFaceImage.size.height - 30)
    
        let x = CGFloat.random(in: xRange)
        let y = CGFloat.random(in: yRange)
        
        let dust = DustImageNode()
        dust.position = CGPoint(x: x, y: y)
        
        addChild(dust)
    }
    
    private func addDusts() {
        for _ in 1...40 {
            addDustImage()
        }
    }
    
    private var isDusterTouched: Bool = false
    
    private var hasClearSoundPlayed: Bool = false
    
    private var isGameOver: Bool = false
}

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // calculate the range of current duster's location >> to check if user started touching correct location
        let xRange: ClosedRange<CGFloat> = handImage.position.x - handImage.size.width / 2 ... handImage.position.x + handImage.size.width / 2
        let yRange: ClosedRange<CGFloat> = handImage.position.y - handImage.size.height * 0.2 ... handImage.position.y + handImage.size.height * 0.3
        
        isDusterTouched = xRange.contains(location.x) && yRange.contains(location.y)
        
        // play sweep sound only when duster image is touched
        if isDusterTouched {
            playSweepSound()
        }
        
        if restartImage.contains(location) {
            hasClearSoundPlayed = false
            addDusts()
            restartImage.removeFromParent()
            setHandPosition()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if isDusterTouched {
            let moveAction = SKAction.move(to: location, duration: 0.07)
            handImage.run(moveAction)
            cleanDusts()
            
            // when all dusts get cleared, stop sweep sound and play clear sound
            if scene?.children.filter({ $0.name == "dust" }).count == 0 && !hasClearSoundPlayed {
                playClearSound()
                addChild(restartImage)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDusterTouched = false
        
        // sweep sound has to be off when not sweeping
        let fadeOutAction = SKAction.changeVolume(to: 0, duration: 0.3)
        purringSound.run(fadeOutAction)
    }
    
    private func playSweepSound() {
        if purringSound.parent == nil {
            addChild(purringSound)
        }
        let changeVolumeAction = SKAction.changeVolume(to: 1.0, duration: 0.1)
        purringSound.run(changeVolumeAction)
    }
    
    private func cleanDusts() {
        let x = handImage.position.x
        let y = handImage.position.y - handImage.size.height * 0.2
        let point = CGPoint(x: x, y: y)
        
        for node in nodes(at: point) where (node as? DustImageNode) != nil {
            let moveAction = SKAction.move(to: point, duration: 0.03)
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
        
        // 2. play clear sound after sweep cound fades out
        purringSound.run(fadeOutAction) { [weak self] in
            let clearSound = SKAudioNode(fileNamed: Assets.meowSound)
            clearSound.autoplayLooped = false
            self?.addChild(clearSound)
            
            // turn down clear sound since sweep sound's originally quiet
            let setVolumeAction = SKAction.changeVolume(to: 0.3, duration: 0.0)
            let playAction = SKAction.play()
            // wait 2 seconds(play time) before removing node from parent
            let waitAction = SKAction.wait(forDuration: 2.0)
            let removeAction = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([setVolumeAction, playAction, waitAction, removeAction])
            
            clearSound.run(sequence)
        }
    }
}

#Preview {
    ContentView()
}
