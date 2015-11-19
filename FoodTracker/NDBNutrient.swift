//
//  NDBNutrient.swift
//  
//
//  Created by Omar Albeik on 19/11/15.
//
//

import Foundation
import CoreData


class NDBNutrient: NSManagedObject {

	@NSManaged var id: NSNumber?
	@NSManaged var name: String?
	@NSManaged var unit: String?
	@NSManaged var value: NSNumber?
	
	@NSManaged var measure: [NDBItemMeasure]
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("NDBNutrient", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		
	}
	
}
