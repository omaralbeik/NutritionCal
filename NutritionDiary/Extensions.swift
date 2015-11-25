//
//  Extensions.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 22/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit

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
	
}

extension CollectionType {
	func find(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
		return try indexOf(predicate).map({self[$0]})
	}
}