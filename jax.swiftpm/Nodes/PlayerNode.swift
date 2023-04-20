//
//  PlayerNode.swift
//  jax
//
//  Created by Felipe Passos on 05/04/23.
//

import Foundation
import SpriteKit

class PlayerNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "warrior_idle_1")
        
        super.init(texture: texture, color: .gray, size: texture.size())
        
        idleAnimation()
        
        name = "player"
        zPosition = 100
                
        configurePhysics()
        
    }
    
    private var enemyInContact: EnemyNode?
    
    func didContact(_ other: SKNode) {
        if (other.name != "torch") { stopMove() }
        
        if (other.name == "torch") { enemyInContact = (other as! EnemyNode) }
    }
    
    func endContact(_ other: SKNode) {
        if (other.name == "torch") { enemyInContact = nil }
    }
    
    func configurePhysics() {
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
    
    func attack(_ completion: () -> Void) {
        stopMove()
        
        attackAnimation()
        
        if (enemyInContact != nil) {
            enemyInContact!.kill()
            enemyInContact = nil
            completion()
        }
    }
    
    func stopMove() {
        removeAllActions()
        removeCrosshair()
        
        idleAnimation()
    }
    
    func move(location: CGPoint) {
        placeCrosshair(location: location)
                
        let move = SKAction.customAction(withDuration: TimeInterval(1), actionBlock: {
            (node,elapsedTime) in
            let distance = node.position.distance(point: location)
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
            let spriteSheet = Array(0...5).map { SKTexture(imageNamed: "warrior_idle_\($0)") }
            self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)), withKey: "idle")
        }
    }
    
    func attackAnimation() {
        let range = GameManager.attackFullAnimationEnabled ? [0, 1, 2, 3, 4, 5] : [0, 5]
        let spriteSheet = range.map { SKTexture(imageNamed: "warrior_attack_\($0)") }
        
        self.run(.animate(with: spriteSheet, timePerFrame: 0.05), withKey: "attack")
    }
    
    func runningAnimation() {
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        
        if (self.action(forKey: "running") == nil) {
            let spriteSheet = Array(0...5).map { SKTexture(imageNamed: "warrior_running_\($0)") }
            
            self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)), withKey: "running")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
