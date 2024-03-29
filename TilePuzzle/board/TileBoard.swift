//
//  TileBoard.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/3/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit
import CoreData

/**
 * Creates a interactable tile board based on image
 */

class TileBoard: UIView, UIGestureRecognizerDelegate {
	
	var image: UIImage
	var index = 0
	var size: Int
	var length: Int
	
	let boardSize = Globals.boardSize
	var tileSize: Int
	var type: String
	var map: [Int]	// keeps track of board
	
	var display = UIImageView(image: UIImage(named: "0_pets"))
	var board: [UIImageView]!
	// keeps track of gesture and its direction
	var tileGesture: TileGesture!
	var start = CGPoint(x: 0, y: 0)
	var end = CGPoint(x: 0, y: 0)
	
	var dir = -1			// current direction of moving tile
	var currentTile = -1	// starting tile index
	var shuffled: [Int]		// original shuffled board
	var isMoving = false	// if user started moving yet
	
	var moves = 0
	var timer = BoardTimer()
	
	var howToView: HowToView?
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	
	// initilize TileBoard with placeholdervalues
	override init(frame: CGRect) {
		// placeholder values
		self.image = UIImage(named: "0_pets")!
		self.size = 3
		self.length = 9
		self.tileSize = boardSize / 3
		self.type = "pets"
		self.map = Array(0...length - 1)
		self.shuffled = map
		super.init(frame: frame)
		
		display.frame = CGRect(x: 0, y: 0, width: Globals.boardSize, height: Globals.boardSize)
		howToView = HowToView(frame: display.frame)
		
		tileGesture = TileGesture(target: self, action: #selector(gesture(action:)))
		addGestureRecognizer(tileGesture)
		tileGesture.delegate = self
	}
	
	// set values
	func setValues(newImage: UIImage, newSize: Int, index: Int, type: String) {
		self.image = newImage
		self.index = index
		self.size = newSize
		self.length = newSize * newSize
		self.tileSize = boardSize / newSize
		self.type = type
		self.map = Array(0...length - 1)
		self.shuffled = map

		display.image = newImage
		// set how to image
		howToView!.setBoardSize(boardSize: size)
		
		board = createBoard()
		for i in board {
			self.addSubview(i)
		}
		addSubview(display)
		addSubview(howToView!)
	}
	
	/// start of gesture functions
	// gets start block for gesture
	func getStartingBlock() -> Int {
		for i in 0...length - 1 {
			if board[i].frame.contains(start) {
				return i
			}
		}
		return -1
	}
	
	// tile gesture
	@objc func gesture(action: TileGesture) {
		if action.state == .began {
			start = tileGesture.point
			currentTile = getStartingBlock()
		}
		if action.state == .ended {
			end = tileGesture.point
			dir = getDirection()
			move()
		}
	}
	/// end of gesture functions
	
	/// start of board creation
	// gets sub image for tile
	private func getSubImage(frame: CGRect) -> UIImage {
		let scale = (image.size.width / CGFloat(Globals.boardSize))	// image to view size
		let crop = CGRect(x: frame.minX * scale, y: frame.minY * scale, width: frame.width * scale, height: frame.height * scale)
		let temp = image.cgImage!.cropping(to: crop)	// crops image to frame
		return UIImage(cgImage: temp!, scale: scale, orientation: .up)
	}
	
	// creates tileImage based on param
	private func createTileImage(tile: UIImage, frame: CGRect, index: Int) -> UIImageView {
		let temp = CustomTile(frame: frame)
		temp.setImage(tile: getSubImage(frame: frame))
		if index == length - 1 {
			temp.image = nil	// create blank space
		}
		return temp
	}
	
	// gets frame of current tile
	private func getFrame(sub: UIImage, pos: Int) -> CGRect {
		let x = pos % size
		let y = pos / size
		return CGRect(x: x * tileSize, y: y * tileSize, width: tileSize, height: tileSize)
	}
	
	// creates tile board
	private func createBoard() -> [UIImageView] {
		var array = [UIImageView]()
		for i in 0...length - 1 {
			let frame = getFrame(sub: image, pos: i)
			array.append(createTileImage(tile: image, frame: frame, index: i))
		}
		return array
	}
	/// end of board creation
	
	// check if board is complete
	func checkFinished() -> Bool {
		// if already completed, return
		if TilesController.isCompleted {
			return true
		}
		let array = Array(0...length - 1)	// completed array
		if array == map {
			// puzzle is completed
			TilesController.isCompleted = true
			display.isHidden = false
			
			// marks that puzzle is completed, if not marked already
			if TilesController.completedImage.isHidden {
				TilesController.completedImage.animateShow()
			}
			
			timer.pauseTimer()	// stops timer
			isMoving = false
			display.animateShow()	// shows full image
			TilesController.coverView.animateShow()
			
			updateCoreData()	// updates puzzle data
			resetCurrentData()	// clears data for current puzzle
			return true
		}
		return false
	}
	
	// get direction: right = 0, left = 1, up = 2, down = 3
	func getDirection() -> Int {
		let x = Int(start.x - end.x)
		let y = Int(start.y - end.y)
		// check for insignificant difference
		let check = max(abs(x), abs(y)) - min(abs(x), abs(y))
		if check < 50 {
			return -1
		}
		let offset = Int(self.frame.width / 8)
		var direction = -1
		// check for significant x change
		if abs(x) > offset && abs(x) > abs(y) {
			direction = 1
			if x < 0 {
				direction = 0
			}
		}
		// check for significant y change
		if abs(y) > offset && abs(y) > abs(x) {
			direction = 2
			if y < 0 {
				direction = 3
			}
		}
		return direction
	}
	
	// checks if blank is in correct direction
	func correctDirection() -> Int {
		let blank = findBlank()
		// check horizontal
		if dir == 0 || dir == 1 {
			if blank / size == currentTile / size {
				if dir == 0 && currentTile < blank {
					return 1	// move right
				}
				if dir == 1 && currentTile > blank {
					return -1	// move left
				}
			}
		}
		// check vertical
		if dir == 2 || dir == 3 {
			if blank % size == currentTile % size {
				if dir == 2 && currentTile > blank {
					return -size
				}
				if dir == 3 && currentTile < blank {
					return size
				}
			}
		}
		return 0
	}
	
	// make move, uses currentTile and dir
	func move() {
		// check if puzzle is complete or display is visible
		if checkFinished() || !display.isHidden {
			return
		}
		// not trying to move
		if dir == -1 || currentTile == -1 {
			return
		}
		
		var blank = findBlank()
		// return if blank space
		if currentTile == blank {
			return
		}
		// make sure blank is in line of direction
		let correct = correctDirection()
		if correct == 0 {
			return
		}
		// move tiles until blank is in correct space
		while currentTile != blank {
			// check if first move
			if !isMoving {
				timer.startTimer()
				isMoving = true
			}
			// updates moves
			moves += 1
			TilesController.moveLabel.text = "Moves: \(moves)"
			// finds tile to swap, then swaps
			var swap = blank - correct
			swapTile(a: blank, b: swap)
			blank = findBlank()
			swap -= correct	// update blank position
			// checks if puzzle is complete, exits if so
			if checkFinished() {
				break
			} else {
				// only saves current data if not finished
				saveCurrentData()
			}
		}
	}
	
	// swap tile
	func swapTile(a: Int, b: Int) {
		let temp = board[a].image
		board[a].image = board[b].image
		board[b].image = temp

		map.swapAt(a, b)
	}
	
	// find index of blank space
	func findBlank() -> Int {
		for i in 0...length - 1 {
			if map[i] == length - 1 {
				return i
			}
		}
		return -1
	}
	
	// get index of number
	func getIndex(array: [Int], val: Int) -> Int {
		for i in (val + 1)...length - 1 {
			if array[i] == val {
				return i
			}
		}
		return -1
	}
	
	// changes tiles around to given board
	func changeBoard(array: [Int]) {
		for i in 0...length - 2 {
			var index = 0
			for j in 0...length - 1 {
				if array[i] == map[j] {
					index = j
					break
				}
			}
			swapTile(a: i, b: index)
		}
	}
	
	// reset board to original shuffle
	func resetBoard() {
		changeBoard(array: shuffled)
		isMoving = false
		moves = 0
		timer.resetTimer()
		TilesController.moveLabel.text = "Moves: \(moves)"
		dir = -1
		saveCurrentData()
	}
	
	// shuffles tile board
	func shuffleBoard() {
		moves = 0
		TilesController.moveLabel.text = "Moves: \(moves)"
		timer.resetTimer()
		
		shuffled = Array(0...length - 1).shuffled()
		while Solvable.isSolvable(board: shuffled, size: size) {
			shuffled = Array(0...length - 1).shuffled()
		}
		changeBoard(array: shuffled)
		saveCurrentData()
	}
	
	// uses user defaults to save data
	func saveCurrentData() {
		let defaults = UserDefaults.standard
		defaults.set(index, forKey: "index")
		defaults.set(type, forKey: "type")
		defaults.set(size, forKey: "size")
		defaults.set(shuffled, forKey: "shuffled")
		defaults.set(map, forKey: "current")
		defaults.set(moves, forKey: "moves")
	}
	
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
	
	// updates core data
	func updateCoreData() {
		// create pop up list
		let popUps = PopUpController()
		
		let dataIndex = size - 3
		var stats: [Stats?] = persistenceManager!.fetchStat()
		if stats.isEmpty {
			return
		}
		stats[0]!.total![dataIndex] += 1	// increments total puzzles
		// updates least moves if current moves is the least
		let oldMoves = stats[0]!.leastMoves![dataIndex]
		if moves < oldMoves || oldMoves == 0 && moves != 0 {
			stats[0]!.leastMoves![dataIndex] = moves
			popUps.personalBest(type: "Moves", value: TilesController.moveLabel.text!)
		}
		// updates best time if current time is the best
		let oldTime = stats[0]!.minTimes![dataIndex]
		if timer.counter < oldTime || oldTime == 0.0 && timer.counter != 0.0 {
			stats[0]!.minTimes![dataIndex] = timer.counter
			popUps.personalBest(type: "Time", value: timer.formatTime())
		}
		// updates completed puzzle
		if type == "custom" {
			let custom = persistenceManager!.fetchCustom()
			custom[index].completed![dataIndex] += 1
		} else {
			let catagoryNum = Globals.catagories.firstIndex(of: type)!
			stats[0]!.completed![catagoryNum][index][dataIndex] += 1
		}
		// saves data
		persistenceManager!.save()
		popUps.displayList(view: UIApplication.shared.keyWindow!.rootViewController!)
		showCompleteView()
	}
	
	// shows and updates complete view
	func showCompleteView() {
		if size == 6 {
			TilesController.completedNextDifficulty.isEnabled = false
			TilesController.completedNextDifficulty.alpha = 0.3
		} else {
			TilesController.completedNextDifficulty.isEnabled = true
			TilesController.completedNextDifficulty.alpha = 1.0
		}
		var maxNum = 0
		if type == "custom" {
			let custom = persistenceManager!.fetchCustom()
			maxNum = custom.count - 1
		} else {
			maxNum = Globals.numCatagories[Globals.catagories.firstIndex(of: type)!] - 1
		}
		if index == maxNum {
			TilesController.completedNextPuzzle.isEnabled = false
			TilesController.completedNextPuzzle.alpha = 0.3
		} else {
			TilesController.completedNextPuzzle.isEnabled = true
			TilesController.completedNextPuzzle.alpha = 1.0
		}
		TilesController.completedView.animateShow()
	}
	
	// initilizer to compile
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
