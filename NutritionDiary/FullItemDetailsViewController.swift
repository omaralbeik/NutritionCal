//
//  FullItemDetailsViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 23/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit

class FullItemDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var ndbItem: NDBItem!
	
	@IBOutlet weak var tableView: UITableView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self

    }
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FullItemDetailsViewControllerTableViewCell")!
		
		let nutritions = ndbItem.nutrients
		cell.textLabel?.text = nutritions![indexPath.row].name
		
		let value = nutritions![indexPath.row].value! as Double
		let roundedValue = Double(round(1000*value)/1000)
		
		let valueText = "\(roundedValue) " + nutritions![indexPath.row].unit!
		cell.detailTextLabel?.text = valueText
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ndbItem.nutrients!.count
	}
	
	
	
	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
	}

}
