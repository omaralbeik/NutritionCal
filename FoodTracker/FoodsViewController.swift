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

class FoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	// shared tableView
	@IBOutlet weak var tableView: UITableView!
	
	var searchController: UISearchController!
	
	//MARK: - View Life Cycles
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if searchController.active {
			if searchController.searchBar.selectedScopeButtonIndex == 0 {
				fetchFoods(showSavedFoods: true)
			}
			else {
				fetchFoods(showSavedFoods: false)
			}
		}
		else {
			fetchFoods(showSavedFoods: true)
		}
	}
	
	// viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchFoods(showSavedFoods: true)
		
		tableView.delegate = self
		tableView.dataSource = self
		foodsFetchedResultsController.delegate = self
		
		// UI customizations
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MaterialDesignColor.green500]
		
		// set the search controller
		searchController = UISearchController(searchResultsController: nil)
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.sizeToFit()
		
		// button titles for search controller
		searchController.searchBar.scopeButtonTitles = ["Saved", "Search Results"]
		
		// UI customizations
		searchController.searchBar.tintColor = MaterialDesignColor.green500
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = MaterialDesignColor.green500
		
		searchController.searchBar.barTintColor = MaterialDesignColor.grey200
		
		tableView.tableHeaderView = self.searchController.searchBar
		searchController.searchBar.delegate = self
		self.definesPresentationContext = true
		
	}
	
	
	// MARK: - Core Data Convenience
	
	// Shared Context from CoreDataStackManager
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	// foodsFetchedResultsController
	lazy var foodsFetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "NDBItem")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	
	// MARK: - fetchedResultsController delegate
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
				let food = foodsFetchedResultsController.objectAtIndexPath(indexPath!) as! NDBItem
				cell.textLabel?.text = food.name
				cell.detailTextLabel?.text = food.ndbNo
				
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
		
		let foods = foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		cell.textLabel?.text = foods[indexPath.row].name
		cell.detailTextLabel?.text = foods[indexPath.row].ndbNo
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		let sectionInfo = foodsFetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		let eatAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "  Eat ", backgroundColor: MaterialDesignColor.green500, image: UIImage(named: "eatActionIcon"), forCellHeight: 95, handler: { (action, indexPath) -> Void in
			
			let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			let food = foods[indexPath.row]
			
			self.eatFood(food)
			
			tableView.setEditing(false, animated: true)
		})
		
		let saveAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: " Save ", backgroundColor: MaterialDesignColor.blueGrey900, image: UIImage(named: "saveActionIcon"), forCellHeight: 95, handler: { (action, indexPath) -> Void in
			
			let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			let food = foods[indexPath.row]
			
			self.sharedContext.performBlock({ () -> Void in
				food.saved = true
				self.saveContext()
				self.presentConfirmation(true)
			})
			
			tableView.setEditing(false, animated: true)
		})
		
		let deleteAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "Delete", backgroundColor: MaterialDesignColor.red500, image: UIImage(named: "deleteActionIcon"), forCellHeight: 95, handler: { (action, indexPath) -> Void in
			
			let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			let food = foods[indexPath.row]
			
			let alert = UIAlertController(title: "Delete", message: "Delete \(food.name!)", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				
				self.sharedContext.performBlock({ () -> Void in
					self.sharedContext.deleteObject(food)
					self.saveContext()
					self.presentConfirmation(false)
				})
				tableView.setEditing(false, animated: true)
			})
			
			let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				
				dispatch_async(dispatch_get_main_queue()) {
					self.tableView.setEditing(false, animated: true)
				}
			})
			
			alert.addAction(cancelAction)
			alert.addAction(deleteAction)
			
			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(alert, animated: true, completion: nil)
			}
		})
		
		return searchController.active ? (searchController.searchBar.selectedScopeButtonIndex == 1 ? [eatAction, saveAction] : [eatAction, deleteAction]) : [eatAction, deleteAction]
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		dismissKeyboard()
		performSegueWithIdentifier("toFoodDetailsVCSegue", sender: self)
	}
	
	
	//MARK: prepareForSegue method
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "toFoodDetailsVCSegue" {
			
			let foodDeatailsVC = segue.destinationViewController as! FoodDetailsViewController
			
			let indexPath = tableView.indexPathForSelectedRow
			let foodName = tableView.cellForRowAtIndexPath(indexPath!)!.textLabel!.text
			let foodNDBNo = tableView.cellForRowAtIndexPath(indexPath!)!.detailTextLabel!.text
			
			foodDeatailsVC.foodName = foodName
			foodDeatailsVC.foodNDBNo = foodNDBNo
		}
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		
		fetchFoods(showSavedFoods: false)
		
		searchController.searchBar.selectedScopeButtonIndex = 1
		
		let searchString = self.searchController.searchBar.text
		
		if searchString?.characters.count > 0 {
			
			tableViewLoading(true)
			
			NDB.requestNDBItemsFromString(searchString!, type: NDBSearchType.ByRelevance) { (success, items, error) -> Void in
				
				dispatch_async(dispatch_get_main_queue()) {
					self.tableViewLoading(false)
				}
				
				if success {
					let ndbItems = items! as! [[String : AnyObject]]
					for item in ndbItems {
						self.sharedContext.performBlock({ () -> Void in
							_ = NDBItem(dictionary: item, context: self.sharedContext)
						})
					}
				}
				else {
					print(error)
					
					dispatch_async(dispatch_get_main_queue()) {
						self.presentMessage("Oops!", message: error!, action: "OK")
					}
				}
			}
		}
	}
	
	
	//MARK: eatFood method
	func eatFood(food: NDBItem) {
		
		NDB.NDBReportForItem(food.ndbNo!, type: NDBReportType.Stats) { (success, result, error) -> Void in
			
			if success {
				
				print(result)
				
			}
		}
	}
	
	//MARK: - UISearchResults delegate
	
	func willPresentSearchController(searchController: UISearchController) {
		searchController.searchBar.selectedScopeButtonIndex = 0
	}
	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		
		deleteAllUnsavedItems()
		
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			fetchFoods(showSavedFoods: true)
			searchSavedFoods()
		} else {
			fetchFoods(showSavedFoods: false)
			
			searchBarSearchButtonClicked(searchController.searchBar)
		}
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			fetchFoods(showSavedFoods: true)
			searchSavedFoods()
			
		} else {
			fetchFoods(showSavedFoods: false)
		}
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		tableViewLoading(false)
		fetchFoods(showSavedFoods: true)
		tableView.reloadData()
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		fetchFoods(showSavedFoods: true)
		deleteAllUnsavedItems()
	}
	
	@IBAction func addBarButtonItemTapped(sender: UIBarButtonItem) {
		self.searchController.searchBar.becomeFirstResponder()
		deleteAllUnsavedItems()
	}
	
	func dismissKeyboard() {
		
		fetchFoods(showSavedFoods: true)
		
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		
		if textFieldInsideSearchBar?.isFirstResponder() == true {
			textFieldInsideSearchBar?.resignFirstResponder()
		}
	}
	
	//MARK: - Helpers
	
	// searchSavedFoods helper method:
	func searchSavedFoods() {
		
		deleteAllUnsavedItems()
		
		if let searchString = searchController.searchBar.text {
			
			let predicate: NSPredicate?
			
			if searchString.characters.count > 0 {
				predicate = NSPredicate(format:"name CONTAINS[cd] %@", searchString)
			} else {
				predicate = nil
			}
			
			sharedContext.performBlock({ () -> Void in
				
				do {
					self.foodsFetchedResultsController.fetchRequest.predicate = predicate
					try self.foodsFetchedResultsController.performFetch()
				}
				catch {
					print("Error fetching foods in searchSavedFoods method")
				}
			})
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
	}
	
	//presentConfirmation helper method
	func presentConfirmation(saved: Bool) {
		
		let frame = CGRect(x: CGRectGetMidX(view.frame)-35, y: CGRectGetMidY(view.frame)-35, width: 70, height: 70)
		let imageView = UIImageView(frame: frame)
		
		// if saved, present saved image, else present deleted image
		
		if saved {
			imageView.image = UIImage(named: "itemSavedIcon")
		} else {
			imageView.image = UIImage(named: "itemDeletedIcon")
		}
		
		imageView.alpha = 0.1
		view.addSubview(imageView)
		
		dispatch_async(dispatch_get_main_queue()) {
			
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				imageView.alpha = 1
				imageView.bounds.size.height *= 1.8
				imageView.bounds.size.width *= 1.8
				}) { (completion) -> Void in
					UIView.animateWithDuration(0.2, animations: { () -> Void in
						imageView.alpha = 0.1
						imageView.bounds.size.height = 1
						imageView.bounds.size.width = 1
						}, completion: { (completion) -> Void in
							imageView.removeFromSuperview()
					})
			}
			
		}
	}
	
	//deleteAllUnsavedItems halper method
	func deleteAllUnsavedItems() {
		
		fetchFoods(showSavedFoods: false)
		
		let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		for food in foods {
			if !(food.saved == true) {
				sharedContext.performBlock({ () -> Void in
					self.sharedContext.deleteObject(food)
					self.saveContext()
				})
			}
		}
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
	}
	
	//tableViewLoading helper method
	func tableViewLoading(loading: Bool) {
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.frame)-20, y: 115, width: 40, height: 40)
		let loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		searchController.view.addSubview(loadingIndicator)
		
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			
			if loading {
				self.tableView.alpha = 0.1
				if self.searchController.searchBar.text != "" {
					loadingIndicator.startAnimation()
				}
			}
			else {
				self.tableView.alpha = 1
				loadingIndicator.stopAnimation()
			}
			
			}) { (completion) -> Void in
				
				dispatch_async(dispatch_get_main_queue()) {
					self.tableView.reloadData()
					loadingIndicator.removeFromSuperview()
				}
		}
	}
	
	//saveContext helper method
	func saveContext() {
		sharedContext.performBlock { () -> Void in
			do {
				try self.sharedContext.save()
			}
			catch {
				print("Error saving Context")
			}
		}
	}
	
	//fetchFoods helper method
	func fetchFoods(showSavedFoods showSavedFoods: Bool) {
		
		if showSavedFoods {
			foodsFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "saved == %@", true)
		} else {
			foodsFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "saved != %@", true)
		}
		
		do {
			try foodsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching foods")
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
	}
	
	//Present a message helper method
	func presentMessage(title: String, message: String, action: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
}
