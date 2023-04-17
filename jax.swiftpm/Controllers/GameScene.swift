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
    var subtitle = SKLabelNode()
    var attackButton = SKSpriteNode()
    var splash = SKShapeNode()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        configurePlayer()
        configureCamera()
        configureTileMap()
        configurePhysics()
        configureMap()
        configureUI()
        configureSound()
        configureSplash()
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
        let rangeX = Int(player.position.x + 50)..<Int(player.position.x + 300)
        let rangeY = Int(player.position.y + 50)..<Int(player.position.y + 300)
        
        let enemy = EnemyNode()
        enemy.position = CGPoint(
            x: Int.random(in: rangeX),
            y: Int.random(in: rangeY)
        )
        
        addChild(enemy)

        enemy.follow(player: player)
    }
    
    func configureSplash() {
        let background = SKShapeNode(rectOf: frame.size)
        background.name = "background"
        background.position = player.position
        background.fillColor = .black
        background.zPosition = 1000000
        
        let title = SKLabelNode()
        title.name = "background"
        title.text = "The legend of Harald"
        
        let subtitle = SKLabelNode()
        subtitle.name = "background"
        subtitle.position = CGPoint(x: 0, y: -25)
        subtitle.text = "A story about game feel"
        subtitle.fontSize = 18
        
        let label = SKLabelNode()
        label.name = "background"
        label.text = "[Tap anywhere to start your journey]"
        label.position = CGPoint(x: 0, y: -100)
        label.fontSize = 24
        
        background.addChild(title)
        background.addChild(subtitle)
        background.addChild(label)
        
        splash = background
        scene?.addChild(splash)
        
        label.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.5, duration: 1),
            .fadeAlpha(to: 1, duration: 1),
        ])))
    }
    
    func configureSound() {
        soundManager.playPlayback(intensity: 0)
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
        let displaySize: CGRect = UIScreen.main.bounds
        let displayWidth = displaySize.width
        let displayHeight = displaySize.height
        
        ui = childNode(withName: "UI")!
        
        attackButton = ui.childNode(withName: "AttackButton") as! SKSpriteNode
        attackButton.position = CGPoint(
            x: displayWidth * 0.4,
            y: displayHeight * -0.4
        )
        attackButton.isHidden = true
        
        subtitle = ui.childNode(withName: "Subtitle") as! SKLabelNode
        subtitle.position = CGPoint(
            x: scene!.frame.midX,
            y: displayHeight * -0.4
        )
        subtitle.isHidden = true
    }
    
    func configureCamera() {
        cam.position = CGPoint(x: 0, y: 0)
        cam.setScale(0.5)
        
        scene?.addChild(cam)
        scene?.camera = cam
    }
    
    func configureMap() {
        let map = self.childNode(withName: "Map")!
        
        for  mapNode in map.children as! [SKSpriteNode] {
            if (mapNode.name == "tree") {
                let rect = SKShapeNode(circleOfRadius: 16)
                rect.position.y -= 64
                
                if (GameManager.debugMode) {
                    mapNode.addChild(rect)
                }
                
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
                
                if (GameManager.debugMode) {
                    mapNode.addChild(rect)
                }
                
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
                                        
                    
                    let tileNode = SKShapeNode()
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.name = "Water"
                    tileNode.physicsBody?.categoryBitMask = PhysicsCategory.waterGround
                    tileNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                    tileNode.physicsBody?.usesPreciseCollisionDetection = true
                    
                    tileMap.addChild(tileNode)
                    
                    if (GameManager.debugMode) {
                        let rect = SKShapeNode(rect: CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height))
                        tileNode.addChild(rect)
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        camera?.position = player.position
        ui.position = cam.position
        ui.xScale = cam.xScale
        ui.yScale = cam.yScale
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: self)

        let touchedNode = atPoint(touch)
        if touchedNode.name == "AttackButton" {
            player.attack()

            if (GameManager.attackShakingEnabled) {
                simpleShake()
            }

            touchedNode.run(.sequence([
              .fadeAlpha(to: 0.3, duration: 0.1),
              .fadeAlpha(to: 1, duration: 0.1)
            ]))
            
            return;
        }
        
        if (touchedNode.name == "background") {
            splash.run(.sequence([
                .fadeOut(withDuration: 0.7),
            ]), completion: {
                self.splash.removeFromParent()
                self.scene1()
            })
        }

        if (GameManager.canMove) {
            player.move(location: touch)
        }
    }
    
    func scene1() {
        run(.sequence([
            .wait(forDuration: 0.5),
            .run({
                self.subtitle.isHidden = false
                self.subtitle.updateAttributedText("Oh, my lord! Thank goodness you activated me just in time!\nCan’t you listen the importance of the sound? I can talk!")
            }),
            .playSoundFileNamed("voiceover-1", waitForCompletion: true)
        ]), completion: {
            self.run(.sequence([
                .wait(forDuration: 1),
                .run({
                    self.subtitle.updateAttributedText("Come on, my lord! Tap on this splendid technology\ncalled screen to walk! ")
                    GameManager.canMove = true
                }),
                .playSoundFileNamed("voiceover-3", waitForCompletion: true),
                .wait(forDuration: 2),
                .run({
                    self.subtitle.updateAttributedText("Come on, my lord! We need to run to the village\nsomething is not quite right there!")
                }),
                .run({
                    self.cam.run(.scale(to: 1, duration: 2))
                    self.soundManager.playPlayback(intensity: 1)
                }),
                .playSoundFileNamed("voiceover-2", waitForCompletion: true),
                .run({
                    self.subtitle.isHidden = true
                })
            ]))
        })
    }
}

