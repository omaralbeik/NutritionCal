//
//  SavedFoodsViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 22/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import MaterialDesignColor
import NVActivityIndicatorView
import BGTableViewRowActionWithImage

class SavedFoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	let healthStore = HealthStore.sharedInstance()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noItemsSavedLabel: UILabel!
	
	var searchController: UISearchController!
	var loadingIndicator: NVActivityIndicatorView!
	
	var temporaryContext: NSManagedObjectContext!
	var searchResults: [NDBItem]? = []
	
	var NDBClientSharedInstance = NDBClient.sharedInstance()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchNDBItems()
		
		healthStore.requestAuthorizationForHealthStore()
		
		// Set the temporary context
		temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
		temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.bounds)-20, y: CGRectGetMidY(view.bounds)-40, width: 40, height: 40)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		
		tableView.delegate = self
		tableView.dataSource = self
		itemsFetchedResultsController.delegate = self
		
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
		
		// UI customizations
		searchController.searchBar.tintColor = MaterialDesignColor.green500
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		textFieldInsideSearchBar?.textColor = MaterialDesignColor.green500
		
		searchController.searchBar.barTintColor = MaterialDesignColor.grey200
		
		// button titles for search controller
		searchController.searchBar.scopeButtonTitles = ["Saved", "Online Results"]
		
		tableView.tableHeaderView = self.searchController.searchBar
		searchController.searchBar.delegate = self
		self.definesPresentationContext = true
		
		searchController.view.addSubview(loadingIndicator)
		self.view.addSubview(loadingIndicator)
		
	}
	
	
	// MARK: - Core Data Convenience
	// Shared Context from CoreDataStackManager
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	// itemsFetchedResultsController
	lazy var itemsFetchedResultsController: NSFetchedResultsController = {
		
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
	
	// measuresFetchedResultsController
	lazy var measuresFetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "NDBMeasure")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	
	// MARK: - fetchedResultsController delegate
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		if !searchController.active {
			tableView.beginUpdates()
			self.tableViewLoading(true)
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
		forChangeType type: NSFetchedResultsChangeType,
		newIndexPath: NSIndexPath?) {
			
			if !searchController.active {
				switch type {
				case .Insert:
					//					print("Insert")
					
					tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
					break
					
				case .Delete:
					//					print("Delete")
					
					tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
					break
					
				case .Update:
					//					print("Update")
					
					let cell = tableView.cellForRowAtIndexPath(indexPath!)! as UITableViewCell
					let food = itemsFetchedResultsController.objectAtIndexPath(indexPath!) as! NDBItem
					cell.textLabel?.text = food.name
					cell.detailTextLabel?.text = food.group
					
					break
					
				case .Move:
					//					print("Move")
					
					tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
					tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
					break
				}
			}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		if !searchController.active {
			tableView.endUpdates()
			tableViewLoading(false)
		}
		
	}
	
	
	
	//MARK: - UITableViewDataSource & UITableViewDelegate
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("SavedFoodTableViewCell")! as UITableViewCell
		
		if searchController.active && searchController.searchBar.selectedScopeButtonIndex == 1 {
			
			cell.textLabel?.text = self.searchResults![indexPath.row].name
			cell.detailTextLabel?.text = self.searchResults![indexPath.row].group
			return cell
			
		}
		
		let foods = itemsFetchedResultsController.fetchedObjects as! [NDBItem]
		cell.textLabel?.text = foods[indexPath.row].name
		cell.detailTextLabel?.text = foods[indexPath.row].group
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.active && searchController.searchBar.selectedScopeButtonIndex == 1 {
			
			if self.searchResults?.count == 0 {
				
				if searchController.searchBar.text?.characters.count == 0 {
					noItemsSavedLabel.text = "No Results!"
					noItemsSavedLabel.hidden = false
				}
				
			} else {
				noItemsSavedLabel.hidden = true
			}
			
			return self.searchResults!.count
		}
		
		if itemsFetchedResultsController.fetchedObjects?.count == 0 {
			noItemsSavedLabel.text = "No Items Saved.\nStart Adding Items by tapping +"
			noItemsSavedLabel.hidden = false
		} else {
			noItemsSavedLabel.hidden = true
		}
		
		return itemsFetchedResultsController.fetchedObjects!.count
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		let eatAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "     ", backgroundColor: MaterialDesignColor.green500, image: UIImage(named: "eatActionIcon"), forCellHeight: 110, handler: { (action, indexPath) -> Void in
			
			
			if !(self.searchController.active && self.searchController.searchBar.selectedScopeButtonIndex == 1) {
				
				let items = self.itemsFetchedResultsController.fetchedObjects as! [NDBItem]
				let item = items[indexPath.row]
				
				var nutrientsFetched: Bool {
					
					if let nutrients = item.nutrients {
						if nutrients.count > 0 {
							return true
						}
					}
					return false
				}
				
				if nutrientsFetched {
					
					self.eatItem(item)
					return
					
				} else {
					
					self.tableViewLoading(true)
					
					self.NutrientsForItem(item, saveResults: true, completionHandler: { (success, errorString) -> Void in
						
						if success {
							
							self.tableViewLoading(false)
							self.eatItem(item)
							return
							
						} else {
							
							self.tableViewLoading(false)
							self.presentMessage("Oops!", message: errorString!, action: "OK")
							
						}
						
					})
					
				}
				
				
			}
				
			else {
				
				let item = self.searchResults![indexPath.row]
				
				var nutrientsFetched: Bool {
					
					if let nutrients = item.nutrients {
						if nutrients.count > 0 {
							return true
						}
					}
					return false
				}
				
				if nutrientsFetched {
					
					self.eatItem(item)
					return
					
				} else {
					
					self.tableViewLoading(true)
					
					self.NutrientsForItem(item, saveResults: false, completionHandler: { (success, errorString) -> Void in
						
						if success {
							
							self.tableViewLoading(false)
							self.eatItem(item)
							return
							
						} else {
							
							self.tableViewLoading(false)
							self.presentMessage("Oops!", message: errorString!, action: "OK")
							
						}
						
					})
					
				}
				
			}
			
			tableView.setEditing(false, animated: true)
		})
		
		let saveAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "     ", backgroundColor: MaterialDesignColor.grey800, image: UIImage(named: "saveActionIcon"), forCellHeight: 110, handler: { (action, indexPath) -> Void in
			
			self.tableViewLoading(true)
			
			let item = self.searchResults![indexPath.row]
			let itemDict: [String: AnyObject] = ["name": item.name!, "ndbno": item.ndbNo!, "group": item.group!]
			
			let itemToSave = NDBItem(dictionary: itemDict, context: self.sharedContext)
			itemToSave.saved = true
			
			self.saveContext()
			
			self.NutrientsForItem(itemToSave, saveResults: true, completionHandler: { (success, errorString) -> Void in
				
				if success {
					self.tableViewLoading(false)
					self.saveContext()
					
				} else {
					self.tableViewLoading(false)
				}
				
			})
			
			tableView.setEditing(false, animated: true)
		})
		
		let deleteAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "     ", backgroundColor: MaterialDesignColor.red500, image: UIImage(named: "deleteActionIcon"), forCellHeight: 110, handler: { (action, indexPath) -> Void in
			
			var itemName: String {
				if !(self.searchController.active) {
					let item = self.itemsFetchedResultsController.fetchedObjects![indexPath.row] as! NDBItem
					return item.name!
				}
				else {
					return "item"
				}
				
			}
			
			let alert = UIAlertController(title: "Delete", message: "Delete (\(itemName)) ?", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				
				if let items = self.itemsFetchedResultsController.fetchedObjects as? [NDBItem] {
					let item = items[indexPath.row]
					self.deleteNDBItem(item)
				}
				
				tableView.setEditing(false, animated: true)
			})
			
			let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				
				self.tableView.setEditing(false, animated: true)
			})
			
			alert.addAction(deleteAlertAction)
			alert.addAction(cancelAlertAction)
			
			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(alert, animated: true, completion: nil)
			}
		})
		
		return searchController.active ? (searchController.searchBar.selectedScopeButtonIndex == 1 ? [eatAction, saveAction] : [eatAction, deleteAction]) : [eatAction, deleteAction]
		
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if !(searchController.active && self.searchController.searchBar.selectedScopeButtonIndex == 1) {
			
			let items = itemsFetchedResultsController.fetchedObjects as! [NDBItem]
			let item = items[indexPath.row]
			
			var nutrientsFetched: Bool {
				
				if let nutrients = item.nutrients {
					if nutrients.count > 0 {
						return true
					}
				}
				return false
			}
			
			if nutrientsFetched {
				
				dispatch_async(dispatch_get_main_queue()) {
					self.performSegueWithIdentifier("toItemDetailsViewControllerSegue", sender: self)
				}
				return
				
			} else {
				
				self.tableViewLoading(true)
				
				self.NutrientsForItem(item, saveResults: true, completionHandler: { (success, errorString) -> Void in
					
					if success {
						
						self.tableViewLoading(false)
						
						dispatch_async(dispatch_get_main_queue()) {
							self.performSegueWithIdentifier("toItemDetailsViewControllerSegue", sender: self)
						}
						return
						
					} else {
						
						self.tableViewLoading(false)
						self.presentMessage("Oops!", message: errorString!, action: "OK")
						
					}
					
				})
				
			}
			
			
		}
			
		else {
			
			let item = self.searchResults![indexPath.row]
			
			var nutrientsFetched: Bool {
				
				if let nutrients = item.nutrients {
					if nutrients.count > 0 {
						return true
					}
				}
				return false
			}
			
			if nutrientsFetched {
				
				dispatch_async(dispatch_get_main_queue()) {
					self.performSegueWithIdentifier("toItemDetailsViewControllerSegue", sender: self)
				}
				return
				
			} else {
				
				self.tableViewLoading(true)
				
				self.NutrientsForItem(item, saveResults: false, completionHandler: { (success, errorString) -> Void in
					
					if success {
						
						self.tableViewLoading(false)
						
						dispatch_async(dispatch_get_main_queue()) {
							self.performSegueWithIdentifier("toItemDetailsViewControllerSegue", sender: self)
						}
						return
						
					} else {
						
						self.tableViewLoading(false)
						self.presentMessage("Oops!", message: errorString!, action: "OK")
						
					}
					
				})
				
			}
			
		}
		
	}
	
	
	//MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		
		self.tableViewLoading(true)
		
		searchController.searchBar.selectedScopeButtonIndex = 1
		
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			self.searchSavedFoods()
			self.tableView.reloadData()
		}
		
		if searchController.searchBar.selectedScopeButtonIndex == 1 {
			
			if let searchString = searchController.searchBar.text {
				if searchString.characters.count > 0 {
					self.NDBItemsFromString(searchString, completionHandler: { (success, errorString) -> Void in
						
						if success {
							
							//	// Reload the table on the main thread
							dispatch_async(dispatch_get_main_queue()) {
								self.tableView.reloadData()
								self.tableViewLoading(false)
							}
							
						} else {
							
							dispatch_async(dispatch_get_main_queue()) {
								self.tableView.reloadData()
								self.tableViewLoading(false)
								self.presentMessage("Oops!", message: errorString!, action: "OK")
							}
						}
						
					})
					
				}
			}
		}
		
	}
	
	
	//MARK: - UISearchControllerDelegate
	func willPresentSearchController(searchController: UISearchController) {
		searchController.searchBar.selectedScopeButtonIndex = 0
		
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		searchController.searchBar.selectedScopeButtonIndex = 0
		self.tableViewLoading(false)
		NDBClientSharedInstance.cancelTask()
		self.searchResults = []
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		tableView.reloadData()
		
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		NDBClientSharedInstance.cancelTask()
		
		if searchController.searchBar.selectedScopeButtonIndex == 0 {
			self.searchSavedFoods()
			self.tableView.reloadData()
		}
		
		if searchController.searchBar.selectedScopeButtonIndex == 1 {
			
			if let searchString = searchController.searchBar.text {
				
				if searchString.characters.count == 0 {
					self.searchResults = []
					tableView.reloadData()
				}
				
				if searchString.characters.count > 0 {
					
					tableViewLoading(true)
					self.NDBItemsFromString(searchString, completionHandler: { (success, errorString) -> Void in
						
						if success {
							
							//	// Reload the table on the main thread
							dispatch_async(dispatch_get_main_queue()) {
								self.tableView.reloadData()
								self.tableViewLoading(false)
							}
							
						} else {
							
							dispatch_async(dispatch_get_main_queue()) {
								//self.presentMessage("Oops!", message: errorString!, action: "OK")
								self.tableViewLoading(false)
							}
						}
						
					})
					
				}
			}
		}
		
	}
	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		tableView.reloadData()
	}
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "toItemDetailsViewControllerSegue" {
			
			var item: NDBItem {
				
				let indexPath = self.tableView.indexPathForSelectedRow!
				
				if !(searchController.active && searchController.searchBar.selectedScopeButtonIndex == 1) {
					
					let items = self.itemsFetchedResultsController.fetchedObjects as! [NDBItem]
					return items[indexPath.row]
					
				} else {
					
					return self.searchResults![indexPath.row]
				}
			}
			
			let itemDetailsVC = segue.destinationViewController as! ItemDetailsViewController
			itemDetailsVC.ndbItem = item
			
		}
	}
	
	
	@IBAction func addBarButtomItemTapped(sender: UIBarButtonItem) {
		self.searchController.searchBar.becomeFirstResponder()
	}
	
	
	//MARK: APIs Helpers
	
	func NDBItemsFromString(searchString: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
		
		if Reachability.isConnectedToNetwork() {
			
			NDBClientSharedInstance.NDBItemsFromString(searchString, type: .ByRelevance, completionHandler: { (success, result, errorString) -> Void in
				
				if success {
					
					if let results = result as? [[String: AnyObject]] {
						self.searchResults = results.map() {
							NDBItem(dictionary: $0, context: self.temporaryContext)
						}
					}
					completionHandler(success: true, errorString: nil)
					
				} else {
					
					completionHandler(success: false, errorString: errorString)
				}
				
			})
			
		} else {
			self.presentNoConnectionMessage()
		}
		
	}
	
	func NutrientsForItem(item: NDBItem, saveResults: Bool, completionHandler: (success: Bool, errorString: String?) -> Void) {
		
		if Reachability.isConnectedToNetwork() {
			
			NDBClientSharedInstance.NDBReportForItem(item.ndbNo!, type: .Full, completionHandler: { (success, result, errorString) -> Void in
				
				if success {
					
					if let nutrients = result as? [[String: AnyObject]] {
						
						for nutrient in nutrients {
							let nutrientObject = NDBNutrient(item: item, dictionary: nutrient, context: item.managedObjectContext!)
							
							if let measures = nutrient["measures"] as? [[String: AnyObject]] {
								
								for measure in measures {
									_ = NDBMeasure(nutrient: nutrientObject, dictionary: measure, context: item.managedObjectContext!)
								}
							}
						}
						
						if saveResults {
							
							item.managedObjectContext?.performBlock({
								
								do {
									try item.managedObjectContext?.save()
								} catch {
									print("Error saving context after adding measures")
									return
								}
							})
							
						}
						
						completionHandler(success: true, errorString: nil)
						
					}
					
				} else {
					
					completionHandler(success: false, errorString: errorString)
				}
				
			})
			
		} else {
			self.presentNoConnectionMessage()
		}
	}
	
	func eatItem(ndbItem: NDBItem) {
		
		let alert = UIAlertController(title: "Select Size:", message: "\(ndbItem.name!) has many sizes, Please choose one to eat/drink:", preferredStyle: .ActionSheet)
		
		let nutrients = ndbItem.nutrients
		
		for nutrient in nutrients! {
			
			if nutrient.id == 208 {
				
				for measure in nutrient.measures! {
					let action = UIAlertAction(title: measure.label!, style: .Default, handler: { (action) -> Void in
						print("Should eat: \(measure.label!)")
						
						let qtyAlert = UIAlertController(title: "Enter Quanitity", message: "How many \(measure.label!) did you eat/drink ?", preferredStyle:
							UIAlertControllerStyle.Alert)
						
						qtyAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
							
							textField.placeholder = "Enter quanitity"
							textField.keyboardType = UIKeyboardType.NumberPad
							textField.addTarget(self, action: "qtyTextChanged:", forControlEvents: .EditingChanged)
						})
						
						qtyAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
						
						let eatAction = UIAlertAction(title: "Eat!", style: .Default, handler: { (action) -> Void in
							
							let textField = qtyAlert.textFields?.first!
							if textField != nil {
								print(textField!.text!)
								
								if let qty = Int(textField!.text!) {
									
									// create a DayEntry for the item eated
									_ = DayEntry(item: ndbItem, measure: measure, qty: qty, context: self.sharedContext)
									self.saveContext()
									
									if let healthStoreSync = NSUserDefaults.standardUserDefaults().valueForKey("healthStoreSync") as? Bool {
										
										if healthStoreSync {
											
											self.healthStore.addNDBItemToHealthStore(ndbItem, selectedMeasure: measure, qty: qty, completionHandler: { (success, errorString) -> Void in
												
												if success {
													print("\(ndbItem.name!) added to helth app")
												} else {
													print(errorString!)
													self.presentMessage("Oops!", message: errorString!, action: "OK")
												}
												
											})
											
										}
										
									}
								}
								
							}
							
						})
						eatAction.enabled = false
						
						qtyAlert.addAction(eatAction)
						
						qtyAlert.view.tintColor = MaterialDesignColor.green500
						
						dispatch_async(dispatch_get_main_queue()) {
							self.presentViewController(qtyAlert, animated: true, completion: nil)
							qtyAlert.view.tintColor = MaterialDesignColor.green500
							self.tableView.setEditing(false, animated: true)
						}
						
					})
					alert.addAction(action)
				}
			}
			
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
			
		}))
		
		dispatch_async(dispatch_get_main_queue()) {
			
			alert.view.tintColor = MaterialDesignColor.green500
			
			self.presentViewController(alert, animated: true, completion: nil)
			
			alert.view.tintColor = MaterialDesignColor.green500
			
		}
	}
	
	func qtyTextChanged(sender:AnyObject) {
		let tf = sender as! UITextField
		var resp : UIResponder = tf
		while !(resp is UIAlertController) { resp = resp.nextResponder()! }
		let alert = resp as! UIAlertController
		(alert.actions[1] as UIAlertAction).enabled = (tf.text != "")
	}
	
	
	//MARK: - CoreData Helpers
	
	func fetchNDBItems() {
		do {
			try itemsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching old NDB items")
		}
	}
	
	func deleteNDBItem(item: NDBItem) {
		
		nutrientsFetchedResultsController.fetchRequest.predicate = NSPredicate(format:"item ==  %@", item)
		
		do {
			try self.nutrientsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching nutrients for: \(item.name!)")
			return
		}
		
		let nutrients = nutrientsFetchedResultsController.fetchedObjects as! [NDBNutrient]
		
		for nutrient in nutrients {
			
			measuresFetchedResultsController.fetchRequest.predicate = NSPredicate(format:"nutrient ==  %@", nutrient)
			
			do {
				try self.measuresFetchedResultsController.performFetch()
			} catch {
				print("Error fetching measures for: \(nutrient.name)")
				return
			}
			
			if let measures = measuresFetchedResultsController.fetchedObjects as? [NDBMeasure] {
				
				for measure in measures {
					sharedContext.performBlock({
						self.sharedContext.deleteObject(measure)
					})
					print("measure deleted")
				}
			}
			self.saveContext()
			
			sharedContext.performBlock({
				self.sharedContext.deleteObject(nutrient)
			})
			self.saveContext()
		}
		
		self.sharedContext.performBlock ({
			
			self.sharedContext.deleteObject(item)
		})
		self.saveContext()
		
	}
	
	func saveContext() {
		sharedContext.performBlock {
			do {
				try self.sharedContext.save()
			}
			catch {
				print("Error saving Context in saveContext method")
			}
		}
	}
	
	func searchSavedFoods() {
		
		if let searchString = searchController.searchBar.text {
			
			let predicate: NSPredicate?
			
			if searchString.characters.count > 0 {
				predicate = NSPredicate(format:"name CONTAINS[cd] %@", searchString)
			} else {
				predicate = nil
			}
			
			do {
				self.itemsFetchedResultsController.fetchRequest.predicate = predicate
				try self.itemsFetchedResultsController.performFetch()
			}
			catch {
				print("Error fetching foods in searchSavedFoods method")
				return
			}
			
			if itemsFetchedResultsController.fetchedObjects?.count < 1 {
				searchController.searchBar.selectedScopeButtonIndex = 1
			}
			
		}
		
	}
	
	
	//MARK: - Helpers
	
	func tableViewLoading(loading: Bool) {
		
		dispatch_async(dispatch_get_main_queue()) {
			
			if loading {
				self.tableView.hidden = true
				self.noItemsSavedLabel.hidden = true
				self.loadingIndicator.startAnimation()
			} else {
				self.tableView.hidden = false
				self.loadingIndicator.stopAnimation()
			}
		}
	}
	
	func dismissKeyboard() {
		
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		
		if textFieldInsideSearchBar?.isFirstResponder() == true {
			textFieldInsideSearchBar?.resignFirstResponder()
		}
	}
	
	func presentMessage(title: String, message: String, action: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
		
		dispatch_async(dispatch_get_main_queue()) {
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	func presentNoConnectionMessage() {
		dismissKeyboard()
		searchController.active = false
		tableViewLoading(false)
		self.presentMessage("No Internet", message: "Internet connection is required to save items!, please connect and try again", action: "OK")
	}
	
}
