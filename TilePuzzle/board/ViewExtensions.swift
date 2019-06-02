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
	func animateShow(duration: Double = 1.5, delay: Double = 0.3) {
		self.alpha = 0
		if self.isHidden {
			self.isHidden = false
		}
		UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: {
			self.alpha = 1
		}, completion: { _ in })	// do nothing
	}
	
	// animates full image being hidden
	func animateHide(duration: Double = 1.5, delay: Double = 0.5) {
		UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: {
			self.alpha = 0
		}, completion: { _ in
			self.isHidden = true
			self.alpha = 1
		})
	}
}
