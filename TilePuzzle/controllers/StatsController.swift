//
//  StatsController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/13/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit
import CoreData

class StatsController: UIViewController {
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	let xOffset = (Globals.width - Globals.leftAlign * 2) / 3
	
	var leastMoves = [0, 0, 0, 0]
	var minTime = [0.0, 0.0, 0.0, 0.0]
	
	let totalLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Total Puzzles Completed:  \(0)"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textAlignment = .center
		label.frame = CGRect(x: Globals.leftAlign, y: Globals.topAlign + Globals.smallTop / 2,
							 width: Globals.width - Globals.leftAlign, height: Globals.smallTop)
		return label
	}()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		totalLabel.textColor = HomeController.foregroundColor
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Stats & Achievements"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		view.backgroundColor = HomeController.backgroundColor
		
		loadStats()
		
		view.addSubview(totalLabel)
		createTitleLabel()
		createTable()
	}
	
	// creates title table
	func createTitleLabel() {
		let names = ["Difficulty", "Best Time", "Least Moves"]
		
		for i in 0...names.count - 1 {
			let label = UILabel()
			
			label.text = "\(names[i])"
			label.textColor = HomeController.foregroundColor
			label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			let x = Globals.leftAlign + xOffset * i
			label.frame = CGRect(x: x, y: Globals.topAlign * 2, width: xOffset, height: Globals.smallTop)
			view.addSubview(label)
		}
	}
	
	// crate stat "table" rows
	func createRows(difficulty: Int, currentY: Int) {
		let names = ["\(difficulty)", formatTime(counter: minTime[difficulty - 3]),
			"\(leastMoves[difficulty - 3])"]
		
		for i in 0...names.count - 1 {
			let label = UILabel()
			
			label.text = names[i]
			label.textColor = HomeController.foregroundColor
			label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			let x = Globals.leftAlign + xOffset * i
			label.frame = CGRect(x: x, y: currentY, width: xOffset, height: Globals.smallTop)
			view.addSubview(label)
		}
	}
	
	// create stat "table"
	func createTable() {
		let difficulties = [3, 4, 5, 6]
		let initY = Globals.topAlign * 2 + Globals.smallTop
		
		for i in 0...difficulties.count - 1 {
			createRows(difficulty: difficulties[i], currentY: initY + Globals.topAlign / 2 * i)
		}
	}
	
	// loads stats from core data
	func loadStats() {
		var stats: [Stats?] = persistenceManager!.fetchStat()
		if stats.isEmpty {
			return
		}
		totalLabel.text = "Total Puzzles Completed:  \(stats[0]!.total!.reduce(0, +))"
		leastMoves = stats[0]!.leastMoves!
		minTime = stats[0]!.minTimes!
	}
	
	// formats current time
	func formatTime(counter: Double) -> String {
		let minutes = Int(counter) / 60 % 60
		let seconds = Int(counter) % 60
		let mili = Int(counter * 10) - Int(counter) * 10
		return String(format: "%02i:%02i.%01i", minutes, seconds, mili)
	}
}
