//
//  PlayerNode.swift
//  jax
//
//  Created by Felipe Passos on 05/04/23.
//

import Foundation
import SpriteKit

class PlayerNode: SKSpriteNode {
    private let sheet = SpriteSheet(
        texture: SKTexture(imageNamed: "warrior"),
        rows: 3,
        columns: 6
    )
    
    init() {
        let texture = sheet.textureForColumn(column: 0, row: 2)!
        
        super.init(texture: texture, color: .gray, size: texture.size())
        
        idleAnimation()
        
        name = "player"
        zPosition = 100
        
        let physicsFrame = SKShapeNode(rectOf: CGSize(width: 64, height: 64))
        
        physicsBody = SKPhysicsBody(rectangleOf: physicsFrame.frame.size)
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.waterGround
        physicsBody?.collisionBitMask = PhysicsCategory.waterGround
        physicsBody?.usesPreciseCollisionDetection = false
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
    }
    
    func removeCrosshair() {
        scene?.childNode(withName: "crosshair")?.removeFromParent()
    }
    
    func placeCrosshair(location: CGPoint) {
        removeCrosshair()
        
        let crosshair = SKSpriteNode(texture: SKTexture(imageNamed: "crosshair"))
        
        crosshair.name = "crosshair"
        crosshair.position = location
        
        scene?.addChild(crosshair)
        
        crosshair.run(.repeatForever(.sequence([
            .scale(to: 0.6, duration: 0.4),
            .scale(to: 1, duration: 0.4)
        ])))
    }
    
    func attack() {
        stopMove()
        
        attackAnimation()
    }
    
    func stopMove() {
        removeAllActions()
        removeCrosshair()
        
        idleAnimation()
    }
    
    func movePlayer(location: CGPoint) {
        placeCrosshair(location: location)
        
        removeAllActions()
        
        runningAnimation()
        
        if (location.x < position.x) {
            xScale = -1;
        } else {
            xScale = 1;
        }
        
        let runAction = SKAction.move(
            to: CGPoint(
                x: location.x,
                y: location.y
            ),
            duration: location.distance(point: position) * 0.005
        )

        run(runAction, completion: {
            self.removeCrosshair()
            self.idleAnimation()
        })
    }
    
    func idleAnimation() {
        let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 2)! }
        
        self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)))
    }
    
    func attackAnimation() {
        let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 0)! }
        
        self.run(.animate(with: spriteSheet, timePerFrame: 0.05))
    }
    
    func runningAnimation() {
        let runningAction = self.action(forKey: "running")
        if (runningAction != nil) { return }
        
        let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 1)! }
        
        self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)), withKey: "running")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
