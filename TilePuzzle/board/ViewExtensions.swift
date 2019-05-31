//
//  ViewExtensions.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/30/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

// animations
extension UIView {
	// animates revealing full image
	func animateShow() {
		self.alpha = 0
		if self.isHidden {
			self.isHidden = false
		}
		UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveLinear, animations: {
			self.alpha = 1
		}, completion: { _ in })	// do nothing
	}
	
	// animates full image being hidden
	func animateHide() {
		UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveLinear, animations: {
			self.alpha = 0
		}, completion: { _ in
			self.isHidden = true
			self.alpha = 1
		})
	}
}
