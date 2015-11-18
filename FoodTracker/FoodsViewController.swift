//
//  FoodsViewController.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import MaterialDesignColor
import NVActivityIndicatorView
import BGTableViewRowActionWithImage

class FoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating  {
	
	// button titles for search controller
	var scopeButtonTitles = ["Saved", "Search Results"]
	
	// loading indicator for search controller
	var loadingIndicator: NVActivityIndicatorView!
	
	// shared tableView
	@IBOutlet weak var tableView: UITableView!
	
	var searchController: UISearchController!
	
	//MARK: - View Life Cycles
	
	// viewWillAppear
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		do {
			try foodsFetchedResultsController.performFetch()
		} catch {
			print("Error fetching foods in viewWillAppear")
		}
		
		tableView.reloadData()
	}
	
	// viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		
		do {
			try foodsFetchedResultsController.performFetch()
		} catch {
			print("Error fetching foods in viewDidLoad")
		}
		
		tableView.reloadData()
		
		tableView.delegate = self
		tableView.dataSource = self
		foodsFetchedResultsController.delegate = self
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.frame)-15, y: 115, width: 30, height: 30)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		// UI customizations
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MaterialDesignColor.green500]
		
		searchController = UISearchController(searchResultsController: nil)
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.sizeToFit()
		searchController.searchBar.scopeButtonTitles = scopeButtonTitles
		
		// UI customizations
		searchController.searchBar.tintColor = MaterialDesignColor.green500
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = MaterialDesignColor.green500
		searchController.searchBar.barTintColor = MaterialDesignColor.grey200
		
		tableView.tableHeaderView = self.searchController.searchBar
		searchController.searchBar.delegate = self
		self.definesPresentationContext = true
		
		searchController.view.addSubview(loadingIndicator)
	}
	
	
	// MARK: - Core Data Convenience
	
	// Shared Context from CoreDataStackManager
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	// foodsFetchedResultsController
	lazy var foodsFetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "NDBItem")
		
		fetchRequest.predicate = NSPredicate(format: "saved == %@", true)
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	// MARK: - fetchedResultsController delegate
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
	}
	
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		
		switch type {
		case .Insert:
			tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
			
		case .Delete:
			tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
			
		default:
			return
		}
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
				let food = foodsFetchedResultsController.objectAtIndexPath(indexPath!) as! NDBItem
				cell.textLabel?.text = food.name
				
			case .Move:
				tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
				tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
			}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
	}
	
	
	//MARK: - UITableViewDataSource
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("foodTableViewCell")! as UITableViewCell
		
		
		if searchController.active {
			
			let foods = foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			cell.textLabel?.text = foods[indexPath.row].name
			return cell
			
		}
		
		let foods = foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		cell.textLabel?.text = foods[indexPath.row].name
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.active {
			
			let sectionInfo = foodsFetchedResultsController.sections![section]
			return sectionInfo.numberOfObjects
		}
		
		let sectionInfo = foodsFetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		let eatAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "  Eat ", backgroundColor: MaterialDesignColor.green500, image: UIImage(named: "eatActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
			print("should eat")
			tableView.setEditing(false, animated: true)
		})
		
		let saveAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: " Save ", backgroundColor: MaterialDesignColor.blueGrey900, image: UIImage(named: "saveActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
			
			let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			let food = foods[indexPath.row]
			
			self.sharedContext.performBlock({ () -> Void in
				food.saved = true
				
				do {
					try self.sharedContext.save()
				}
				catch {
					print("Error saving context after saving an item")
				}
				
				print("\(food.name!) saved successfully")
			})
			
			tableView.setEditing(false, animated: true)
		})
		
		let deleteAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "Delete", backgroundColor: MaterialDesignColor.red500, image: UIImage(named: "deleteActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
			
			let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			let food = foods[indexPath.row]
			
			let alert = UIAlertController(title: "Delete", message: "Delete \(food.name!)", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				
				self.sharedContext.performBlock({ () -> Void in
					
					
					self.sharedContext.deleteObject(food)
					
					do {
						try self.sharedContext.save()
					}
					catch {
						print("Error saving context after deleting an item")
					}
					
				})
				
			})
			
			let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
			
			alert.addAction(deleteAction)
			alert.addAction(cancelAction)
			
			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(alert, animated: true, completion: nil)
			}
			
			tableView.setEditing(false, animated: true)
		})
		
		if searchController.active {
			return [eatAction, saveAction]
			
		}
		
		return [eatAction, deleteAction]
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		dismissKeyboard()
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		
		let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		
		for food in foods {
			if !(food.saved == true) {
				
				sharedContext.performBlock({ () -> Void in
					self.sharedContext.deleteObject(food)
					
					do {
						try self.sharedContext.save()
					}
					catch {
						print("Error saving context after deleting an item")
					}
				})
				
			}
		}
		
		foodsFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "saved != %@", true)
		
		do {
			try foodsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching food in searchController")
		}
		
		searchController.searchBar.selectedScopeButtonIndex = 1
		
		hideTableView(true)
		
		let searchString = self.searchController.searchBar.text
		
		NDB.requestNDBItemsFromString(searchString!, type: NDBSearchType.ByRelevance) { (success, items, error) -> Void in
			if success {
				print(items!.count)
				
				let ndbItems = items! as! [[String : AnyObject]]
				
				for item in ndbItems {
					
					self.sharedContext.performBlock({ () -> Void in
						_ = NDBItem(dictionary: item, context: self.sharedContext)
						
						do {
							try self.sharedContext.save()
						}
						catch {
							print("Error saving context after search")
						}
					})
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					self.hideTableView(false)
				}
				
			}
			else {
				print(error)
				
				dispatch_async(dispatch_get_main_queue()) {
					self.hideTableView(false)
					self.presentMessage("Oops!", message: error!, action: "OK")
				}
			}
		}
	}
	
	
	//MARK: - UISearchResultsUpdating
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		tableView.reloadData()
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		
		foodsFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "saved == %@", true)
		
		do {
			try foodsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching foods in willDismissSearchController")
		}
		
		let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		
		for food in foods {
			if !(food.saved == true) {
				
				sharedContext.performBlock({ () -> Void in
					self.sharedContext.deleteObject(food)
					
					do {
						try self.sharedContext.save()
					}
					catch {
						print("Error saving context after deleting an item")
					}
				})
				
			}
		}
	}
	
	@IBAction func addBarButtonItemTapped(sender: UIBarButtonItem) {
		self.searchController.searchBar.becomeFirstResponder()
		
	}
	
	func dismissKeyboard() {
		
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		
		if textFieldInsideSearchBar?.isFirstResponder() == true {
			textFieldInsideSearchBar?.resignFirstResponder()
		}
	}
	
	
	//MARK: - Helpers
	
	//hideTableView
	func hideTableView(hide: Bool) {
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			if hide {
				self.tableView.alpha = 0.1
				
				if self.searchController.searchBar.text != "" {
					self.loadingIndicator.startAnimation()
				}
			}
			else {
				self.tableView.alpha = 1
				self.loadingIndicator.stopAnimation()
			}
			self.tableView.reloadData()
		})
	}
	
	//Present a message helper method:
	func presentMessage(title: String, message: String, action: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
}
