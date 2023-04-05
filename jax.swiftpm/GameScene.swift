//
//  GameScene.swift
//  jax
//
//  Created by Felipe Passos on 04/04/23.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    var player = SKSpriteNode()
    var cam = SKCameraNode()
    var nodePosition = CGPoint()
    var startTouch = CGPoint()
    let sheet = SpriteSheet(
        texture: SKTexture(imageNamed: "warrior"),
        rows: 3,
        columns: 6,
        spacing: 1,
        margin: 1
    )
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.camera = cam
        
        let text = scene?.childNode(withName: "//*title*") as! SKLabelNode
        text.text = "Deu boa"
        
        player = SKSpriteNode(texture: sheet.textureForColumn(column: 0, row: 2))
        self.addChild(player)
        
        idleAnimation()
    }
    
    override func update(_ currentTime: TimeInterval) {
        camera?.position = player.position
    }
    
    func idleAnimation() {
        let spriteSheet = [
            sheet.textureForColumn(column: 0, row: 2)!,
            sheet.textureForColumn(column: 1, row: 2)!,
            sheet.textureForColumn(column: 2, row: 2)!,
            sheet.textureForColumn(column: 3, row: 2)!,
            sheet.textureForColumn(column: 4, row: 2)!,
            sheet.textureForColumn(column: 5, row: 2)!
        ]
        
        player.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)))
    }
    
    func attackAnimation() {
        let spriteSheet = [
            sheet.textureForColumn(column: 0, row: 0)!,
            sheet.textureForColumn(column: 1, row: 0)!,
            sheet.textureForColumn(column: 2, row: 0)!,
            sheet.textureForColumn(column: 3, row: 0)!,
            sheet.textureForColumn(column: 4, row: 0)!,
            sheet.textureForColumn(column: 5, row: 0)!
        ]
        
        player.run(.animate(with: spriteSheet, timePerFrame: 0.1))
    }
    
    
    
    func runningAnimation() {
        let spriteSheet = [
            sheet.textureForColumn(column: 0, row: 1)!,
            sheet.textureForColumn(column: 1, row: 1)!,
            sheet.textureForColumn(column: 2, row: 1)!,
            sheet.textureForColumn(column: 3, row: 1)!,
            sheet.textureForColumn(column: 4, row: 1)!,
            sheet.textureForColumn(column: 5, row: 1)!
        ]
        
        player.run(.repeatForever(.animate(with: spriteSheet, timePerFrame: 0.1)))
    }
    
    func sceneShake(shakeCount: Int, intensity: CGVector, shakeDuration: Double) {
            let sceneView = self.scene!.view! as UIView
            let shakeAnimation = CABasicAnimation(keyPath: "position")

            shakeAnimation.duration = shakeDuration / Double(shakeCount)
            shakeAnimation.repeatCount = Float(shakeCount)
            shakeAnimation.autoreverses = true
            shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x - intensity.dx, y: sceneView.center.y - intensity.dy))
            shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x + intensity.dx, y: sceneView.center.y + intensity.dy))

            sceneView.layer.add(shakeAnimation, forKey: "position")
          }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// Bomb shake
//        sceneShake(shakeCount: 3, intensity: CGVector(dx: 12, dy: 3), shakeDuration: 0.3)
        
        /// Attack shake
//        attackAnimation()
//        sceneShake(shakeCount: 1, intensity: CGVector(dx: 2, dy: 1), shakeDuration: 0.1)
        
        let touch = touches.first

        if let location = touch?.location(in: self){
            player.removeAllActions()
            
            runningAnimation()

            if (location.x < player.position.x) {
                player.xScale = -1;
            } else {
                player.xScale = 1;
            }
            
            let runAction = SKAction.move(
                to: CGPoint(
                    x: location.x,
                    y: location.y
                ),
                duration: location.distance(point: player.position) * 0.005
            )

            player.run(runAction, completion: idleAnimation)
            
        }
    }
}

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:Int = 3, amplitudeY:Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx,y: dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
}
