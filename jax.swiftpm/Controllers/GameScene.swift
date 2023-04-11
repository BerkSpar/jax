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
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("didBegin")
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            return;
        }
        
        if (nodeA.name == "player") {
            if (nodeB.name == "water") {
                player.stopMove()
            }
        }
        
        if (nodeB.name == "player") {
            if (nodeA.name == "water") {
                player.stopMove()
            }
        }
    }
    
    func configurePlayer() {
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
    
    func configureTileMap() {
        self.tileMap = self.childNode(withName: "Water Tile Map") as? SKTileMapNode
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
//                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                    let tileNode = SKShapeNode()
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.name = "water"
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
        for touch in touches {
              let location = touch.location(in: self)
              let touchedNode = atPoint(location)
              if touchedNode.name == "AttackButton" {
                  player.attack()
                  simpleShake()
                  
                  return;
              }
         }
        
        player.movePlayer(location: touches.first!.location(in: self))
    }
}

