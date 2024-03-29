//
//  PictureClasses.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/14/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class PictureClass: UIView {
	
	var size: Int
	var type: Int = 0
	var index: Int = 0
	var button: UIButton
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	
	override init(frame: CGRect) {
		self.size = Int(frame.width)
		self.button = UIButton()
		
		super.init(frame: frame)
	}
	
	func setValues(button: UIButton, type: Int, index: Int) {
		self.button = button
		self.type = type
		self.index = index
		
		createVisuals()
		addSubview(button)
	}
	
	// creates completed visuals
	func createVisuals() {
		// return if "random" tile
		if index < 0 {
			return
		}

		var completedArray = [0, 0, 0, 0]	// placeholder
		if type < 0 {
			// custom image
			let custom = persistenceManager!.fetchCustom()
			completedArray = custom[index].completed!
		} else {
			// normal image
			let stats: [Stats?] = persistenceManager!.fetchStat()
			completedArray = stats[0]!.completed![type][index]
		}
		
		for i in 0...completedArray.count - 1 {
			let label = UILabel()
			
			label.layer.borderWidth = 2
			label.layer.cornerRadius = 4
			label.layer.borderColor = HomeController.foregroundColor.cgColor
			label.clipsToBounds = true
			
			if completedArray[i] >= 1 {
				label.backgroundColor = HomeController.foregroundColor
			}
			
			let width = size / 9
			let x = width + width * i * 2
			let y = size + width / 2
			label.frame = CGRect(x: x, y: y, width: width, height: width)
			
			addSubview(label)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// loads custom image from core data
class LoadCustom {
	static let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	static func loadCustomImage(index: Int) -> UIImage {
		let custom = LoadCustom.persistenceManager!.fetchCustom()
		let customData = custom[index].image
		let image = UIImage(data: customData!)
		return image!
	}
	
	static func loadCustomColor(name: String) -> UIColor {
		var color = UIColor.white
		if name == "black" {
			color = UIColor.black
		}
		return color
	}
	
	static func getStringColor(color: UIColor) -> String {
		var name = "white"
		if color == UIColor.black {
			name = "black"
		}
		return name
	}
}
