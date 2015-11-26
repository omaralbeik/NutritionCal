//
//  NDBNutrient.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation
import CoreData


class NDBNutrient: NSManagedObject {
	
	@NSManaged var id: NSNumber?
	@NSManaged var name: String?
	@NSManaged var unit: String?
	@NSManaged var value: NSNumber?
	
	@NSManaged var item: NDBItem
	@NSManaged var measures: [NDBMeasure]?
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(item: NDBItem, dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("NDBNutrient", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.id = (dictionary["nutrient_id"] as! Int)
		self.name = (dictionary["name"] as! String)
		self.unit = (dictionary["unit"] as! String)
		self.value = (dictionary["value"] as! Double)
		self.item = item
	}
	
}
