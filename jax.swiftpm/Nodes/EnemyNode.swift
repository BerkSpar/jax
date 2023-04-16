//
//  PlayerNode.swift
//  jax
//
//  Created by Felipe Passos on 05/04/23.
//

import Foundation
import SpriteKit

class EnemyNode: SKSpriteNode {
    private let sheet = SpriteSheet(
        texture: SKTexture(imageNamed: "torch"),
        rows: 3,
        columns: 7
    )
    
    init() {
        let texture = sheet.textureForColumn(column: 0, row: 2)!
        
        super.init(texture: texture, color: .gray, size: texture.size())
        
        idleAnimation()
        
        name = "torch"
        zPosition = 90
        
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
        physicsBody?.categoryBitMask = PhysicsCategory.torch
        physicsBody?.contactTestBitMask = PhysicsCategory.waterGround | PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.waterGround | PhysicsCategory.torch
        physicsBody?.usesPreciseCollisionDetection = false
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
    }
    
    func attack() {
        
    }
    
    func stopMove() {
        removeAllActions()
        
        idleAnimation()
    }
    
    func follow(player: PlayerNode) {
        let followPlayer = SKAction.customAction(withDuration: TimeInterval(Int.max), actionBlock: {
            (node,elapsedTime) in
            let distance = node.position.distance(point: player.position)
            
            if (distance > 80) {
                self.runningAnimation()
                
                let dx = player.position.x - node.position.x
                let dy = player.position.y - node.position.y
                let angle = atan2(dx,dy)
                node.position.x += sin(angle) * 2
                node.position.y += cos(angle) * 2
                node.xScale = player.position.x < node.position.x ? -1 : 1
            } else {
                self.idleAnimation()
            }
        })
        
        run(followPlayer, withKey: "follow_player")
    }
    
    func move(location: CGPoint) {
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
            self.idleAnimation()
        })
    }
    
    func idleAnimation() {
        self.removeAction(forKey: "running")
        self.removeAction(forKey: "attack")
        
        if (self.action(forKey: "idle") == nil) {
            let spriteSheet = Array(0...6).map { sheet.textureForColumn(column: $0, row: 2)! }
            
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
