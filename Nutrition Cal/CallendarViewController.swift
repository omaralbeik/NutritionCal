//
//  CallendarViewController.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import FSCalendar
import MaterialDesignColor
import BGTableViewRowActionWithImage

class CallendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
	
	@IBOutlet weak var todayBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var calendarContainerView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noItemsLabel: UILabel!
	
	
	let healthStore = HealthStore.sharedInstance()
	var allDaysEntries: [DayEntry] = []
	
	private weak var calendar: FSCalendar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		do {
			try daysFetchedResultsController.performFetch()
		} catch {
			print("error fetching all days")
		}
		
		fetchAllDays()
		
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
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchAllDays()
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
		
		if daysFetchedResultsController.fetchedObjects?.count == 0 {
			tableView.hidden = true
			noItemsLabel.hidden = false
		} else {
			tableView.hidden = false
			noItemsLabel.hidden = true
		}
		
		return daysFetchedResultsController.fetchedObjects!.count
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		let days = daysFetchedResultsController.fetchedObjects as! [DayEntry]
		
		let deleteAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "    ", backgroundColor: MaterialDesignColor.red500, image: UIImage(named: "deleteDayEntryActionIcon"), forCellHeight: 70, handler: { (action, indexPath) -> Void in
			
			
			let alert = UIAlertController(title: "Delete", message: "Delete (\(days[indexPath.row].ndbItemName)) ?", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				
				dispatch_async(dispatch_get_main_queue()) {
					self.sharedContext.deleteObject(days[indexPath.row])
					CoreDataStackManager.sharedInstance().saveContext()
					self.calendar?.reloadData()
				}
				
				tableView.setEditing(false, animated: true)
			})
			
			let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				
				self.tableView.setEditing(false, animated: true)
			})
			
			alert.addAction(deleteAlertAction)
			alert.addAction(cancelAlertAction)
			
			alert.view.tintColor = MaterialDesignColor.green500
			
			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(alert, animated: true, completion: nil)
				alert.view.tintColor = MaterialDesignColor.green500
			}
			
		})
		return [deleteAction]
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
		
		for dayEntry in allDaysEntries {
			if dayEntry.daysSince1970 == date.daysSince1970() {
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
	func fetchAllDays() {
		let fetchRequest = NSFetchRequest(entityName: "DayEntry")
		
		do {
			
			allDaysEntries = try self.sharedContext.executeFetchRequest(fetchRequest) as! [DayEntry]
			
		} catch {
			print("Error fetching all days entries")
		}
		
		self.calendar?.reloadData()
		
	}
	
	
	func fetchDays() {
		
		fetchAllDays()
		
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
