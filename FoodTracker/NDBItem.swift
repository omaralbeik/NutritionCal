//
//  NDBItem.swift
//  
//
//  Created by Omar Albeik on 18/11/15.
//
//

import Foundation
import CoreData


class NDBItem: NSManagedObject {

	@NSManaged var group: String?
	@NSManaged var name: String?
	@NSManaged var ndbNo: String?
	@NSManaged var dateAdded: NSDate?
	@NSManaged var saved: NSNumber
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("NDBItem", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		group = (dictionary["group"] as! String)
		name = (dictionary["name"] as! String)
		ndbNo = (dictionary["ndbno"] as! String)
		dateAdded = NSDate()
		saved = false
	}
	
}
