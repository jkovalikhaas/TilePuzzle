//
//  TileClasses.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/3/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

// creates custom image tile (UIImageView)
class CustomTile: UIImageView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clear
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 1
		isUserInteractionEnabled = true
	}
	
	// set image
	func setImage(tile: UIImage) {
		image = tile
	}
	// required init
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// tile gesture
class TileGesture: UIPanGestureRecognizer {
	
	var point: CGPoint = CGPoint(x: 0, y: 0)
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesBegan(touches, with: event)
		guard let touch = touches.first, view != nil else {
			state = .failed
			return
		}
		point = touch.location(in: self.view)
		state = .began
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesEnded(touches, with: event)
		guard let touch = touches.first, view != nil else {
			state = .failed
			return
		}
		point = touch.location(in: self.view)
		state = .ended
	}
	
	override func reset() {
		super.reset()
		state = .possible
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesCancelled(touches, with: event)
		state = .cancelled
	}
	
}

// checks if board is solvable
class Solvable {
	// finds blank of board
	static func findBlank(board: [Int]) -> Int {
		for i in 0...board.count - 1 {
			if board[i] == board.count - 1 {
				return i
			}
		}
		return -1
	}
	
	// count inversions of board
	static func countInversions(board: [Int]) -> Int {
		var inversion = 0
		let blank = Solvable.findBlank(board: board)
		for i in 0...board.count - 2 {
			if i == blank {
				continue
			}
			for j in (i + 1)...board.count - 1 {
				if board[i] > board[j] {
					inversion += 1
				}
			}
		}
		return inversion
	}
	
	// check if solvable
	static func isSolvable(board: [Int], size: Int) -> Bool {
		let inversions = Solvable.countInversions(board: board) % 2 == 0
		if board.count % 2 != 0 {
			return !inversions
		} else {
			let pos = size + 1 - Solvable.findBlank(board: board) / size
			if pos % 2 == 0 {
				return !inversions
			} else {
				return inversions
			}
		}
	}
}

// timer class
class BoardTimer {
	
	var timer = Timer()
	var isPlaying = false
	var counter = 0.0
	
	func startTimer() {
		if isPlaying {
			return
		}
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
		isPlaying = true
	}
	
	func pauseTimer() {
		timer.invalidate()
		isPlaying = false
	}
	
	func resetTimer() {
		timer.invalidate()
		isPlaying = false
		counter = 0.0
		TilesController.timerLabel.text = formatTime()
		UserDefaults.standard.set(counter, forKey: "time")
	}
	
	@objc func updateTimer() {
		counter = counter + 0.1
		UserDefaults.standard.set(counter, forKey: "time")
		TilesController.timerLabel.text = formatTime()
	}
	
	func formatTime() -> String {
		let hours = Int(counter) / 3600
		let minutes = Int(counter) / 60 % 60
		let seconds = Int(counter) % 60
		return String(format: "Timer:  %02i:%02i:%02i", hours, minutes, seconds)
	}
}

// how to image view
class HowToView: UIImageView {
	
	let infoView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "how_to_info")
		return imageView
	}()
	
	let mapView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "how_to_3")
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		infoView.frame = frame
		isHidden = true
		
		let size = frame.size.width / 3 * 2
		let x = frame.size.width / 2 - size / 2
		let y = frame.size.height / 3
		mapView.frame = CGRect(x: x, y: y, width: size, height: size)
		
		addSubview(infoView)
		addSubview(mapView)
	}
	
	// sets image based on board size
	func setBoardSize(boardSize: Int) {
		mapView.image = UIImage(named: "how_to_\(boardSize)")
	}
	
	// sets view to hidden/shown
	func setHidden() {
		if isHidden {
			isHidden = false
		} else {
			isHidden = true
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
