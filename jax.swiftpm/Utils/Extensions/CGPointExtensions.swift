//
//  CGPointExtensions.swift
//  jax
//
//  Created by Felipe Passos on 05/04/23.
//

import Foundation

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}
