//
//  GameScene.swift
//  jax
//
//  Created by Felipe Passos on 04/04/23.
//

import Foundation
import SpriteKit
import AVFAudio

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player = PlayerNode()
    var cam = SKCameraNode()
    var ui = SKNode()
    var tileMap: SKTileMapNode?
    var soundManager = SoundManager()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        configurePlayer()
        configureCamera()
        configureTileMap()
        configurePhysics()
        configureMap()
        configureUI()
        
        let enemy = EnemyNode()
        enemy.name = "torch"
        addChild(enemy)
        
        soundManager.playPlayback(intensity: 0)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            return;
        }
        
        if (nodeA.name == "player" || nodeB.name == "player") {
            player.stopMove()
        }
    }
    
    func createRandomTorch() {
        let enemy = EnemyNode()
        enemy.position = CGPoint(
            x: Int.random(in: 50..<500),
            y: Int.random(in: 50..<500)
        )
        
        addChild(enemy)

        enemy.follow(player: player)
    }
    
    func configurePlayer() {
        let startPoint = scene?.childNode(withName: "StartPoint")!
        
        player.position = startPoint!.position
        scene?.addChild(player)
    }
    
    func configurePhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func configureUI() {
        ui = childNode(withName: "UI")!
    }
    
    func configureCamera() {
        cam.position = CGPoint(x: 0, y: 0)
        scene?.addChild(cam)
        scene?.camera = cam
        
        /// Scale up
        // let zoomInAction = SKAction.scale(to: 0.5, duration: 1)
        // cam.run(zoomInAction)
    }
    
    func configureMap() {
        let map = self.childNode(withName: "Map")!
        
        for  mapNode in map.children as! [SKSpriteNode] {
            if (mapNode.name == "tree") {
                let rect = SKShapeNode(circleOfRadius: 16)
                rect.position.y -= 64
                mapNode.addChild(rect)
                
                mapNode.run(.repeatForever(SKAction(named: "TreeIdleAnimation")!))
                
                mapNode.physicsBody = SKPhysicsBody(
                    circleOfRadius: 8,
                    center: CGPoint(x: 0, y: -32)

                )
                
                mapNode.physicsBody?.categoryBitMask = PhysicsCategory.tree
                mapNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                mapNode.physicsBody?.isDynamic = false
            }
            
            if (mapNode.name == "house") {
                let rect = SKShapeNode(rectOf: CGSize(width: 96, height: 64))
                rect.position.y -= 64
                mapNode.addChild(rect)
                
                mapNode.physicsBody = SKPhysicsBody(
                    rectangleOf: CGSize(width: 55, height: 32),
                    center: CGPoint(x: 0, y: -32)

                )
                
                mapNode.physicsBody?.categoryBitMask = PhysicsCategory.tree
                mapNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                mapNode.physicsBody?.isDynamic = false
            }
        }
    }
    
    func configureTileMap() {
        self.tileMap = self.childNode(withName: "Water TileMap") as? SKTileMapNode
        guard let tileMap = self.tileMap else { fatalError("Missing tile map for the level") }

        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height

        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDefinition?.name != nil
                if (isEdgeTile) {
                    let x = CGFloat(col) * tileSize.width - halfWidth
                    let y = CGFloat(row) * tileSize.height - halfHeight
                                        
                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                    let tileNode = SKShapeNode(rect: rect)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.name = "Water"
                    tileNode.physicsBody?.categoryBitMask = PhysicsCategory.waterGround
                    tileNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                    tileNode.physicsBody?.usesPreciseCollisionDetection = true

                    tileMap.addChild(tileNode)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        camera?.position = player.position
        ui.position = camera?.position ?? CGPoint(x: 0, y: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: self)

        let touchedNode = atPoint(touch)
        if touchedNode.name == "AttackButton" {
            player.attack()
            simpleShake()
            
            touchedNode.run(.sequence([
              .fadeAlpha(to: 0.3, duration: 0.1),
              .fadeAlpha(to: 1, duration: 0.1)
            ]))

            return;
        }

        player.move(location: touch)
    }
}

