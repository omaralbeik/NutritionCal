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
	
	var foodName: String!
	var foodNDBNo : String!
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let barChart = PNBarChart(frame: self.chartView.frame)
		
		barChart.xLabels = ["Ca", "CHO", "Chol", "KCal", "Fat", "Prot", "Sugar", "Vit C"]
		barChart.yValues = [3.86,5,1,4,5.43,5,3,2]
		barChart.isShowNumbers = false
		barChart.isGradientShow = false
		
		barChart.legendFontColor = UIColor.orangeColor()
		barChart.labelTextColor = UIColor.orangeColor()
		
		barChart.barWidth = 25
		
		barChart.strokeColors = [
			MaterialDesignColor.red500,
			MaterialDesignColor.lightGreen500,
			MaterialDesignColor.grey800,
			MaterialDesignColor.brown500,
			MaterialDesignColor.teal500,
			MaterialDesignColor.deepPurple500,
			MaterialDesignColor.pink500,
			MaterialDesignColor.deepOrange500
		]
		
		barChart.barBackgroundColor = MaterialDesignColor.grey100
		
		barChart.strokeChart()
		
		view.addSubview(barChart)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		nameLabel.text = foodName
	}
	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
		
	}
	
}
