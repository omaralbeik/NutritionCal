////
////  USDAItem.swift
////  
////
////  Created by Omar Albeik on 17/11/15.
////
////
//
//import Foundation
//import CoreData
//
//
//class USDAItem: NSManagedObject {
//
//	@NSManaged var name: String?
//	@NSManaged var idValue: String?
//	@NSManaged var dateAdded: NSDate?
//
//	
//	@NSManaged var calcium: NSNumber?
//	@NSManaged var carbohydrate: NSNumber?
//	@NSManaged var cholesterol: NSNumber?
//	@NSManaged var energy: NSNumber?
//	@NSManaged var fatTotal: NSNumber?
//	@NSManaged var protein: NSNumber?
//	@NSManaged var sugar: NSNumber?
//	@NSManaged var vitaminC: NSNumber?
//
//	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//		super.init(entity: entity, insertIntoManagedObjectContext: context)
//	}
//	
//	init (dictionary: [String : AnyObject], context: NSManagedObjectContext) {
//		
//		let entity = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: context)!
//		super.init(entity: entity, insertIntoManagedObjectContext: context)
//		
//		name = dictionary["name"] as? String
//		idValue = dictionary["idVlaue"] as? String
//		dateAdded = NSDate()
//		
//		
//		
//		calcium = dictionary["calcium"] as! Double
//		carbohydrate = dictionary[""] as! Double
//		
//		
//		
//		
//	}
//	
//	
////	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
////		
////		super.init(entity: entity, insertIntoManagedObjectContext: context)
////	}
////	
////	init(name: String, color: UIColor, dailyReminder: NSDate?, type: Bool, context: NSManagedObjectContext) {
////		
////		let entity = NSEntityDescription.entityForName("Habit", inManagedObjectContext: context)!
////		super.init(entity: entity, insertIntoManagedObjectContext: context)
////		
////		self.type = type
////		self.name = name
////		
////		self.dateAdded = NSDate()
////		
////		let colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
////		
////		self.colorData = colorData
////		self.dailyReminder = dailyReminder
////		
////	}
//	
//}
