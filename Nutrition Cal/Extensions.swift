//
//  Extensions.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import MaterialDesignColor

extension NSDate {
	
	func isToday() -> Bool {
		let cal = NSCalendar.currentCalendar()
		var components = cal.components([.Era, .Year, .Month, .Day], fromDate:NSDate())
		let today = cal.dateFromComponents(components)!
		
		components = cal.components([.Era, .Year, .Month, .Day], fromDate:self)
		let otherDate = cal.dateFromComponents(components)!
		
		if(today.isEqualToDate(otherDate)) {
			return true
		} else {
			return false
		}
	}
	
	func daysSince1970() -> Int {
		
		let dateIn1970 = NSDate(timeIntervalSince1970: NSTimeIntervalSince1970)
		
		let calendar = NSCalendar.currentCalendar()
		let components = calendar.components([.Day], fromDate: dateIn1970, toDate: self, options: [])
		
		return components.day
	}
	
}

extension CollectionType {
	func find(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
		return try indexOf(predicate).map({self[$0]})
	}
}

extension UIViewController {
	
	func presentMessage(title: String, message: String, action: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
		
		alert.view.tintColor = MaterialDesignColor.green500
		
		dispatch_async(dispatch_get_main_queue()) {
			self.presentViewController(alert, animated: true, completion: nil)
			alert.view.tintColor = MaterialDesignColor.green500
		}
	}
	
}
