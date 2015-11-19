//
//  NDBItemMeasure.swift
//  
//
//  Created by Omar Albeik on 19/11/15.
//
//

import Foundation
import CoreData


class NDBItemMeasure: NSManagedObject {

	@NSManaged var label: String?
	@NSManaged var eqv: NSNumber?
	
	@NSManaged var item: NDBItem?
	@NSManaged var nutrients: [NDBNutrient]?
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("NDBItemMeasure", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		
	}
	
}
