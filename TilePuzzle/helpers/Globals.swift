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
	
	// size of tile board
	static let boardSize = width - leftAlign * 2
	static let boardRect = CGRect(x: leftAlign, y: topAlign * 3, width: boardSize, height: boardSize)
	
	// num images/catagories
	static let numImages = 183
	static let totalCatagories = 15
	static let catagories = ["pets", "cats", "deer", "farm", "smam", "lmam", "pred", "prim",
							"sbirds", "lbirds", "amph", "rept", "seam", "fish", "bugs"]
	static let numCatagories = [10, 13, 13, 15, 14, 11, 12, 11, 14, 14, 10, 13, 11, 12, 10]
	
	static let catagoryTitles = ["Pets", "Big Cats", "Hooved Animals", "Farm Animals", "Small Mammals",
								"Large Mammals", "Carnivores", "Primates", "Small Birds", "Large Birds",
								"Small Reptiles", "Large Reptiles", "Marine Life", "Fish", "Bugs"]
}
