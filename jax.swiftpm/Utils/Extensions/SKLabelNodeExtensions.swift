//
//  SKLabelNodeExtension.swift
//  jax
//
//  Created by Felipe Passos on 17/04/23.
//

import Foundation

extension SKLabelNode {
    func updateAttributedText(_ text: String) {
        if let attributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.mutableString.setString(text)
            self.attributedText = mutableAttributedText
        }
    }
}
