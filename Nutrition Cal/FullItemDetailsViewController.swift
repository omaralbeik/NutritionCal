//
//  FullItemDetailsViewController.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import MaterialDesignColor
import RKDropdownAlert

class FullItemDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	var ndbItem: NDBItem!
	
	let healthStore = HealthStore.sharedInstance()
	
	var nutritionsArray: [NDBNutrient] = []
	var filtredNutritionsArray: [NDBNutrient] = []
	
	@IBOutlet weak var tableView: UITableView!
	
	var searchController: UISearchController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		nutritionsArray = ndbItem.nutrients!
		
		tableView.delegate = self
		tableView.dataSource = self
		
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
		
		tableView.tableHeaderView = self.searchController.searchBar
		self.definesPresentationContext = true
		
	}
	
	// MARK: - Core Data Convenience
	// Shared Context from CoreDataStackManager
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		let searchString = self.searchController.searchBar.text
		
		if searchString?.characters.count > 0 {
			filterContentForSearch(searchString!)
		} else {
			filtredNutritionsArray = nutritionsArray
		}
		tableView.reloadData()
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FullItemDetailsViewControllerTableViewCell")!
		
		if searchController.active {
			
			cell.textLabel?.text = filtredNutritionsArray[indexPath.row].name
			
			let value = filtredNutritionsArray[indexPath.row].value! as Double
			let roundedValue = Double(round(1000*value)/1000)
			
			let valueText = "\(roundedValue) " + filtredNutritionsArray[indexPath.row].unit!
			cell.detailTextLabel?.text = valueText
			
		} else {
			
			cell.textLabel?.text = nutritionsArray[indexPath.row].name
			
			let value = nutritionsArray[indexPath.row].value! as Double
			let roundedValue = Double(round(1000*value)/1000)
			
			let valueText = "\(roundedValue) " + nutritionsArray[indexPath.row].unit!
			cell.detailTextLabel?.text = valueText
			
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.active {
			return filtredNutritionsArray.count
		} else {
			return nutritionsArray.count
		}
	}
	
	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: "Select Size:", message: "\(ndbItem.name!) has many sizes, Please choose one to eat/drink:", preferredStyle: .ActionSheet)
		
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
									let dayEntry = DayEntry(item: self.ndbItem!, measure: measure, qty: qty, context: self.sharedContext)
									self.saveContext()
									
									// show eated dropdown alert
									dispatch_async(dispatch_get_main_queue()) {
										_ = RKDropdownAlert.title("Added", message: "\(dayEntry.ndbItemName) added to History successfully.", backgroundColor: MaterialDesignColor.green500, textColor: UIColor.whiteColor(), time: 2)
									}
									
									if let healthStoreSync = NSUserDefaults.standardUserDefaults().valueForKey("healthStoreSync") as? Bool {
										
										if healthStoreSync {
											
											self.healthStore.addNDBItemToHealthStore(self.ndbItem, selectedMeasure: measure, qty: qty, completionHandler: { (success, errorString) -> Void in
												
												if success {
													print("\(self.ndbItem.name!) added to helth app")
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
							
						}
						
					})
					alert.addAction(action)
				}
			}
			
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
			
		}))
		
		alert.view.tintColor = MaterialDesignColor.green500
		
		presentViewController(alert, animated: true, completion: nil)
		
		alert.view.tintColor = MaterialDesignColor.green500
		
	}
	
	
	//MARK: - Helpers
	
	func filterContentForSearch (searchString: String) {
		
		filtredNutritionsArray = nutritionsArray.filter({ (nutrient) -> Bool in
			let nutrientMatch = nutrient.name!.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
			return nutrientMatch != nil ? true : false
		})
	}
	
	func qtyTextChanged(sender:AnyObject) {
		let tf = sender as! UITextField
		var resp : UIResponder = tf
		while !(resp is UIAlertController) { resp = resp.nextResponder()! }
		let alert = resp as! UIAlertController
		(alert.actions[1] as UIAlertAction).enabled = (tf.text != "")
	}
	
	func saveContext() {
		
		dispatch_async(dispatch_get_main_queue()) {
			CoreDataStackManager.sharedInstance().saveContext()
		}
	}

}
