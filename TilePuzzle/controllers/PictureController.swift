//
//  PictureController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/6/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class PictureController: UICollectionViewController {
	
	let numImages = Globals.numImages
	var scrollView: UIScrollView!
	let size = (Globals.width - Globals.leftAlign * 2) / 4
	
	var difficultyButtons: [UIButton] = []
	var imageButtons: [UIButton] = []
	
	var difficulty = 3
	var image = 0
	var difficultySelected = false
	var imageSelected = false
	
	var type = Globals.catagories[0]
	var total = Globals.numCatagories[0]
	
	let difficultyLabel: UILabel = {
		let label = UILabel()
		label.text = "Difficulty:"
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		
		let y = Globals.topAlign / 2 - Globals.smallTop / 2
		label.frame = CGRect(x: Globals.leftAlign * 2, y: y, width: Globals.xCenter / 2, height: Globals.smallTop)
		
		return label
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Image Picker"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		collectionView.backgroundColor = .white
		
		// scroll view
		scrollView = UIScrollView(frame: view.bounds)
		scrollView.bounces = true
		
		let yOffset = (total / 3 * (size + size / 2)) - Globals.height / 2
		scrollView.contentSize = CGSize(width: Globals.width, height: Globals.height + yOffset)
		
		imageButtons = generateButtons()
		
		let difficultyView = topView()
		
		collectionView.addSubview(scrollView)
		collectionView.addSubview(difficultyView)
	}
	
	// creates top view (for difficulty)
	func topView() -> UIView {
		let topView = UIView()
		
		topView.backgroundColor = .white
		topView.frame = CGRect(x: 0, y: 0, width: Globals.width, height: Globals.topAlign)
		
		difficultyButtons = createDifficultyButtons()
		for i in difficultyButtons {
			topView.addSubview(i)
		}
		
		topView.addSubview(difficultyLabel)
		
		return topView
	}
	
	// creates choose difficulty buttons
	func createDifficultyButtons() -> [UIButton] {
		var buttons: [UIButton] = []
		
		for i in 3...6 {
			let button = UIButton()
			
			button.layer.borderColor = UIColor.black.cgColor
			button.layer.borderWidth = 1.0
			button.layer.cornerRadius = 10
			button.showsTouchWhenHighlighted = true
			
			button.setTitle("\(i)", for: .normal)
			button.titleLabel?.text = "\(i)"
			button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			button.setTitleColor(.black, for: .normal)
			
			let size = Globals.leftAlign
			let x = Globals.xCenter + (size + size / 2) * (i - 3)
			let y = Globals.topAlign / 2 - size / 2
			button.frame = CGRect(x: x, y: y, width: size, height: size)
			
			button.addTarget(self, action: #selector(selectDifficulty(_:)), for: .touchUpInside)
			buttons.append(button)
		}
		
		return buttons
	}
	
	// create button from image
	func generateButtons() -> [UIButton] {
		var buttons: [UIButton] = []
		
		for i in 0...total {
			let button = UIButton()
			
			button.backgroundColor = .black
			button.layer.cornerRadius = 10
			button.layer.borderColor = UIColor.black.cgColor
			button.showsTouchWhenHighlighted = true
			
			if i == 0 {
				button.setTitle("?", for: .normal)
				button.titleLabel?.text = "?"
				button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			} else {
				button.setTitle("\(i - 1)", for: .normal)
				button.titleLabel?.text = "\(i - 1)"
				button.setImage(UIImage(named: "\(i - 1)_\(type)"), for: .normal)
			}
			
			let x = Globals.leftAlign + (size + size / 2) * (i % 3)
			let y = Globals.topAlign + (size + size / 2) * (i / 3)
			button.frame = CGRect(x: x, y: y, width: size, height: size)
			button.clipsToBounds = true
			
			button.addTarget(self, action: #selector(selectImage(_:)), for: .touchUpInside)
			
			scrollView.addSubview(button)
			buttons.append(button)
		}
		
		return buttons
	}
	
	// selects difficulty
	@objc func selectDifficulty(_ sender: UIButton) {
		difficulty = Int((sender.titleLabel?.text)!)!
		difficultySelected = true
		
		for i in difficultyButtons {
			if i == sender {
				if i.backgroundColor == .black {
					i.backgroundColor = .white
					i.setTitleColor(.black, for: .normal)
					difficultySelected = false
				} else {
					i.backgroundColor = .black
					i.setTitleColor(.white, for: .normal)
				}
			} else {
				i.backgroundColor = .white
				i.setTitleColor(.black, for: .normal)
			}
		}
		
		if imageSelected {
			pushTile()
		}
	}
	
	// go to tile controller with image
	@objc func selectImage(_ sender: UIButton) {
		let n = sender.titleLabel?.text
		if n == "?" {
			image = Array(0...total - 1).randomElement()!
		} else {
			image = Int(n!)!
		}
		imageSelected = true
		
		for i in imageButtons {
			if i == sender {
				if i.layer.borderWidth == 4.0 {
					i.layer.borderWidth = 0.0
					imageSelected = false
				} else {
					i.layer.borderWidth = 4.0
				}
			} else {
				i.layer.borderWidth = 0.0
			}
		}
		
		if difficultySelected {
			pushTile()
		}
	}
	
	// goes to tile controller
	func pushTile() {
		// clear selections
		imageSelected = false
		difficultySelected = false
		
		for i in imageButtons {
			i.layer.borderWidth = 0.0
		}
		for i in difficultyButtons {
			i.backgroundColor = .white
			i.setTitleColor(.black, for: .normal)
		}
		
		let controller = TilesController(collectionViewLayout: UICollectionViewFlowLayout())
		controller.setDisplay(i: image, difficulty: difficulty, type: type)
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// sets type and total of type
	func setTypeValues(val: String, num: Int) {
		type = val
		total = num
	}
}