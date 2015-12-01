//
//  NDBItem.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation
import CoreData


class NDBItem: NSManagedObject {
	
	@NSManaged var group: String?
	@NSManaged var name: String
	@NSManaged var ndbNo: String
	@NSManaged var saved: NSNumber
	@NSManaged var dateAdded: NSDate
	
	@NSManaged var nutrients: [NDBNutrient]?
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("NDBItem", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.group = (dictionary["group"] as! String)
		self.name = (dictionary["name"] as! String)
		self.ndbNo = (dictionary["ndbno"] as! String)
		self.saved = false
		self.dateAdded = NSDate()
	}
	
}
