//
//  TilesController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/2/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class TilesController: UICollectionViewController {
	
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
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		return label
	}()
	// shows time
	static let timerLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		return label
	}()
	
	// show image button
	let showButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = .black
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Show", for: .normal)
		button.titleLabel?.text = "Show"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(.white, for: .normal)

		let width =  Globals.width / 4
		let height = Globals.smallTop
		let x = Globals.xCenter - width * 3 / 2
		let y = Int(Globals.boardRect.maxY)
		button.frame = CGRect(x: x, y: y, width: width, height: height)
		
		button.addTarget(self, action: #selector(showImage(_:)), for: .touchUpInside)
		
		return button
	}()
	
	// show image button
	let checkButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = .black
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Check", for: .normal)
		button.titleLabel?.text = "Check"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(.white, for: .normal)
		
		let width =  Globals.width / 4
		let height = Globals.smallTop
		let x = Globals.xCenter + width / 2
		let y = Int(Globals.boardRect.maxY)
		button.frame = CGRect(x: x, y: y, width: width, height: height)
		
		button.addTarget(self, action: #selector(checkTilesPressed(_:)), for: .touchDown)
		button.addTarget(self, action: #selector(checkTilesRelease(_:)), for: .touchUpInside)
		
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// set navigation bar
		navigationItem.title = "Tile Game"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButton(_:)))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetBoard(_:)))
		collectionView.backgroundColor = .white
		
		TilesController.isCompleted = false
		
		let topY = Globals.topAlign / 2 + Globals.smallTop / 2
		TilesController.moveLabel.frame = CGRect(x: Globals.leftAlign * 2, y: topY,
								 width: Globals.xCenter, height: Globals.smallTop)
		TilesController.timerLabel.frame = CGRect(x: Globals.xCenter, y: topY,
												 width: Globals.xCenter, height: Globals.smallTop)
		
		// loads current board data if there is any
		if inProgress {
			loadCurrentData()
		} else {
			board.setValues(newImage: display!, newSize: boardSize, index: imageIndex, type: type)
			board.shuffleBoard()
			TilesController.timerLabel.text = "Timer:  00:00:00"
			TilesController.moveLabel.text = "Moves: \(0)"
		}
		
		view.addSubview(board)
		collectionView.addSubview(showButton)
		collectionView.addSubview(checkButton)
		collectionView.addSubview(TilesController.timerLabel)
		collectionView.addSubview(TilesController.moveLabel)
	}
	
	// shows image
	@objc func showImage(_ sender: UIButton) {
		if TilesController.isCompleted {
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
		if TilesController.isCompleted {
			return
		}
		board.moves += 10
		TilesController.moveLabel.text = "Moves: \(board.moves)"
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
	
	// returns to original shuffled state
	@objc func resetBoard(_ sender: UIBarButtonItem) {
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
		display = UIImage(named: "\(i)_\(type)")
		boardSize = difficulty
	}

	// load current board data
	func loadCurrentData() {
		let defaults = UserDefaults.standard
		// display information
		imageIndex = defaults.integer(forKey: "index")
		type = defaults.string(forKey: "type")!
		display = UIImage(named: "\(imageIndex)_\(type)")
		boardSize = defaults.integer(forKey: "size")
		// set board values
		board.setValues(newImage: display!, newSize: boardSize, index: imageIndex, type: type)
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
		board.timer.startTimer()
	}
}
