//
//  CallendarViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 22/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import FSCalendar
import MaterialDesignColor

class CallendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
	
	@IBOutlet weak var todayBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var calendarContainerView: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	let healthStore = HealthStore.sharedInstance()
	
	private weak var calendar: FSCalendar!
	
	var allDays: [DayEntry] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		do {
			try daysFetchedResultsController.performFetch()
		} catch {
			print("error fetching all days")
		}
		
		self.allDays = daysFetchedResultsController.fetchedObjects! as! [DayEntry]
		
		tableView.delegate = self
		tableView.dataSource = self
		daysFetchedResultsController.delegate = self
		
		print(daysFetchedResultsController.fetchedObjects?.count)
		
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
	
	
	// MARK: - Core Data Convenience
	// Shared Context from CoreDataStackManager
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	// daysFetchedResultsController
	lazy var daysFetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "DayEntry")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	// MARK: - UITableView delegate & data sourse
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("historyTableViewCell")!
		
		let days = daysFetchedResultsController.fetchedObjects as! [DayEntry]
		
		cell.textLabel?.text = days[indexPath.row].ndbItemName
		cell.detailTextLabel?.text = "\(days[indexPath.row].qty) \(days[indexPath.row].measureLabel)"
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return daysFetchedResultsController.fetchedObjects!.count
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		let days = daysFetchedResultsController.fetchedObjects as! [DayEntry]
		
		let alert = UIAlertController(title: "Delete", message: "Delete (\(days[indexPath.row].ndbItemName)) ?", preferredStyle: UIAlertControllerStyle.Alert)
		
		let deleteAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
			
			self.sharedContext.performBlock({
				
				self.sharedContext.deleteObject(days[indexPath.row])
				
				do {
					try self.sharedContext.save()
				} catch {
					print("Error saving context after deleting dayEntry")
				}
				
			})
			
			tableView.setEditing(false, animated: true)
		})
		
		let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
			self.tableView.setEditing(false, animated: true)
		})
		
		alert.addAction(deleteAlertAction)
		alert.addAction(cancelAlertAction)

		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	
	// MARK: - daysFetchedResultsController delegate
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
		forChangeType type: NSFetchedResultsChangeType,
		newIndexPath: NSIndexPath?) {
			switch type {
			case .Insert:
				tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
				
			case .Delete:
				tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
				
			case .Update:
				let cell = tableView.cellForRowAtIndexPath(indexPath!)! as UITableViewCell
				let day = daysFetchedResultsController.objectAtIndexPath(indexPath!) as! DayEntry
				cell.textLabel?.text = day.ndbItemName
				cell.detailTextLabel?.text = "\(day.qty) \(day.measureLabel)"
				
			case .Move:
				tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
				tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
			}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
	}
	
	
	func calendar(calendar: FSCalendar!, imageForDate date: NSDate!) -> UIImage! {
		
		for day in allDays {
			
			if day.daysSince1970 == date.daysSince1970() {
				return UIImage(named: "dayLine")
			}
		}
		return UIImage()
	}
	
	
	// MARK: - FSCalendarDelegate
	func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
		
		if date.isToday() {
			todayBarButtonItem.enabled = false
		} else {
			todayBarButtonItem.enabled = true
		}
		
		getDayEntriesForDate(date)
	}
	
	
	// MARK: - IBActions
	@IBAction func todayBarButtonItemTapped(sender: UIBarButtonItem) {
		calendar.selectDate(NSDate(), scrollToDate: true)
		todayBarButtonItem.enabled = false
		getDayEntriesForDate(NSDate())
	}
	
	
	@IBAction func addBarButtonItemTapped(sender: UIBarButtonItem) {
		tabBarController?.selectedIndex = 0
	}
	
	
	// CoreData Helpers
	func fetchDays() {
		
		do {
			try daysFetchedResultsController.performFetch()
		} catch {
			print("Error fetching days")
		}
		
	}
	
	func getDayEntriesForDate(date: NSDate) {
		
		let daysSince1970 = date.daysSince1970() as NSNumber
		
		daysFetchedResultsController.fetchRequest.predicate = NSPredicate(format:"daysSince1970 ==  %@", daysSince1970)
		fetchDays()
		tableView.reloadData()
		
	}
	
	
	
}
