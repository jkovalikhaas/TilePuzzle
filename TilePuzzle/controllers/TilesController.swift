//
//  TilesController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/2/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class TilesController: UIViewController {
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	
	var display = UIImage(named: "0_pets")
	var board = TileBoard(frame: Globals.boardRect)
	var boardSize = 3
	var imageIndex = 0
	var type = Globals.catagories[0]
	
	static var isCompleted = false
	var inProgress = false
	
	// shows number of moves
	static let moveLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		return label
	}()
	// shows time
	static let timerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		return label
	}()
	// image to indicate if puzzle has been completed
	static let completedImage: UIImageView = {
		let imageView = UIImageView()

		imageView.layer.cornerRadius = 10
		imageView.clipsToBounds = true
		
		let size = Globals.leftAlign
		let y = Globals.topAlign / (1 + Globals.ipadMultiplier) + Globals.smallTop / 2
		imageView.frame = CGRect(x: Globals.width - size * 4, y: y, width: size, height: size)
		imageView.isHidden = true
		return imageView
	}()
	
	// show "how to" image
	let howToButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = HomeController.backgroundColor
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		button.layer.borderColor = HomeController.foregroundColor.cgColor
		button.layer.borderWidth = 1
		
		button.setTitle("?", for: .normal)
		button.titleLabel?.text = "?"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(HomeController.foregroundColor, for: .normal)
		
		let size = Globals.leftAlign
		let y = Globals.topAlign / (1 + Globals.ipadMultiplier) + Globals.smallTop / 2
		button.frame = CGRect(x: Globals.width - size * 2, y: y, width: size, height: size)
		button.addTarget(self, action: #selector(showHowTo(_:)), for: .touchUpInside)
		
		return button
	}()
	
	// show image button
	let showButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = HomeController.foregroundColor
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Show", for: .normal)
		button.titleLabel?.text = "Show"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(HomeController.backgroundColor, for: .normal)

		let width =  Globals.width / 4
		let height = Globals.smallTop
		let x = Globals.xCenter - width * 3 / 2
		let y = Int(Globals.boardRect.maxY) + Globals.smallTop
		button.frame = CGRect(x: x, y: y, width: width, height: height)
		
		button.addTarget(self, action: #selector(showImage(_:)), for: .touchUpInside)
		
		return button
	}()
	
	// show image button
	let checkButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = HomeController.foregroundColor
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Check", for: .normal)
		button.titleLabel?.text = "Check"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(HomeController.backgroundColor, for: .normal)
		
		let width =  Globals.width / 4
		let height = Globals.smallTop
		let x = Globals.xCenter + width / 2
		let y = Int(Globals.boardRect.maxY) + Globals.smallTop
		button.frame = CGRect(x: x, y: y, width: width, height: height)

		button.addTarget(self, action: #selector(checkTilesPressed(_:)), for: .touchDown)
		button.addTarget(self, action: #selector(checkTilesRelease(_:)), for: .touchUpInside)
		
		return button
	}()
	
	// remove custom image from button memory
	let removeButton: UIButton = {
		let button = UIButton()
		button.isHidden = true
		
		button.backgroundColor = .red
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Remove", for: .normal)
		button.titleLabel?.text = "Remove"
		button.titleLabel?.font = UIFont.systemFont(ofSize: Globals.font)
		button.setTitleColor(.white, for: .normal)
		
		let width =  Globals.width / 5
		let height = Globals.smallTop / 2
		let x = Globals.xCenter - width / 2
		let y = Globals.height - Globals.topAlign
		button.frame = CGRect(x: x, y: y, width: width, height: height)
		
		button.addTarget(self, action: #selector(removeCustomImage(_:)), for: .touchUpInside)
		
		return button
	}()
	
	// what to do before view appears
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// set mode color
		let color = LoadCustom.getStringColor(color: HomeController.foregroundColor)
		TilesController.completedImage.image = UIImage(named: "completed_\(color)")
		TilesController.completedImage.backgroundColor = HomeController.backgroundColor
		TilesController.completedImage.layer.borderWidth = 1
		TilesController.completedImage.layer.borderColor = HomeController.foregroundColor.cgColor
		
		TilesController.moveLabel.textColor = HomeController.foregroundColor
		TilesController.timerLabel.textColor = HomeController.foregroundColor
		hideCompleted() // determines if current puzzle has been completed
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// set navigation bar
		navigationItem.title = "Tile Game"
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.backgroundColor = .white
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButton(_:)))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetBoard(_:)))
		view.backgroundColor = HomeController.backgroundColor
		
		TilesController.isCompleted = false
		
		let topY = Globals.topAlign + Globals.smallTop * 3 / 2
		TilesController.moveLabel.frame = CGRect(x: Globals.leftAlign * 2, y: topY,
								 width: Globals.xCenter, height: Globals.smallTop)
		TilesController.timerLabel.frame = CGRect(x: Globals.xCenter, y: topY,
												 width: Globals.xCenter, height: Globals.smallTop)
		
		// loads current board data if there is any
		if inProgress {
			loadCurrentData()
		} else {
			board.setValues(newImage: display!, newSize: boardSize, index: imageIndex, type: type)
			board.display.animateHide()
			
			board.shuffleBoard()
			TilesController.timerLabel.text = "Timer:  00:00:00"
			TilesController.moveLabel.text = "Moves: \(0)"
		}
		// reveal remove button if a custom image
		if type == "custom" {
			removeButton.isHidden = false
		}
		
		view.addSubview(board)
		view.addSubview(howToButton)
		view.addSubview(showButton)
		view.addSubview(checkButton)
		
		view.addSubview(TilesController.timerLabel)
		view.addSubview(TilesController.moveLabel)
		view.addSubview(TilesController.completedImage)
		view.addSubview(removeButton)
	}
	
	// shows image
	@objc func showImage(_ sender: UIButton) {
		if TilesController.isCompleted || !board.howToView!.isHidden {
			return
		}
		if board.display.isHidden == false {
			board.display.isHidden = true
			showButton.setTitle("Show", for: .normal)
			showButton.titleLabel?.text = "Show"
		} else {
			board.display.isHidden = false
			showButton.setTitle("Hide", for: .normal)
			showButton.titleLabel?.text = "Hide"
		}
	}
	
	/// for checking image
	// shows correct tiles
	@objc func checkTilesPressed(_ sender: UIButton) {
		if TilesController.isCompleted || !board.display.isHidden || !board.howToView!.isHidden {
			return
		}
		board.moves += 10
		TilesController.moveLabel.text = "Moves: \(board.moves)"
		board.saveCurrentData()
		let goal = Array(0...board.length - 1)
		for i in 0...board.board.count - 1 {
			if goal[i] != board.map[i] && i != board.findBlank() {
				board.board[i].isHidden = true
			}
		}
	}
	
	// clears shown tiles
	@objc func checkTilesRelease(_ sender: UIButton) {
		for i in 0...board.board.count - 1 {
			if i != board.findBlank() {
				board.board[i].isHidden = false
			}
		}
	}
	/// end of checking image
	
	// hides/shows how to view
	@objc func showHowTo(_ sender: UIButton) {
		if TilesController.isCompleted || !board.display.isHidden {
			return
		}
		board.howToView!.setHidden()
	}
	
	// returns to original shuffled state
	@objc func resetBoard(_ sender: UIBarButtonItem) {
		if TilesController.isCompleted || !board.display.isHidden || !board.howToView!.isHidden {
			return
		}
		board.display.isHidden = true
		board.resetBoard()
	}
	
	// back button
	@objc func homeButton(_ sender: UIBarButtonItem) {
		board.timer.pauseTimer()
		navigationController?.popToRootViewController(animated: true)
	}

	// set display
	func setDisplay(i: Int, difficulty: Int, type: String) {
		imageIndex = i
		self.type = type
		if self.type == "custom" {
			display = LoadCustom.loadCustomImage(index: i)
		} else {
			display = UIImage(named: "\(i)_\(type)")
		}
		boardSize = difficulty
	}
	
	// removes custom image from memory
	@objc func removeCustomImage(_ sender: UIButton) {
		board.timer.resetTimer()
		board.resetCurrentData()
		let custom = persistenceManager!.fetchCustom()
		persistenceManager!.delete(custom[imageIndex])
		navigationController?.popToRootViewController(animated: true) // return to root
	}
	
	// determines if current puzzle has been completed
	func hideCompleted() {
		var currentPuzzle = 0
		if self.type == "custom" {
			let custom = persistenceManager!.fetchCustom()
			currentPuzzle = custom[imageIndex].completed![boardSize - 3]
		} else {
			let stats: [Stats?] = persistenceManager!.fetchStat()
			let catagoryNum = Globals.catagories.firstIndex(of: type)!	// gets num of catagory
			currentPuzzle = stats[0]!.completed![catagoryNum][imageIndex][boardSize - 3]
		}
		// if completed show, else hide
		if currentPuzzle > 0 {
			TilesController.completedImage.isHidden = false
		} else {
			TilesController.completedImage.isHidden = true
		}
	}
	
	// load current board data
	func loadCurrentData() {
		let defaults = UserDefaults.standard
		// display information
		imageIndex = defaults.integer(forKey: "index")
		type = defaults.string(forKey: "type")!
		if type == "custom" {
			display = LoadCustom.loadCustomImage(index: imageIndex)
		} else {
			display = UIImage(named: "\(imageIndex)_\(type)")
		}
		boardSize = defaults.integer(forKey: "size")
		// set board values then hide display
		board.setValues(newImage: display!, newSize: boardSize, index: imageIndex, type: type)
		board.display.isHidden = true
		
		let shuffled = defaults.object(forKey: "shuffled") as? [Int] ?? [Int]()
		let map = defaults.object(forKey: "current") as? [Int] ?? [Int]()
		// changes board to current map
		board.changeBoard(array: map)
		board.shuffled = shuffled
		// set move variable and label
		let moves = defaults.integer(forKey: "moves")
		board.moves = moves
		TilesController.moveLabel.text = "Moves: \(moves)"
		// set timer counter and timer label
		let counter = defaults.double(forKey: "time")
		board.timer.counter = counter
		TilesController.timerLabel.text = board.timer.formatTime()
	}
}
