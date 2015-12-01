//
//  SavedFoodsViewController.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import MaterialDesignColor
import NVActivityIndicatorView
import BGTableViewRowActionWithImage
import RKDropdownAlert
import DGRunkeeperSwitch

class SavedFoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	let healthStore = HealthStore.sharedInstance()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noItemsSavedLabel: UILabel!
	@IBOutlet weak var addBarButton: UIBarButtonItem!
	
	var mainNavSwitch: DGRunkeeperSwitch!
	
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
		temporaryContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.bounds)-20, y: CGRectGetMidY(view.bounds)-40, width: 40, height: 40)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		mainNavSwitch = DGRunkeeperSwitch(leftTitle: "Favorites", rightTitle: "Online")
		mainNavSwitch.frame = CGRect(x: 50, y: 20, width: CGRectGetWidth(self.view.bounds) - 100, height: 30)
		mainNavSwitch.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 12)
		mainNavSwitch.backgroundColor = MaterialDesignColor.green500
		mainNavSwitch.tintColor = UIColor.whiteColor()
		mainNavSwitch.selectedTitleColor = MaterialDesignColor.green500
		mainNavSwitch.autoresizingMask = [.FlexibleWidth]
		mainNavSwitch.addTarget(self, action: "mainNavSwitchSelectedIndexChanged:", forControlEvents: UIControlEvents.ValueChanged)
		
		navigationItem.titleView = mainNavSwitch
		
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
		
		searchController.searchBar.barTintColor = MaterialDesignColor.green500
		searchController.searchBar.tintColor = UIColor.whiteColor()
		
		// button titles for search controller
		
		
		tableView.tableHeaderView = self.searchController.searchBar
		searchController.searchBar.delegate = self
		self.definesPresentationContext = true
		
		searchController.view.addSubview(loadingIndicator)
		self.view.addSubview(loadingIndicator)
		
	}
	
	func mainNavSwitchSelectedIndexChanged(sender: DGRunkeeperSwitch) {
		print(sender.selectedIndex)
		
		if sender.selectedIndex == 1 {
			self.searchController.searchBar.becomeFirstResponder()
			self.addBarButton.enabled = false
		}
		
		tableView.reloadData()
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
		if !(searchController.active && self.mainNavSwitch.selectedIndex == 1) {
			self.tableViewLoading(true)
			tableView.beginUpdates()
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
		forChangeType type: NSFetchedResultsChangeType,
		newIndexPath: NSIndexPath?) {
			
			if !(searchController.active && self.mainNavSwitch.selectedIndex == 1) {
				
				switch type {
				case .Insert:
					tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
					break
					
				case .Delete:
					tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
					break
					
				case .Update:
					let cell = tableView.cellForRowAtIndexPath(indexPath!)! as UITableViewCell
					let food = itemsFetchedResultsController.objectAtIndexPath(indexPath!) as! NDBItem
					cell.textLabel?.text = food.name
					cell.detailTextLabel?.text = food.group
					break
					
				case .Move:
					tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
					tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
					break
				}
				
			}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		if !(searchController.active && self.mainNavSwitch.selectedIndex == 1) {
			tableView.endUpdates()
			tableViewLoading(false)
		}
		
	}
	
	
	
	//MARK: - UITableViewDataSource & UITableViewDelegate
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("SavedFoodTableViewCell")! as UITableViewCell
		
		if searchController.active && self.mainNavSwitch.selectedIndex == 1 {
			
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
		
		if searchController.active && self.mainNavSwitch.selectedIndex == 1 {
			
			if self.searchResults?.count == 0 {
				
				if searchController.searchBar.text?.characters.count == 0 {
					
					noItemsSavedLabel.text = "Search for Foods & Drinks Online."
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
			
			
			if !(self.searchController.active && self.mainNavSwitch.selectedIndex == 1) {
				
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
					
					self.eatNDBItem(item)
					return
					
				} else {
					
					self.tableViewLoading(true)
					
					self.NutrientsForNDBItem(item, completionHandler: { (success, errorString) -> Void in
						
						if success {
							
							dispatch_async(dispatch_get_main_queue()) {
								self.tableViewLoading(false)
								self.eatNDBItem(item)
								return
							}
							
						} else {
							
							dispatch_async(dispatch_get_main_queue()) {
								self.tableViewLoading(false)
								self.presentMessage("Oops!", message: errorString!, action: "OK")
							}
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
					
					self.eatNDBItem(item)
					return
					
				} else {
					
					self.tableViewLoading(true)
					
					self.NutrientsForNDBItem(item, completionHandler: { (success, errorString) -> Void in
						
						if success {
							
							dispatch_async(dispatch_get_main_queue()) {
								self.tableViewLoading(false)
								self.eatNDBItem(item)
								return
							}
							
						} else {
							
							dispatch_async(dispatch_get_main_queue()) {
								self.tableViewLoading(false)
								self.presentMessage("Oops!", message: errorString!, action: "OK")
							}
						}
						
					})
					
				}
				
			}
			
			tableView.setEditing(false, animated: true)
		})
		
		let saveAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "     ", backgroundColor: MaterialDesignColor.grey800, image: UIImage(named: "saveActionIcon"), forCellHeight: 110, handler: { (action, indexPath) -> Void in
			
			self.tableViewLoading(true)
			
			let item = self.searchResults![indexPath.row]
			let itemDict: [String: AnyObject] = ["name": item.name, "ndbno": item.ndbNo, "group": item.group!]
			
			
			var itemAlreadySaved: Bool {
				
				let savedItems = self.itemsFetchedResultsController.fetchedObjects as! [NDBItem]
				
				for savedItem in savedItems {
					if savedItem.ndbNo == item.ndbNo {
						return true
					}
				}
				return false
			}
			
			
			if !itemAlreadySaved {
				
				dispatch_async(dispatch_get_main_queue()) {
					
					let itemToSave = NDBItem(dictionary: itemDict, context: self.sharedContext)
					itemToSave.saved = true
					
					self.NutrientsForNDBItem(itemToSave, completionHandler: { (success, errorString) -> Void in
						
						if success {
							self.tableViewLoading(false)
							
							self.saveContext()
							
							// show success dropdown alert
							dispatch_async(dispatch_get_main_queue()) {
								_ = RKDropdownAlert.title("Saved", message: "", backgroundColor: MaterialDesignColor.grey800, textColor: UIColor.whiteColor(), time: 2)
							}
							
						} else {
							self.tableViewLoading(false)
						}
						
					})
					
					GoogleClient.sharedInstance().getImageFromString(itemToSave.name, completionHandler: { (success, image, errorString) -> Void in
						
						if success {
							
							dispatch_async(dispatch_get_main_queue()) {
								
								itemToSave.image = image
								self.saveContext()
								print("\(itemToSave.ndbNo) image saved")
								
							}
							
						}
						
					})
					
				}
				
			} else {
				
				// show slready saved dropdown alert
				dispatch_async(dispatch_get_main_queue()) {
					_ = RKDropdownAlert.title("Already Saved", message: "", backgroundColor: MaterialDesignColor.ameber800, textColor: UIColor.whiteColor(), time: 2)
					self.tableViewLoading(false)
				}
			}
			
			tableView.setEditing(false, animated: true)
		})
		
		let deleteAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "     ", backgroundColor: MaterialDesignColor.red500, image: UIImage(named: "deleteActionIcon"), forCellHeight: 110, handler: { (action, indexPath) -> Void in
			
			var itemName: String {
				if !(self.searchController.active && self.mainNavSwitch.selectedIndex == 1) {
					let item = self.itemsFetchedResultsController.fetchedObjects![indexPath.row] as! NDBItem
					return item.name
				}
				else {
					return "item"
				}
				
			}
			
			let alert = UIAlertController(title: "Delete", message: "Delete (\(itemName)) ?", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				
				if let items = self.itemsFetchedResultsController.fetchedObjects as? [NDBItem] {
					let item = items[indexPath.row]
					_ = item.name
					self.deleteNDBItem(item)
					
					// show deleted dropdown alert
					dispatch_async(dispatch_get_main_queue()) {
						_ = RKDropdownAlert.title("Deleted", message: "", backgroundColor: MaterialDesignColor.red500, textColor: UIColor.whiteColor(), time: 2)
					}
					
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
		
		return searchController.active ? (mainNavSwitch.selectedIndex == 1 ? [eatAction, saveAction] : [eatAction, deleteAction]) : [eatAction, deleteAction]
		
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if !(searchController.active && self.mainNavSwitch.selectedIndex == 1) {
			
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
				
				self.NutrientsForNDBItem(item, completionHandler: { (success, errorString) -> Void in
					
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
				
				self.NutrientsForNDBItem(item, completionHandler: { (success, errorString) -> Void in
					
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
		
		self.mainNavSwitch.setSelectedIndex(1, animated: true)
		
		if self.mainNavSwitch.selectedIndex == 0 {
			self.searchSavedFoods()
			self.tableView.reloadData()
		}
		
		if self.mainNavSwitch.selectedIndex == 1 {
			
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
							}
						}
						
					})
					
				}
			}
		}
		
	}
	
	
	//MARK: - UISearchControllerDelegate
	
	func didPresentSearchController(searchController: UISearchController) {
		self.searchController.searchBar.becomeFirstResponder()
		self.addBarButton.enabled = false
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		self.mainNavSwitch.setSelectedIndex(0, animated: true)
		self.tableViewLoading(false)
		NDBClientSharedInstance.cancelTask()
		self.searchResults = []
		self.addBarButton.enabled = true
	}
	
	func didDismissSearchController(searchController: UISearchController) {
		tableView.reloadData()
		self.addBarButton.enabled = true
	}
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		NDBClientSharedInstance.cancelTask()
		
		if self.mainNavSwitch.selectedIndex == 0 {
			self.searchSavedFoods()
			self.tableView.reloadData()
		}
		
		if self.mainNavSwitch.selectedIndex == 1 {
			
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
								self.tableView.reloadData()
								self.tableViewLoading(false)
								self.noItemsSavedLabel.text = "No Results!"
								self.noItemsSavedLabel.hidden = false
							}
						}
						
					})
					
				}
			}
		}
		
	}
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "toItemDetailsViewControllerSegue" {
			
			var item: NDBItem {
				
				let indexPath = self.tableView.indexPathForSelectedRow!
				
				if !(searchController.active && self.mainNavSwitch.selectedIndex == 1) {
					
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
		
		if self.tableView.contentOffset.y > -64.0 {
			self.tableView.setContentOffset(CGPoint(x: 0, y: -64), animated:true)
		} else {
			self.searchController.active = true
		}
	}
	
	
	func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
		if self.tableView.contentOffset.y == -64.0 {
			self.searchController.active = true
		}
	}
	
	//MARK: APIs Helpers
	
	func NDBItemsFromString(searchString: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
		
		if Reachability.isConnectedToNetwork() {
			
			NDBClientSharedInstance.NDBItemsFromString(searchString, type: .ByRelevance, completionHandler: { (success, result, errorString) -> Void in
				
				if success {
					
					if let results = result as? [[String: AnyObject]] {
						
						dispatch_async(dispatch_get_main_queue()) {
							self.searchResults = results.map() {
								NDBItem(dictionary: $0, context: self.temporaryContext)
							}
						}
					}
					
					completionHandler(success: true, errorString: nil)
					
				} else {
					self.searchResults = []
					print(errorString)
					completionHandler(success: false, errorString: errorString)
				}
				
			})
			
		} else {
			self.presentNoConnectionMessage()
		}
		
	}
	
	func NutrientsForNDBItem(ndbItem: NDBItem, completionHandler: (success: Bool, errorString: String?) -> Void) {
		
		if Reachability.isConnectedToNetwork() {
			
			NDBClientSharedInstance.NDBReportForItem(ndbItem.ndbNo, type: .Full, completionHandler: { (success, result, errorString) -> Void in
				
				if success {
					
					if let nutrients = result as? [[String: AnyObject]] {
						
						for nutrient in nutrients {
							
							dispatch_async(dispatch_get_main_queue()) {
								
								let nutrientObject = NDBNutrient(item: ndbItem, dictionary: nutrient, context: ndbItem.managedObjectContext!)
								
								if let measures = nutrient["measures"] as? [[String: AnyObject]] {
									
									for measure in measures {
										_ = NDBMeasure(nutrient: nutrientObject, dictionary: measure, context: ndbItem.managedObjectContext!)
										
									}
								}
								
							}
							
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
	
	func eatNDBItem(ndbItem: NDBItem) {
		
		let alert = UIAlertController(title: "Select Size:", message: "\(ndbItem.name) has many sizes, Please choose one to eat/drink:", preferredStyle: .ActionSheet)
		
		let nutrients = ndbItem.nutrients
		
		for nutrient in nutrients! {
			
			if nutrient.id == 208 {
				
				for measure in nutrient.measures! {
					let action = UIAlertAction(title: measure.label!, style: .Default, handler: { (action) -> Void in
						
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
								
								if let qty = Int(textField!.text!) {
									
									// create a DayEntry for the item eated
									
									dispatch_async(dispatch_get_main_queue()) {
										
										_ = DayEntry(item: ndbItem, measure: measure, qty: qty, context: self.sharedContext)
										CoreDataStackManager.sharedInstance().saveContext()
										
										// show eated dropdown alert
										dispatch_async(dispatch_get_main_queue()) {
											_ = RKDropdownAlert.title("Added", message: "", backgroundColor: MaterialDesignColor.green500, textColor: UIColor.whiteColor(), time: 2)
										}
										
									}
									
									if let healthStoreSync = NSUserDefaults.standardUserDefaults().valueForKey("healthStoreSync") as? Bool {
										
										if healthStoreSync {
											
											self.healthStore.addNDBItemToHealthStore(ndbItem, selectedMeasure: measure, qty: qty, completionHandler: { (success, errorString) -> Void in
												
												if success {
													print("\(ndbItem.name) added to helth app")
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
		
		alert.view.tintColor = MaterialDesignColor.green500
		
		dispatch_async(dispatch_get_main_queue()) {
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
	func saveContext() {
		dispatch_async(dispatch_get_main_queue()) {
			CoreDataStackManager.sharedInstance().saveContext()
		}
	}
	
	func fetchNDBItems() {
		do {
			try itemsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching old NDB items")
		}
	}
	
	func deleteNDBItem(item: NDBItem) {
		
		// delete items image from documents directory
		if item.image != nil {
			ImageCache.sharedInstance().deleteImageWithIdentifier(item.ndbNo)
		}
		
		nutrientsFetchedResultsController.fetchRequest.predicate = NSPredicate(format:"item ==  %@", item)
		
		do {
			try self.nutrientsFetchedResultsController.performFetch()
		}
		catch {
			print("Error fetching nutrients for: \(item.name)")
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
					
					dispatch_async(dispatch_get_main_queue()) {
						self.sharedContext.deleteObject(measure)
					}
					
				}
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				self.sharedContext.deleteObject(nutrient)
			}
			
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			self.sharedContext.deleteObject(item)
			self.saveContext()
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
				self.mainNavSwitch.setSelectedIndex(1, animated: true)
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
	
	
	func presentNoConnectionMessage() {
		tableViewLoading(false)
		dismissKeyboard()
		searchController.active = false
		self.presentMessage("No Internet", message: "Internet connection is required to save items!, please connect and try again", action: "OK")
	}
	
}
