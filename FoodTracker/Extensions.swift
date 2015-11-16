//
//  Extensions.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
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