//
//  Globals.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/2/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class Globals {
	
	static let size = UIScreen.main.bounds	// gets size of screen
	static let width = Int(size.width)		// width of screen
	static let height = Int(size.height)	// height of screen
	
	static let xCenter = width / 2			// center of screen width
	static let yCenter = height / 2			// center of screen height
	
	// variables to help align viewcontrollers components
	static let topAlign = height / 12
	static let leftAlign = width / 16
	static let rightAlign = width - (width / 10)
	
	// smaller spacing
	static let smallTop = height / 16
	
	// size of fonts
	static let boldFont = CGFloat(xCenter / 10)
	static let font = CGFloat(xCenter / 15)
	
	// checks if ipad/iphone
	static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
	// used to format ipad
	static let ipadMultiplier: Int = {
		var num = 0
		if isIpad {
			num = 1
		}
		return num
	}()
	
	// size of tile board
	static let boardSize = width - leftAlign * (2 + ipadMultiplier)
	static let boardRect = CGRect(x: leftAlign + (leftAlign * ipadMultiplier / 2), y: topAlign * 3,
								  width: boardSize, height: boardSize)
	
	// num images/catagories
	static let numImages = 208
	static let totalCatagories = 15
	static let catagories = ["pets", "cats", "deer", "farm", "smam", "lmam", "pred", "prim",
							"sbirds", "lbirds", "amph", "rept", "seam", "fish", "bugs"]
	static let numCatagories = [12, 13, 14, 17, 14, 12, 15, 15, 16, 14, 12, 13, 12, 14, 15]
	
	static let catagoryTitles = ["Pets", "Big Cats", "Hooved Animals", "Farm Animals", "Small Mammals",
								"Large Mammals", "Carnivores", "Primates", "Small Birds", "Large Birds",
								"Small Reptiles", "Large Reptiles", "Marine Life", "Fish", "Bugs"]
}
