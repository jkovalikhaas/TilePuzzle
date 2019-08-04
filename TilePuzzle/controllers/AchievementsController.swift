//
//  AchievementsController.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 6/5/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import UIKit

class AchievementsController: UITableViewController {
	
	let headerId = "headerId"
	let cellId = "cellId"
	
	let persistenceManager = (UIApplication.shared.delegate as? AppDelegate)!.container
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Stats & Achievements"
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		view.backgroundColor = HomeController.backgroundColor
	}
	
}
