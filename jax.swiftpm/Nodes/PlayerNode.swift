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
        
        let attackFrame = SKShapeNode(rectOf: CGSize(width: 64, height: 64))
        attackFrame.position.x += 32
        
        if (GameManager.debugMode) {
            attackFrame.strokeColor = .red
            addChild(attackFrame)
        }
        
        let physicsFrame = SKShapeNode(circleOfRadius: 32)
        
        if (GameManager.debugMode) {
            addChild(physicsFrame)
        }
        
        physicsBody = SKPhysicsBody(circleOfRadius: 32)
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.waterGround | PhysicsCategory.torch | PhysicsCategory.tree
        physicsBody?.collisionBitMask = PhysicsCategory.waterGround | PhysicsCategory.torch | PhysicsCategory.tree
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
    
    func move(location: CGPoint) {
        placeCrosshair(location: location)
        
//        runningAnimation()
//
//        if (location.x < position.x) {
//            xScale = -1;
//        } else {
//            xScale = 1;
//        }
//
//        let runAction = SKAction.move(
//            to: CGPoint(
//                x: location.x,
//                y: location.y
//            ),
//            duration: location.distance(point: position) * 0.005
//        )
//
//        run(runAction, completion: {
//            self.removeCrosshair()
//            self.idleAnimation()
//        })
                
        let move = SKAction.customAction(withDuration: TimeInterval(1), actionBlock: {
            (node,elapsedTime) in
            let distance = node.position.distance(point: location)
            print(distance)
            if (distance < 3) {
                self.idleAnimation()
                self.removeCrosshair()
            } else {
                self.runningAnimation()

                let dx = location.x - node.position.x
                let dy = location.y - node.position.y
                let angle = atan2(dx,dy)

                node.position.x += sin(angle) * 2.5
                node.position.y += cos(angle) * 2.5

                node.xScale = location.x < node.position.x ? -1 : 1
            }
        })

        run(.repeatForever(move), withKey: "move")
    }
    
    func idleAnimation() {
        self.removeAction(forKey: "running")
        self.removeAction(forKey: "attack")
        
        if (self.action(forKey: "idle") == nil) {
            let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 2)! }
            
            self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)), withKey: "idle")
        }
    }
    
    func attackAnimation() {
        self.removeAction(forKey: "running")
        self.removeAction(forKey: "idle")
        
        if (self.action(forKey: "attack") == nil) {
            let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 0)! }
            
            self.run(.animate(with: spriteSheet, timePerFrame: 0.05), withKey: "attack")
        }
    }
    
    func runningAnimation() {
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        
        if (self.action(forKey: "running") == nil) {
            let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 1)! }
            
            self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)), withKey: "running")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
