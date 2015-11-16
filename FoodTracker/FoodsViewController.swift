//
//  FoodsViewController.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import MaterialDesignColor
import NVActivityIndicatorView

class FoodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating  {
	
	var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
	
	var loadingIndicator: NVActivityIndicatorView!
	
	@IBOutlet weak var tableView: UITableView!
	
	var searchController: UISearchController!
	
	var suggestedSearchFoods:[String] = []
	var filteredSuggestedSearchFoods:[String] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		let frame = CGRect(x: CGRectGetMidX(view.frame)-15, y: 115, width: 30, height: 30)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		
		suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
		
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		
		navigationController?.navigationBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MaterialDesignColor.green500]
		
		searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.scopeButtonTitles = scopeButtonTitles
		
		searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
		
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
		let foodName : String
		if self.searchController.active {
			foodName = filteredSuggestedSearchFoods[indexPath.row]
		}
		else {
			foodName = suggestedSearchFoods[indexPath.row]
		}
		cell.textLabel?.text = foodName
		cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		return cell
		
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if self.searchController.active {
			return self.filteredSuggestedSearchFoods.count
		}
		else {
			return self.suggestedSearchFoods.count
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		dismissKeyboard()
	}
	
	
	//MARK: - UISearchResultsUpdating
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		if searchController.searchBar.text != "" {
			loadingIndicator.startAnimation()
		}
		
		let searchString = self.searchController.searchBar.text
		let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
		filterContentForSearch(searchString!, scope: selectedScopeButtonIndex)
		tableView.reloadData()
		
		USDA.searchFoodForString(searchString!) { (success, result, error) -> Void in
			
			dispatch_async(dispatch_get_main_queue()) {
				self.loadingIndicator.stopAnimation()
			}
			
			if !success {
				print(error)
			}
		
		}
		
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		loadingIndicator.stopAnimation()
	}
	
	
	//MARK: - Helpers
	func filterContentForSearch (searchText: String, scope: Int) {
		self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food : String) -> Bool in
			let foodMatch = food.rangeOfString(searchText)
			return foodMatch != nil
		})
	}
	
	func dismissKeyboard() {
		
		let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
		
		if textFieldInsideSearchBar?.isFirstResponder() == true {
			textFieldInsideSearchBar?.resignFirstResponder()
		}
	}
	
	//Present a message helper method:
	func presentMessage(title: String, message: String, action: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
}
