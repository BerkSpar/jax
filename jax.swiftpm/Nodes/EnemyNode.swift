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
    
    private var hasContact: Bool = false
    
    init() {
        let texture = sheet.textureForColumn(column: 0, row: 2)!
        
        super.init(texture: texture, color: .gray, size: texture.size())
        
        idleAnimation()
        
        name = "torch"
        zPosition = 90
        
        configurePhysics()
    }
    
    func kill() {
        if (GameManager.simpleDeath) {
            removeFromParent()
            return
        }
        
        run(.sequence([
            .run({
                self.alpha = 0.5
            }),
            .wait(forDuration: 0.2),
            .run({
                self.alpha = 1
            }),
            .wait(forDuration: 0.2),
            .run({
                self.alpha = 0.5
            }),
            .wait(forDuration: 0.2),
            .run({
                self.alpha = 1
            }),
            .run({
                if (!GameManager.deadPersistenceEnabled) {
                    self.removeFromParent()
                }
            })
        ]))
        
        if (GameManager.deadPersistenceEnabled) {
            removeAllActions()
            physicsBody = nil
            run(.scale(to: 0.5, duration: 1))
            deadAnimation(node: self)
        }
    }
    
    func attack() {
        if (self.action(forKey: "attack_player") == nil) {
            run(.repeatForever(.sequence([
                .run({
                    self.attackAnimation()
                }),
                .wait(forDuration: 2)
            ])), withKey: "attack_player")
        }
    }
    
    func didContact(_ other: SKNode) {
        if (other.name == "player") {
            hasContact = true
        }
    }
    
    func endContact(_ other: SKNode) {
        if (other.name == "player") {
            hasContact = false
        }
    }
    
    func configurePhysics() {
        let physicsFrame = SKShapeNode(circleOfRadius: 32)
        
        if (GameManager.debugMode) {
            addChild(physicsFrame)
        }
        
        physicsBody = SKPhysicsBody(circleOfRadius: 32)
        physicsBody?.categoryBitMask = PhysicsCategory.torch
        physicsBody?.contactTestBitMask = PhysicsCategory.waterGround | PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.waterGround | PhysicsCategory.torch | PhysicsCategory.tree
        physicsBody?.usesPreciseCollisionDetection = false
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
    }
    
    func stopMove() {
        removeAllActions()
        
        idleAnimation()
    }
    
    func follow(player: PlayerNode) {
        let followPlayer = SKAction.customAction(withDuration: TimeInterval(Int.max), actionBlock: {
            (node,elapsedTime) in
            if (!self.hasContact) {
                self.runningAnimation()
                
                let dx = player.position.x - node.position.x
                let dy = player.position.y - node.position.y
                let angle = atan2(dx,dy)
                node.position.x += sin(angle) * 2
                node.position.y += cos(angle) * 2
                node.xScale = player.position.x < node.position.x ? -1 : 1
            } else {
                self.attack()
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
    
    func deadAnimation(node: SKSpriteNode) {
        if (self.action(forKey: "dead") == nil) {
            let spriteSheet = Array(0...6).map { SKTexture(imageNamed: "dead_\($0)") }
            
            node.run(.animate(with: spriteSheet, timePerFrame: 0.1), withKey: "dead")
        }
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
        if (self.action(forKey: "attack") == nil) {
            let range = GameManager.attackFullAnimationEnabled ? [0, 1, 2, 3, 4, 5] : [0, 5]
            let spriteSheet = range.map { sheet.textureForColumn(column: $0, row: 0)! }
            
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
