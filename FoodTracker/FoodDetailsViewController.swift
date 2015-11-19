//
//  FoodDetailsViewController.swift
//  FoodTracker
//
//  Created by Omar Albeik on 19/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import PNChart
import MaterialDesignColor

class FoodDetailsViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var chartView: UIView!
	
	var ndbItem: NDBItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300)
		let barChart = PNBarChart(frame: frame)
		
		barChart.xLabels = ["Calcium", "Carbohydrate", "Cholesterol", "Energy", "Fat", "Protein", "Sugar", "Vitamin C"]
//		barChart.xLabels = ["Ca", "Chb", "Chr", "Eng", "Fat", "Pro", "Su", "ViC"]
		barChart.yValues = [1,5,1,4,7,5,3,2]
		barChart.showLabel = true
		barChart.barWidth = 20
		barChart.labelTextColor = UIColor.whiteColor()
//		barChart.strokeColors = [
//			MaterialDesignColor.red500,
//			MaterialDesignColor.lightGreen500,
//			MaterialDesignColor.deepOrange500,
//			MaterialDesignColor.brown500,
//			MaterialDesignColor.teal500,
//			MaterialDesignColor.deepPurple500,
//			MaterialDesignColor.pink500,
//			MaterialDesignColor.grey800
//		]
		
		
		barChart.barBackgroundColor = MaterialDesignColor.grey100
		
		barChart.strokeChart()
		
		chartView.addSubview(barChart)
		
    }
	
	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
		
	}

}
