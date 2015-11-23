//
//  ItemDetailsViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 23/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit

class ItemDetailsViewController: UIViewController {
	
	var ndbItem: NDBItem!
	
	@IBOutlet weak var itemNameLabel: UILabel!
	@IBOutlet weak var chartView: UIView!
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		itemNameLabel.text = ndbItem.name

    }
	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
	}
	
}
