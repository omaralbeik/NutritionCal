//
//  DayEntry.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation
import CoreData


class DayEntry: NSManagedObject {
	
	@NSManaged var ndbItemId: String
	@NSManaged var ndbItemName: String
	@NSManaged var measureLabel: String
	@NSManaged var qty: NSNumber
	@NSManaged var date: NSDate
	@NSManaged var daysSince1970: NSNumber
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init (item: NDBItem, measure: NDBMeasure, qty: Int, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("DayEntry", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.ndbItemName = item.name!
		self.ndbItemId = item.name!
		self.measureLabel = measure.label!
		self.qty = qty
		self.date = NSDate()
		self.daysSince1970 = NSDate().daysSince1970()
	}
}
