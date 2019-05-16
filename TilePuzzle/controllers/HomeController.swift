//
//  HomeController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/9/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit
import CoreData

class HomeController: UIViewController {
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	var buttons: [UIButton] = []	// placeholder for menu buttons
	var inProgress = false			// if a puzzle is in progress
	
	// main title label
	let titleLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Tile Puzzle"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont * 2)
		label.textColor = .black
		label.textAlignment = .center
		label.frame = CGRect(x: 0, y: Globals.smallTop * 2,
							 width: Globals.width, height: Globals.topAlign)
		return label
	}()
	// checks if there is saved data before controller loads
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		// if saved data exists show continue button, otherwise hide
		// sets progress boolean accordingly
		if UserDefaults.standard.integer(forKey: "size") == 0 {
			buttons[0].isHidden = true
			inProgress = false
		} else {
			buttons[0].isHidden = false
			inProgress = true
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white			// sets background to white
		navigationItem.hidesBackButton = true	// hides back button, nothing to go back to

		initStatVals()
		
		view.addSubview(titleLabel)
		createButtons()
	}
	
	// creates home menu buttons
	func createButtons() {
		let titles = ["Continue", "New", "Stats"]
		
		// sets uniform width, height, x, and y variables for the buttons
		let width = Globals.width - Globals.leftAlign * 2
		let height = Globals.smallTop
		let xOffset = Globals.leftAlign
		var yOffset = Globals.yCenter - height * titles.count
		
		// creates a buttons for each element of titles array
		for i in 0...titles.count - 1 {
			// placement for current button
			buttons.append(UIButton(frame: CGRect(x: xOffset, y: yOffset, width: width, height: height)))
			yOffset += height + Globals.smallTop / 2	// increases y
			
			buttons[i].backgroundColor = .black
			buttons[i].layer.cornerRadius = 10
			buttons[i].showsTouchWhenHighlighted = true
			// set title
			buttons[i].setTitle("\(titles[i])", for: .normal)
			buttons[i].titleLabel?.text = "\(titles[i])"
			buttons[i].titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			view.addSubview(buttons[i]) // add buttons to subview
		}
		
		buttons[0].addTarget(self, action: #selector(currentAction(_:)), for: .touchUpInside)
		buttons[1].addTarget(self, action: #selector(newAction(_:)), for: .touchUpInside)
		buttons[2].addTarget(self, action: #selector(pushStats(_:)), for: .touchUpInside)
	}
	
	/// actions for buttons
	// pushes to picture controller
	@objc func newAction(_ sender: UIButton) {
		if inProgress {
			progressAlert()
		} else {
			let controller = CatagoryController()
			navigationController?.pushViewController(controller, animated: true)
		}
	}
	
	// pushes to current tile puzzle
	@objc func currentAction(_ sender: UIButton) {
		let controller = TilesController(collectionViewLayout: UICollectionViewFlowLayout())
		controller.inProgress = true
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// goes to stats controller
	@objc func pushStats(_ sender: UIButton) {
		let controller = StatsController()
		navigationController?.pushViewController(controller, animated: true)
	}
	/// end of button actions
	
	/// pop up alerts
	// alerts user if puzzle in progress, resets data if confirmed
	func progressAlert() {
		let alert = UIAlertController(title: "Puzzle in progress", message: "Choosing new will remove saved progress",
									  preferredStyle: .alert)
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let confirm = UIAlertAction(title: "Yes", style: .default) { (_) in
			self.resetCurrentData() // resets data
			let controller = CatagoryController()
			self.navigationController?.pushViewController(controller, animated: true)
		}
		
		alert.addAction(confirm)
		alert.addAction(cancel)
		present(alert, animated: true, completion: nil)
	}
	/// end of alerts
	
	/// user default functions
	// resets current data to empty variables
	func resetCurrentData() {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: "index")
		defaults.removeObject(forKey: "type")
		defaults.removeObject(forKey: "size")
		defaults.removeObject(forKey: "shuffled")
		defaults.removeObject(forKey: "current")
		defaults.removeObject(forKey: "moves")
		defaults.removeObject(forKey: "time")
	}
	/// end of user defualt
	
	
	// creates completed array
	func createCompletedArray() -> [[[Int]]] {
		var returnArray: [[[Int]]] = []
		for i in 0...Globals.totalCatagories - 1 {
			var array: [[Int]] = []
			for _ in 0...Globals.numCatagories[i] - 1 {
				array.append([0, 0, 0, 0])
			}
			returnArray.append(array)
		}
		return returnArray
	}
	
	// initialize stats values if they aren't found
	func initStatVals() {
		var stats = persistenceManager!.fetchStat()
		if !stats.isEmpty {
			if stats[0].completed![0].isEmpty || stats[0].completed![0][0].isEmpty {
				stats[0].completed! = createCompletedArray()
				persistenceManager!.save()
			}
			return
		}

		let createStat = Stats(context: persistenceManager!.context)
		stats.append(createStat.configure(total: [0, 0, 0, 0], leastMoves: [0, 0, 0, 0],
										minTimes: [0.0, 0.0, 0.0, 0.0],
										completed: createCompletedArray()))
	
		persistenceManager!.save()
	}
}
