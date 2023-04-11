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
        let texture = sheet.textureForColumn(column: 0, row: 2)!
        
        super.init(texture: texture, color: .gray, size: texture.size())
        
        idleAnimation()
        
        let rect = SKShapeNode(rectOf: CGSize(width: 64, height: 64))
        rect.strokeColor = .red
        addChild(rect)
        
        physicsBody = SKPhysicsBody(rectangleOf: rect.frame.size)
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 1
        physicsBody?.collisionBitMask = collisionMask
        physicsBody?.usesPreciseCollisionDetection = false
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
    }
    
    let collisionMask: UInt32 = 0x11 << 0
    
    let sheet = SpriteSheet(
        texture: SKTexture(imageNamed: "warrior"),
        rows: 3,
        columns: 6
    )
    
    func movePlayer(location: CGPoint) {
        removeAllActions()
        
        runningAnimation()
        
        if (location.x < position.x) {
            xScale = -1;
        } else {
            xScale = 1;
        }
        
//        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        
        let runAction = SKAction.move(
            to: CGPoint(
                x: location.x,
                y: location.y
            ),
            duration: location.distance(point: position) * 0.005
        )

        run(runAction, completion: idleAnimation)
         
    }
    
    func idleAnimation() {
        let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 2)! }
        
        self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)))
    }
    
    func attackAnimation() {
        let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 0)! }
        
        self.run(.animate(with: spriteSheet, timePerFrame: 0.1))
    }
    
    func runningAnimation() {        
        let spriteSheet = Array(0...5).map { sheet.textureForColumn(column: $0, row: 1)! }
        
        self.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
