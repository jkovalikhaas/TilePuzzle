//
//  PersistantManager.swift
//  TilePuzzle
//
//  Created by Joe Kovalik-Haas on 5/14/19.
//  Copyright © 2019 Joe. All rights reserved.
//

import Foundation

import Foundation
import CoreData

final class PersistenceManager {
	
	private init() {}
	static let shared = PersistenceManager()
	
	// creates core data container
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Learning_Core_Data")
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
				print("saved successfully")
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	// load support for core data
	func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
		let entityName = String(describing: objectType)
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		
		do {
			let fetchedObjects = try context.fetch(fetchRequest) as? [T]
			return fetchedObjects ?? [T]()
		} catch {
			print(error)
			return [T]()
		}
		
	}
	
	// deletes core data
	func delete(_ object: NSManagedObject) {
		context.delete(object)
		save()
	}
}
