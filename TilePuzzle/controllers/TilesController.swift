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
	
	var pauseButtons: [UIButton] = []
	static var completedMenuButton: UIButton = UIButton(frame: Globals.boardRect)
	static var completedRestartButton: UIButton = UIButton(frame: Globals.boardRect)
	static var completedNextDifficulty: UIButton = UIButton(frame: Globals.boardRect)
	static var completedNextPuzzle: UIButton = UIButton(frame: Globals.boardRect)
	
	static var isCompleted = false
	var inProgress = false
	
	// shown to cover bottom buttons when puzzle completes
	static let coverView: UIView = {
		let view = UIView()
		view.backgroundColor = HomeController.backgroundColor
		view.frame = CGRect(x: 0, y: Globals.height / 2, width: Globals.width, height: Globals.height / 2)
		view.isHidden = true
		return view
	}()
	
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
	
	// resets puzzle
	func resetPuzzle() {
		TilesController.coverView.isHidden = true
		TilesController.completedView.isHidden = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// set navigation bar
		navigationItem.title = "Tile Game"
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.backgroundColor = .white
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(pauseButton(_:)))
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
		
		pauseButtons = createPauseButtons()
		resetPuzzle()
		
		view.addSubview(howToButton)
		view.addSubview(showButton)
		view.addSubview(checkButton)
		view.addSubview(removeButton)
		
		view.addSubview(TilesController.coverView)
		view.addSubview(board)

		view.addSubview(TilesController.timerLabel)
		view.addSubview(TilesController.moveLabel)
		view.addSubview(TilesController.completedImage)
		
		view.addSubview(pauseMenu)
		for i in pauseButtons {
			view.addSubview(i)
		}
		view.addSubview(TilesController.completedView)
	}
	
	// shows image
	@objc func showImage(_ sender: UIButton) {
		if TilesController.isCompleted || !board.howToView!.isHidden || !pauseMenu.isHidden {
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
		if TilesController.isCompleted || !board.display.isHidden ||
			!board.howToView!.isHidden || !pauseMenu.isHidden {
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
		if TilesController.isCompleted || !board.display.isHidden || !pauseMenu.isHidden {
			return
		}
		board.howToView!.setHidden()
	}
	
	// resume function
	func resumeFunc() {
		if board.isMoving {
			board.timer.startTimer()
		}
		pauseMenu.isHidden = true
		for i in pauseButtons {
			i.isHidden = true
		}
		board.alpha = 1.0
		board.isUserInteractionEnabled = true
		checkButton.isEnabled = true
		showButton.isEnabled = true
	}
	// pause button
	@objc func pauseButton(_ sender: UIBarButtonItem) {
		if TilesController.isCompleted {
			return
		}
		if pauseMenu.isHidden {
			board.timer.pauseTimer()
			pauseMenu.isHidden = false
			for i in pauseButtons {
				i.isHidden = false
			}
			board.alpha = 0.5
			board.isUserInteractionEnabled = false
			checkButton.isEnabled = false
			showButton.isEnabled = false
		} else {
			resumeFunc()
		}
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
	
	// pause menu functions:
	// creates pause buttons
	func createPauseButtons() -> [UIButton] {
		let pw = Globals.width / 2
		let ph = Globals.boardSize - Globals.boardSize / 8
		var buttonY = (ph / 2) + (ph / 3) + (ph / 8)
		
		let buttonTitles = ["Resume", "Menu", "Reset"]
		var buttons: [UIButton] = []
		
		for i in buttonTitles {
			let button = UIButton()
			
			button.backgroundColor = HomeController.backgroundColor
			button.layer.cornerRadius = 10
			button.layer.borderWidth = 1
			button.layer.borderColor = HomeController.foregroundColor.cgColor
			button.showsTouchWhenHighlighted = true
			
			button.setTitle(i, for: .normal)
			button.titleLabel?.text = i
			button.titleLabel?.font = UIFont.systemFont(ofSize: Globals.boldFont)
			button.setTitleColor(HomeController.foregroundColor, for: .normal)
			
			button.frame = CGRect(x: pw * 3 / 4, y: buttonY,
								  width: pw / 2, height: ph / 10)
			buttonY += ph / 6
			
			button.isHidden = true
			buttons.append(button)
		}
		buttons[0].addTarget(self, action: #selector(resumeButton(_:)), for: .touchUpInside)
		buttons[1].addTarget(self, action: #selector(menuButton(_:)), for: .touchUpInside)
		buttons[2].addTarget(self, action: #selector(resetBoard(_:)), for: .touchUpInside)
		
		return buttons
	}
	
	// pause title
	static let pauseTitle: UILabel = {
		let label = UILabel()
		
		label.text = "Paused"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont * 2)
		label.textAlignment = .center
		label.textColor = HomeController.foregroundColor
		
		return label
	}()
	
	// pause menu imageView
	let pauseMenu: UIView = {
		let pauseView = UIImageView()
		
		pauseView.backgroundColor = HomeController.backgroundColor
		pauseView.layer.cornerRadius = 10
		
		let height = Globals.boardSize - Globals.boardSize / 8
		pauseView.frame = CGRect(x: Globals.width / 4, y: Globals.height / 2 - height / 2,
							width: Globals.width / 2, height: height)
		
		TilesController.pauseTitle.frame = CGRect(x: 0, y: pauseView.frame.height / 32,
			width: pauseView.frame.width, height: pauseView.frame.height / 8)
		
		pauseView.isHidden = true
		pauseView.addSubview(TilesController.pauseTitle)
		return pauseView
	}()
	
	// button actions for pause menu
	// menu button
	@objc func menuButton(_ sender: UIButton) {
		navigationController?.popToRootViewController(animated: true)
	}
	// resume button from menu
	@objc func resumeButton(_ sender: UIButton) {
		resumeFunc()
	}
	// returns to original shuffled state
	@objc func resetBoard(_ sender: UIButton) {
		if TilesController.isCompleted || !board.display.isHidden || !board.howToView!.isHidden {
			return
		}
		board.display.isHidden = true
		board.resetBoard()
		resumeFunc()
	}
	
	// completed view
	// title
	static let completedTitle: UILabel = {
		let label = UILabel()
		label.text = "Completed!"
		label.textColor = HomeController.foregroundColor
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: Globals.boldFont * 2)
		return label
	}()
	
	// random button
	static let randomButton: UIButton = {
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
		
		button.addTarget(self, action: #selector(nextRandom(_:)), for: .touchUpInside)
		
		return button
	}()
	
	static func createCompletedButton(title: String, num: Int) -> UIButton {
		let width = Globals.boardSize * 2 / 3
		let height = Globals.boardSize - Globals.boardSize / 16
		
		let button = UIButton()
		button.backgroundColor = HomeController.backgroundColor
		button.layer.cornerRadius = 10
		button.layer.borderWidth = 1
		button.layer.borderColor = HomeController.foregroundColor.cgColor
		button.showsTouchWhenHighlighted = true
		
		button.setTitle(title, for: .normal)
		button.titleLabel?.text = title
		button.titleLabel?.font = UIFont.systemFont(ofSize: Globals.boldFont)
		button.setTitleColor(HomeController.foregroundColor, for: .normal)
		
		let cbWidth = width * 2 / 3
		let buttonY = height / 4
		button.frame = CGRect(x: width  / 2 - cbWidth / 2, y: buttonY + (height / 8 * num),
							  width: cbWidth, height: height / 10)
		
		return button
	}
	
	static let completedView: UIView = {
		let view = UIView()
		
		view.isHidden = true
		view.backgroundColor = HomeController.backgroundColor
		view.layer.cornerRadius = 10
		view.layer.borderColor = HomeController.foregroundColor.cgColor
		view.layer.borderWidth = 2

		let width = Globals.boardSize * 2 / 3
		let height = Globals.boardSize - Globals.boardSize / 16
		let boardCenter = Int(Globals.boardRect.maxY + Globals.boardRect.minY) / 2
		let borderSize = height / 16
		view.frame = CGRect(x: Globals.width / 2 - width / 2, y: boardCenter - height / 2,
								 width: width, height: height)
		
		// completed title frame
		TilesController.completedTitle.frame = CGRect(x: 0, y: borderSize,
													  width: width, height: height / 8)
		// random frame
		TilesController.randomButton.frame = CGRect(x: width - borderSize * 3 / 2, y: height / 8 + borderSize * 3 / 2,
									width: borderSize, height: borderSize)
		
		// create completed buttons
		TilesController.completedMenuButton = TilesController.createCompletedButton(title: "Menu", num: 0)
		TilesController.completedRestartButton = TilesController.createCompletedButton(title: "Restart", num: 1)
		TilesController.completedNextDifficulty = TilesController.createCompletedButton(title: "Next Difficulty", num: 2)
		TilesController.completedNextPuzzle = TilesController.createCompletedButton(title: "Next Puzzle", num: 3)
		
		TilesController.completedMenuButton.addTarget(self, action: #selector(menuButton(_:)), for: .touchUpInside)
		TilesController.completedRestartButton.addTarget(self, action: #selector(restartPuzzle(_:)), for: .touchUpInside)
		TilesController.completedNextDifficulty.addTarget(self, action: #selector(nextDifficulty(_:)), for: .touchUpInside)
		TilesController.completedNextPuzzle.addTarget(self, action: #selector(nextPuzzle(_:)), for: .touchUpInside)
		
		view.addSubview(TilesController.completedTitle)
		view.addSubview(TilesController.randomButton)
		view.addSubview(TilesController.completedMenuButton)
		view.addSubview(TilesController.completedRestartButton)
		view.addSubview(TilesController.completedNextDifficulty)
		view.addSubview(TilesController.completedNextPuzzle)
		
		return view
	}()
	
	// button actions for completed view
	// goes to new random tile
	@objc func nextRandom(_ sender: UIButton) {
		let randomDifficulty = (3...6).randomElement()!
		let randomCatagory = (0...Globals.totalCatagories).randomElement()!
		var randomImage = 0
		var randomType = "pets"
		// check if custom is empty
		let custom = persistenceManager!.fetchCustom()
		if randomCatagory == 0 {
			if custom.isEmpty {
				randomImage = (0...Globals.numCatagories[0] - 1).randomElement()!
			} else {
				randomImage = (0...custom.count - 1).randomElement()!
				randomType = "custom"
			}
		} else {
			randomImage = (0...Globals.numCatagories[randomCatagory - 1] - 1).randomElement()!
			randomType = Globals.catagories[randomCatagory - 1]
		}
		
		let controller = TilesController()
		controller.setDisplay(i: randomImage, difficulty: randomDifficulty, type: randomType)
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// restart board
	@objc func restartPuzzle(_ sender: UIButton) {
		board.display.isHidden = true
		board.resetBoard()
		resumeFunc()
		resetPuzzle()
		TilesController.isCompleted = false
	}
	
	// next difficulty
	@objc func nextDifficulty(_ sender: UIButton) {
		let controller = TilesController()
		controller.setDisplay(i: imageIndex, difficulty: boardSize + 1, type: type)
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// next puzzle
	@objc func nextPuzzle(_ sender: UIButton) {
		let controller = TilesController()
		controller.setDisplay(i: imageIndex + 1, difficulty: 3, type: type)
		navigationController?.pushViewController(controller, animated: true)
	}
}
