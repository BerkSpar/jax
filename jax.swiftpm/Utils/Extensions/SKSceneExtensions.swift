//
//  SKSceneExtensions.swift
//  jax
//
//  Created by Felipe Passos on 08/04/23.
//

import Foundation
import SpriteKit

extension SKScene {
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
    
    func bombShake() {
        sceneShake(shakeCount: 10, intensity: CGVector(dx: 12, dy: 6), shakeDuration: 0.3)
    }
}
