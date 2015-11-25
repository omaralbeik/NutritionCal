//
//  CallendarViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 22/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import HealthKit
import FSCalendar
import MaterialDesignColor

class CallendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
	
	@IBOutlet weak var todayBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var calendarContainerView: UIView!
	
	let healthStore = HealthStore.sharedInstance()
	
	private weak var calendar: FSCalendar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// UI customizations
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MaterialDesignColor.green500]
		
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		
		todayBarButtonItem.enabled = false
		
		let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 250))
		calendar.dataSource = self
		calendar.delegate = self
		calendarContainerView.addSubview(calendar)
		self.calendar = calendar
		
		calendar.headerTitleColor = UIColor.blackColor()
		calendar.todayColor = MaterialDesignColor.grey200
		calendar.titleTodayColor = MaterialDesignColor.green500
		calendar.selectionColor = MaterialDesignColor.green500
		calendar.weekdayTextColor = MaterialDesignColor.green500
		
		calendar.selectDate(calendar.today)
		
	}
	
	@IBAction func todayBarButtonItemTapped(sender: UIBarButtonItem) {
		calendar.selectDate(NSDate(), scrollToDate: true)
		todayBarButtonItem.enabled = false
	}
	
	
	@IBAction func addBarButtonItemTapped(sender: UIBarButtonItem) {
		tabBarController?.selectedIndex = 0
	}
	
	
	func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
		
		if date.isToday() {
			todayBarButtonItem.enabled = false
		} else {
			todayBarButtonItem.enabled = true
		}
		
		print(date)
	}
	
}
