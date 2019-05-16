//
//  PersistenceManager.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/14/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import Foundation
import CoreData

final class PersistenceManager {
	
	static let shared = PersistenceManager()
	
	// create container for core data
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "CoreData")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	lazy var context = persistentContainer.viewContext
	
	// saving support for core data
	func save() {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	// STAT: load support for core data
	func fetchStat() -> [Stats] {
		let request: NSFetchRequest<Stats> = Stats.fetchRequest()
		do {
			return try context.fetch(request)
		} catch {
			print(error)
			return []
		}
		
	}
	
	// delete from core data
	func delete(_ object: NSManagedObject) {
		context.delete(object)
		save()
	}
}

//
extension Stats {
	func configure(total: [Int], leastMoves: [Int], minTimes: [Double], completed: [[[Int]]]) -> Self {
		self.total = total
		self.leastMoves = leastMoves
		self.minTimes = minTimes
		self.completed = completed
		
		return self
	}
}
