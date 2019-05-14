//
//  BoardSolver.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/6/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import Foundation

class Tile {
	
	var board: [Int]
	var cost: Int		// cost to goal
	var dir: Int
	var level: Int		// distance from root
	var parent: Tile?	// tile's parent
	
	init(board: [Int], cost: Int, dir: Int, level: Int, parent: Tile? = nil) {
		self.board = board
		self.cost = cost
		self.dir = dir
		self.level = level
		self.parent = parent
	}
}

// uses a* to find solution to tile puzzle
class BoardSolver {
	
	let size: Int
	let length: Int
	let goal: [Int]
	let start: Tile?
	
	init(board: [Int], size: Int) {
		self.size = size
		self.length = size * size
		self.goal = Array(0...length - 1)
		
		self.start = Tile(board: board, cost: -1, dir: -1, level: 0, parent: nil)
	}
	
	// finds index of blank space
	func findBlank(board: [Int]) -> Int {
		for i in 0...length - 1 {
			if board[i] == length - 1 {
				return i
			}
		}
		return -1
	}
	
	// gets manhattan distance for board
	func manhattan(board: [Int]) -> Int {
		var distance = 0
		for i in 0...length - 1 {
			if i != findBlank(board: board) {
				let dx = abs(board[i] % size - goal[i] % size)
				let dy = abs(board[i] / size - goal[i] / size)
				distance += dx + dy
			}
		}
		return distance
	}
	
	// check in bounds
	func inBounds(tile: Int) -> Bool {
		return tile >= 0 && tile < length
	}
	
	// swaps tile with blank in a board
	func swapTile(board: [Int], index: Int) -> [Int] {
		// check if tile is in bounds
		if !inBounds(tile: index) {
			return []
		}
		var temp = board
		let blank = findBlank(board: board)
		temp.swapAt(blank, index)
		return temp
	}
	
	// gets move for blank
	func getMove(board: [Int], dir: Int) -> Int {
		let direction = [1, -1, -size, size]
		return direction[dir]
	}
	
	// opposite direction
	func getOpposite(dir: Int) -> Int {
		if dir < 0 || dir > 3 {
			return -1
		}
		let opposite = [1, 0, 3 , 2]
		return opposite[dir]
	}
	
	// add to seen and sort by cost
	func addSeen(queue: [Tile], element: Tile) -> [Tile] {
		var temp = queue
		// if empty, append to end
		if queue.isEmpty || element.cost > queue.last!.cost {
			temp.append(element)
			return temp
		}
		var index = -1
		// find next largest element in queue
		for i in 0...queue.count - 1 {
			if queue[i].cost > element.cost {
				index = i
				break
			}
		}
		// if not found append, otherwise insert at index
		if index < 0 {
			temp.append(element)
		} else {
			temp.insert(element, at: index)
		}
		return temp
	}
	
	// solves board
	func solve() -> [Int] {
		start!.cost = manhattan(board: start!.board)
		var queue: [Tile] = [start!]
		var seen: [[Int]] = [start!.board]
		
		while !queue.isEmpty {
			let current = queue.removeFirst()
			seen.append(current.board)
			// solution found
			if current.cost == 0 {
				return getSolution(tile: current)
			}
			// look at possible moves
			for i in 0...3 {
				// skips opposite direction
				if current.dir == getOpposite(dir: i) {
					continue
				}
				// gets movement of direction then checks if move is valid
				let move = getMove(board: current.board, dir: i)
				if move == 0 {
					continue
				}
				// gets index to swap with blank
				let index = findBlank(board: current.board) - move
				// gets new board after swap, skips if invalid
				let temp = swapTile(board: current.board, index: index)
				if temp.isEmpty || seen.contains(temp){
					continue
				}
				
				let cost = manhattan(board: temp)
				let newTile = Tile(board: temp, cost: cost, dir: i,
								   level: current.level + 1, parent: current)
				queue = addSeen(queue: queue, element: newTile)
			}
		}
		return []
	}
	
	// gets list of directions from solution
	func getSolution(tile: Tile) -> [Int] {
		var list: [Int] = []
		var current = tile
		while current.board != start!.board {
			list.append(getOpposite(dir: current.dir))
			current = current.parent!
		}
		return list.reversed()
	}
}
