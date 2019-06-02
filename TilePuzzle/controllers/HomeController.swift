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
	var buttons: [UIButton] = []		// placeholder for menu buttons
	var inProgress = false				// if a puzzle is in progress
	// determines 'color' mode
	static var backgroundColor = UIColor.white
	static var foregroundColor = UIColor.black
	
	// main title label
	let titleLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Tile Puzzle"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont * 2)
		label.textAlignment = .center
		label.frame = CGRect(x: 0, y: Globals.smallTop * 2,
							 width: Globals.width, height: Globals.topAlign)
		return label
	}()
	
	// dark mode button
	let darkModeButton: UIButton = {
		let button = UIButton()
		
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		let size = Globals.leftAlign
		let y = Globals.topAlign / (1 + Globals.ipadMultiplier) + Globals.smallTop / 2
		button.frame = CGRect(x: Globals.width - size * 2, y: y, width: size, height: size)
		
		button.addTarget(self, action: #selector(changeMode(_:)), for: .touchUpInside)
		return button
	}()
	
	// checks if there is saved data before controller loads
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		let defaults = UserDefaults.standard
		// if saved data exists show continue button, otherwise hide
		// sets progress boolean accordingly
		if defaults.integer(forKey: "size") == 0 {
			buttons[0].isHidden = true
			inProgress = false
		} else {
			buttons[0].isHidden = false
			inProgress = true
		}
	}
	
	func setColors() {
		let defaults = UserDefaults.standard
		// sets correct colors
		if defaults.string(forKey: "background") != nil {
			HomeController.backgroundColor = LoadCustom.loadCustomColor(name: defaults.string(forKey: "background")!)
			HomeController.foregroundColor = LoadCustom.loadCustomColor(name: defaults.string(forKey: "foreground")!)
		} else {
			// save mode colors
			defaults.set("white", forKey: "background")
			defaults.set("black", forKey: "foreground")
		}
		titleLabel.textColor = HomeController.foregroundColor
		darkModeButton.backgroundColor = HomeController.foregroundColor
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setColors()
		view.backgroundColor = HomeController.backgroundColor // sets background to white
		navigationItem.hidesBackButton = true	// hides back button, nothing to go back to
		
		initStatVals()
		
		view.addSubview(titleLabel)
		view.addSubview(darkModeButton)
		createButtons()
	}
	
	// creates home menu buttons
	func createButtons() {
		let titles = ["Continue", "New", "Stats", "Custom Image"]
		
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
			
			buttons[i].backgroundColor = HomeController.foregroundColor
			buttons[i].layer.cornerRadius = 10
			buttons[i].showsTouchWhenHighlighted = true
			// set title
			buttons[i].setTitle("\(titles[i])", for: .normal)
			buttons[i].titleLabel?.text = "\(titles[i])"
			buttons[i].setTitleColor(HomeController.backgroundColor, for: .normal)
			buttons[i].titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			view.addSubview(buttons[i]) // add buttons to subview
		}
		
		buttons[0].addTarget(self, action: #selector(currentAction(_:)), for: .touchUpInside)
		buttons[1].addTarget(self, action: #selector(newAction(_:)), for: .touchUpInside)
		buttons[2].addTarget(self, action: #selector(pushStats(_:)), for: .touchUpInside)
		buttons[3].addTarget(self, action: #selector(pushCustom(_:)), for: .touchUpInside)
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
		let controller = TilesController()
		controller.inProgress = true
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// goes to stats controller
	@objc func pushStats(_ sender: UIButton) {
		let controller = StatsController()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// pushs to custom image creation
	@objc func pushCustom(_ sender: UIButton) {
		let controller = CustomController()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// converts to dark/light mode
	@objc func changeMode(_ sender: UIButton) {
		if HomeController.backgroundColor == .white {
			HomeController.backgroundColor = .black
			HomeController.foregroundColor = .white
		} else {
			HomeController.backgroundColor = .white
			HomeController.foregroundColor = .black
		}
		
		UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseInOut, animations: {
			self.darkModeButton.backgroundColor = HomeController.foregroundColor
			self.view.backgroundColor = HomeController.backgroundColor
			self.titleLabel.textColor = HomeController.foregroundColor
			for i in self.buttons {
				i.backgroundColor = HomeController.foregroundColor
				i.setTitleColor(HomeController.backgroundColor, for: .normal)
			}
		}, completion: { _ in
			// save mode colors
			let defaults = UserDefaults.standard
			defaults.set(LoadCustom.getStringColor(color: HomeController.backgroundColor), forKey: "background")
			defaults.set(LoadCustom.getStringColor(color: HomeController.foregroundColor), forKey: "foreground")
		})
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
	
	// appends to array if array has changed
	func checkCompletedArray(array: [[[Int]]]) -> [[[Int]]] {
		var temp = array
		// checks if enough catagories
		while temp.count < Globals.totalCatagories {
			temp.append([])
		}
		// checks if catagories are filled
		for i in 0...Globals.totalCatagories - 1 {
			while temp[i].count < Globals.numCatagories[i] {
				temp[i].append([0, 0, 0, 0])
			}
		}
		return temp
	}
	
	// initialize stats values if they aren't found
	func initStatVals() {
		// set up stats
		var stats = persistenceManager!.fetchStat()
		if !stats.isEmpty {
			if stats[0].completed![0].isEmpty || stats[0].completed![0][0].isEmpty {
				stats[0].completed! = createCompletedArray()
			} else {
				stats[0].completed! = checkCompletedArray(array: stats[0].completed!)
			}
		} else {
			let createStat = Stats(context: persistenceManager!.context)
			stats.append(createStat.configure(total: [0, 0, 0, 0], leastMoves: [0, 0, 0, 0],
											  minTimes: [0.0, 0.0, 0.0, 0.0],
											  completed: createCompletedArray()))
		}
		
		persistenceManager!.save()	// save data
	}
	
	// change to light status bar
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
