//
//  StatsController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/13/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class StatsController: UIViewController {
	
	let xOffset = (Globals.width - Globals.leftAlign * 2) / 3
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Puzzle Stats"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		view.backgroundColor = .white
		
		createTitleLabel()
		createTable()
	}
	
	// creates title table
	func createTitleLabel() {
		let names = ["Difficulty", "Best Time", "Least Moves"]
		
		for i in 0...names.count - 1 {
			let label = UILabel()
			
			label.text = "\(names[i])"
			label.textColor = .black
			label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			let x = Globals.leftAlign + xOffset * i
			label.frame = CGRect(x: x, y: Globals.topAlign * 2, width: xOffset, height: Globals.smallTop)
			view.addSubview(label)
		}
	}
	
	// crate stat "table" rows
	func createRows(difficulty: Int, currentY: Int) {
		let names = ["\(difficulty)", "0", "0"]
		for i in 0...names.count - 1 {
			let label = UILabel()
			
			label.text = names[i]
			label.textColor = .black
			label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			let x = Globals.leftAlign + xOffset * i
			label.frame = CGRect(x: x, y: currentY, width: xOffset, height: Globals.smallTop)
			view.addSubview(label)
		}
	}
	
	// create stat "table"
	func createTable() {
		let difficulties = [3, 4, 5, 6]
		let initY = Globals.topAlign * 3
		
		for i in 0...difficulties.count - 1 {
			createRows(difficulty: difficulties[i], currentY: initY + Globals.smallTop * i)
		}
	}
}
