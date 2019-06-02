//
//  PopUps.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 6/1/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class PopUpController {
	
	// list of pop up views
	var list: [UIView]
	
	// set default frame dimensions (for within board)
	let basicFrame: CGRect = {
		let width = Globals.boardSize - Globals.leftAlign
		let height = Globals.boardSize / 2
		let x = Int(Globals.boardRect.minX) + Globals.leftAlign / 2
		let y = Int(Globals.boardRect.minY) + height / 2
		return CGRect(x: x, y: y, width: width, height: height)
	}()
	
	// inits with empty pop up list
	init() {
		list = []
	}
	
	// creates personal best pop up, adds it to list
	func personalBest(type: String, value: String) {
		let view = PopUpView(frame: basicFrame)
		var message = "New best time for this difficulty at \(value)"
		if type == "moves" {
			message = "New least moves for this difficulty with \(value)"
		}
		view.setValues(title: "Congratulations!!", message: message)
		list.append(view)
	}
	
	// display list
	func displayList(view: UIViewController) {
		for i in list.reversed() {
			view.view.addSubview(i)
			if i == list.first! {
				i.animateShow(duration: 0.3, delay: 0.7)
			} else {
				i.animateShow(duration: 0.1, delay: 0.8)
			}
		}
	}
}

class PopUpView: UIView {
	
	// title label
	let titleLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Title"
		label.textColor = HomeController.foregroundColor
		label.textAlignment = .center
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		
		return label
	}()
	
	// display message
	let messageLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Message"
		label.textColor = HomeController.foregroundColor
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: Globals.font)
		
		return label
	}()
	
	// dismiss button
	let dismissButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = HomeController.foregroundColor
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("OK!", for: .normal)
		button.titleLabel?.text = "OK!"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(HomeController.backgroundColor, for: .normal)
		
		button.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
		return button
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		isHidden = true
		backgroundColor = HomeController.backgroundColor
		layer.cornerRadius = 10
		let borderSize = CGFloat(frame.height / 16)
		// set positions
		titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 3)
		messageLabel.frame = CGRect(x: 0, y: frame.height / 3,
									width: frame.width, height: frame.height / 3 - borderSize)
		dismissButton.frame = CGRect(x: frame.width / 3, y: frame.height / 3 * 2,
									 width: frame.width / 3 - borderSize, height: frame.height / 3 - borderSize)
		// views
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(dismissButton)
	}
	
	func setValues(title: String, message: String) {
		titleLabel.text = title
		messageLabel.text = message
	}
	
	// dismiss button action
	@objc func dismissAction(_ sender: UIButton) {
		animateHide(duration: 0.2, delay: 0.1)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
