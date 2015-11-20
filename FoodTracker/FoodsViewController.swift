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
	
	var loadingIndicator: NVActivityIndicatorView!
	
	var searchController: UISearchController!
	
	//MARK: - View Life Cycles
	
	//viewWillAppear
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		print("viewWillAppear")
		
		if searchController.active {
			if searchController.searchBar.selectedScopeButtonIndex == 0 {
				fetchFoods(onlySavedFoods: true)
			}
			else {
				fetchFoods(onlySavedFoods: false)
			}
		}
		else {
			fetchFoods(onlySavedFoods: true)
		}
	}
	
	//viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("viewDidLoad")
		
		deleteAllUnsavedItems()
		fetchFoods(onlySavedFoods: true)
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.frame)-20, y: 165, width: 40, height: 40)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		fetchFoods(onlySavedFoods: true)
		
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
		searchController.hidesNavigationBarDuringPresentation = false
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
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	// nutrientsFetchedResultsController
	lazy var nutrientsFetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "NDBNutrient")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	
	// MARK: - fetchedResultsController delegate
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
		tableViewLoading(true)
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
		forChangeType type: NSFetchedResultsChangeType,
		newIndexPath: NSIndexPath?) {
			
			switch type {
			case .Insert:
				
				print("Insert")
				
				tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
				
			case .Delete:
				
				print("Delete")
				
				tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
				
			case .Update:
				
				print("Update")
				
				let cell = tableView.cellForRowAtIndexPath(indexPath!)! as UITableViewCell
				let food = foodsFetchedResultsController.objectAtIndexPath(indexPath!) as! NDBItem
				cell.textLabel?.text = food.name
				
			case .Move:
				
				print("Move")
				
				tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
				tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
			}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
		tableViewLoading(false)
		tableView.hidden = false
	}
	
	
	//MARK: - UITableViewDataSource
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("foodTableViewCell")! as UITableViewCell
		
		let foods = foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		cell.textLabel?.text = foods[indexPath.row].name
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return foodsFetchedResultsController.fetchedObjects!.count
		
		//		let sectionInfo = foodsFetchedResultsController.sections![section]
		//		return sectionInfo.numberOfObjects
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		let foods = self.foodsFetchedResultsController.fetchedObjects as! [NDBItem]
		let food = foods[indexPath.row]
		
		let eatAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "  Eat ", backgroundColor: MaterialDesignColor.green500, image: UIImage(named: "eatActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
			
			print("should eat: \(food.name!)")
			
			tableView.setEditing(false, animated: true)
		})
		
		let saveAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: " Save ", backgroundColor: MaterialDesignColor.blueGrey900, image: UIImage(named: "saveActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
			
			self.sharedContext.performBlock({ () -> Void in
				food.saved = true
				self.saveContext()
			})
			self.getNDBNutrientsFromNDBItem(food)
			self.presentConfirmation(true)
			
			tableView.setEditing(false, animated: true)
		})
		
		let deleteAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "Delete", backgroundColor: MaterialDesignColor.red500, image: UIImage(named: "deleteActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
			
			let alert = UIAlertController(title: "Delete", message: "Delete \(food.name!)", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				
				self.nutrientsFetchedResultsController.fetchRequest.predicate = NSPredicate(format:"item == %@", food)
				
				do {
					try self.nutrientsFetchedResultsController.performFetch()
				}
				catch {
					print("Error fetching nutrients for: \(food.name!)")
				}
				
				if let nutrients = self.nutrientsFetchedResultsController.fetchedObjects as? [NDBNutrient] {
					
					self.sharedContext.performBlock({ () -> Void in
						
						for nutrient in nutrients {
							self.sharedContext.deleteObject(nutrient)
							self.saveContext()
						}
						
						self.sharedContext.deleteObject(food)
						self.saveContext()
						self.presentConfirmation(false)
					})
					
				}
				
				tableView.setEditing(false, animated: true)
			})
			
			let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				
				dispatch_async(dispatch_get_main_queue()) {
					self.tableView.setEditing(false, animated: true)
				}
			})
			
			alert.addAction(cancelAlertAction)
			alert.addAction(deleteAlertAction)
			
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
			
			let foods = foodsFetchedResultsController.fetchedObjects as! [NDBItem]
			let selectedFood = foods[indexPath!.row]
			
			foodDeatailsVC.ndbItem = selectedFood
		}
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		
		deleteAllUnsavedItems()
		
		searchController.searchBar.selectedScopeButtonIndex = 1
		
		let searchString = self.searchController.searchBar.text
		
		if searchString?.characters.count > 0 {
			
			tableViewLoading(true)
			
			NDBClient.requestNDBItemsFromString(searchString!, type: NDBClient.NDBSearchType.ByRelevance) { (success, result, error) -> Void in
				
				if success {
					
					self.tableViewLoading(false)
					
					let ndbItems = result! as! [[String : AnyObject]]
					for item in ndbItems {
						self.sharedContext.performBlock({ () -> Void in
							_ = NDBItem(dictionary: item, context: self.sharedContext)
							self.saveContext()
						})
					}
				}
				else {
					
					self.tableViewLoading(false)
					self.presentMessage("Oops!", message: error!, action: "OK")
				}
			}
		}
	}
	
	
	//MARK: getNDBNutrientsFromNDBItem method
	func getNDBNutrientsFromNDBItem(ndbItem: NDBItem) {
		
		NDBClient.NDBReportForItem(ndbItem.ndbNo!, type: NDBClient.NDBReportType.Full) { (success, result, errorString) -> Void in
			
			if success {
				let nutrients = result as! [[String: AnyObject]]
				for nutrient in nutrients {
					
					if nutrient["nutrient_id"] as! Int == 301  ||
						nutrient["nutrient_id"] as! Int == 205 ||
						nutrient["nutrient_id"] as! Int == 601 ||
						nutrient["nutrient_id"] as! Int == 208 ||
						nutrient["nutrient_id"] as! Int == 204 ||
						nutrient["nutrient_id"] as! Int == 203 ||
						nutrient["nutrient_id"] as! Int == 269 ||
						nutrient["nutrient_id"] as! Int == 401
					{
						self.sharedContext.performBlock({ () -> Void in
							
							_ = NDBNutrient(item: ndbItem, dictionary: nutrient, context: self.sharedContext)
							self.saveContext()
							
						})
					}
				}
			}
			else {
				self.presentMessage("Oops!", message: errorString!, action: "OK")
			}
		}
	}
	
	
	//MARK: - UISearchResults delegate
	
	func willPresentSearchController(searchController: UISearchController) {
		
		print("willPresentSearchController")
		
		searchController.searchBar.selectedScopeButtonIndex = 0
	}
	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		
		print("selectedScopeButtonIndexDidChange")
		
		deleteAllUnsavedItems()
		
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			fetchFoods(onlySavedFoods: true)
			searchSavedFoods()
		}
		if searchController.searchBar.selectedScopeButtonIndex == 1 {
			fetchFoods(onlySavedFoods: false)
			searchBarSearchButtonClicked(searchController.searchBar)
		}
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		print("updateSearchResultsForSearchController")
		
		deleteAllUnsavedItems()
		
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			fetchFoods(onlySavedFoods: true)
			searchSavedFoods()
			
		} else {
			fetchFoods(onlySavedFoods: false)
		}
		tableView.reloadData()
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		
		print("didDismissSearchController")
		
		tableViewLoading(false)
		deleteAllUnsavedItems()
		fetchFoods(onlySavedFoods: true)
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		
		print("willDismissSearchController")
		
		tableViewLoading(false)
		deleteAllUnsavedItems()
	}
	
	@IBAction func addBarButtonItemTapped(sender: UIBarButtonItem) {
		self.searchController.searchBar.becomeFirstResponder()
		fetchFoods(onlySavedFoods: true)
	}
	
	func dismissKeyboard() {
		
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
		
		let frame = CGRect(x: CGRectGetMidX(view.frame)-60, y: CGRectGetMidY(view.frame)-60, width: 120, height: 120)
		let imageView = UIImageView(frame: frame)
		
		// if saved, present saved image, else present deleted image
		if saved {
			imageView.image = UIImage(named: "itemSavedIcon")
		} else {
			imageView.image = UIImage(named: "itemDeletedIcon")
		}
		
		imageView.alpha = 0.5
		view.addSubview(imageView)
		
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			imageView.alpha = 1
			imageView.bounds.size.height *= 1.2
			imageView.bounds.size.width *= 1.2
			}) { (completion) -> Void in
				UIView.animateWithDuration(0.2, animations: { () -> Void in
					imageView.alpha = 0.5
					imageView.bounds.size.height = 1
					imageView.bounds.size.width = 1
					}, completion: { (completion) -> Void in
						imageView.removeFromSuperview()
				})
		}
	}
	
	//deleteAllUnsavedItems halper method
	func deleteAllUnsavedItems() {
		
		if let foods = self.foodsFetchedResultsController.fetchedObjects as? [NDBItem] {
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
	}
	
	//tableViewLoading helper method
	func tableViewLoading(loading: Bool) {
		
		dispatch_async(dispatch_get_main_queue()) {
			
			if loading {
				self.tableView.hidden = true
				self.loadingIndicator.startAnimation()
			} else {
				self.tableView.hidden = false
				self.loadingIndicator.stopAnimation()
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
	func fetchFoods(onlySavedFoods onlySavedFoods: Bool) {
		
		if onlySavedFoods {
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
		
		saveContext()
		
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
		}
	}
	
	//Present a message helper method
	func presentMessage(title: String, message: String, action: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
		
		dispatch_async(dispatch_get_main_queue()) {
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
}
