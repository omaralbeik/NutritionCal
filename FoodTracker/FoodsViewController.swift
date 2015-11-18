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

class FoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating  {
	
	var searchResults: [[String: AnyObject]] = []
	
	// button titles for search controller
	var scopeButtonTitles = ["Saved", "Search Results"]
	
	// loading indicator for search controller
	var loadingIndicator: NVActivityIndicatorView!
	
	// shared tableView
	@IBOutlet weak var tableView: UITableView!
	
	var searchController: UISearchController!
	
	// Shared Context from CoreDataStackManager
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.frame)-15, y: 115, width: 30, height: 30)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		// UI customizations
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MaterialDesignColor.green500]
		
		searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.scopeButtonTitles = scopeButtonTitles
		
		searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
		
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
	
	
	//MARK: - UITableViewDataSource
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("foodTableViewCell")! as UITableViewCell
		
		cell.textLabel?.text = searchResults[indexPath.row]["name"] as? String
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		
		if searchController.active {
			
			let eatAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: " Eat", backgroundColor: MaterialDesignColor.green500, image: UIImage(named: "eatActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
				print("should eat")
				tableView.setEditing(false, animated: true)
			})
			
			let saveAction = BGTableViewRowActionWithImage.rowActionWithStyle(.Default, title: "Save", backgroundColor: MaterialDesignColor.blueGrey900, image: UIImage(named: "saveActionIcon"), forCellHeight: 65, handler: { (action, indexPath) -> Void in
				print("should save")
				tableView.setEditing(false, animated: true)
			})

			return [eatAction, saveAction]
			
		}
		
		return [UITableViewRowAction()]
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		dismissKeyboard()
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		
		searchController.searchBar.selectedScopeButtonIndex = 1
		
		hideTableView(true)
		
		let searchString = self.searchController.searchBar.text
		
		NDB.requestNDBItemsFromString(searchString!, type: NDBSearchType.ByRelevance) { (success, items, error) -> Void in
			if success {
				print(items!.count)
				self.searchResults = items! as! [[String : AnyObject]]
				
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
		
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		
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
