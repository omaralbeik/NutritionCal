//
//  NDBMeasure.swift
//
//
//  Created by Omar Albeik on 23/11/15.
//
//

import Foundation
import CoreData


class NDBMeasure: NSManagedObject {
	
	@NSManaged var label: String?
	@NSManaged var eqv: NSNumber?
	@NSManaged var qty: NSNumber?
	@NSManaged var value: NSNumber?
	@NSManaged var nutrient: NDBNutrient
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(nutrient: NDBNutrient, dictionary: [String: AnyObject], context: NSManagedObjectContext) {
		
		let entity = NSEntityDescription.entityForName("NDBMeasure", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.label = (dictionary["label"] as! String)
		self.eqv = (dictionary["eqv"] as! Int)
		self.qty = (dictionary["qty"] as! Int)
		self.value = (dictionary["value"] as! Double)
		self.nutrient = nutrient
	}
}
