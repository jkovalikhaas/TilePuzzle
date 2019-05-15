//
//  CatagoryController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/13/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class CatagoryController: UITableViewController {
	
	let cellId = "cellId"
	let titles = Globals.catagoryTitles
	static let rowHeight: CGFloat = CGFloat(Globals.height / 12)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Catagories"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Random", style: .plain, target: self, action: #selector(randomPuzzle(_:)))
		
		// seperator goes edge to edge
		tableView.layoutMargins = UIEdgeInsets.zero
		tableView.separatorInset = UIEdgeInsets.zero
		
		tableView.register(CatagoryCell.self, forCellReuseIdentifier: cellId)
		
		tableView.tableFooterView = UIView()
	}
	
	// num rows
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return titles.count
	}

	// create tableview cells from titles
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
			as! CatagoryCell
		let name = "\(titles[indexPath.row])"
		cell.catagoryLabel.text = name
		cell.totalLabel.text = "\(Globals.numCatagories[indexPath.row])"
		return cell
	}
	
	// selects row
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		pushPictures(index: indexPath.row)
	}
	
	// sets height of row
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CatagoryController.rowHeight
	}
	
	// gets random puzzle
	@objc func randomPuzzle(_ sender: UIBarButtonItem) {
		let randomNum: Int = (0...Globals.numImages - 1).randomElement()!
		let randomCatagory = randomNum % Globals.numCatagories.count
		pushPictures(index: randomCatagory)
	}
	
	// pushes to PictureController
	func pushPictures(index: Int) {
		let controller = PictureController(collectionViewLayout: UICollectionViewFlowLayout())
		controller.setTypeValues(val: Globals.catagories[index], num: Globals.numCatagories[index])
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// dispose of any resources that can be recreated.
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

// catagory cell
class CatagoryCell: UITableViewCell {
	
	static let height = Globals.width / 16
	static let labelY = Int(CatagoryController.rowHeight / 2) - CatagoryCell.height / 2
	
	let catagoryLabel: UILabel = {
		let label = UILabel()
		label.text = "Hello There"
		label.font = UIFont.boldSystemFont(ofSize: Globals.font)
		label.numberOfLines = 0
		
		label.frame = CGRect(x: Globals.leftAlign, y: CatagoryCell.labelY, width: Globals.xCenter, height: CatagoryCell.height)
		return label
	}()
	
	let totalLabel: UILabel = {
		let label = UILabel()
		label.text = "0"
		label.font = UIFont.boldSystemFont(ofSize: Globals.font)
		label.numberOfLines = 0
		
		label.textAlignment = .center
		label.frame = CGRect(x: Globals.xCenter, y: CatagoryCell.labelY, width: Globals.xCenter, height: CatagoryCell.height)
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		addSubview(catagoryLabel)
		addSubview(totalLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}