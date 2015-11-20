//
//  FoodDetailsViewController.swift
//  FoodTracker
//
//  Created by Omar Albeik on 19/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import PNChart
import MaterialDesignColor

class FoodDetailsViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var chartView: UIView!

	var ndbItem: NDBItem!
	
	var calcium : Double = 0
	var carbohydrate : Double = 0
	var cholesterol : Double = 0
	var energy : Double = 0
	var fatTotal : Double = 0
	var protein : Double = 0
	var sugar : Double = 0
	var vitaminC : Double = 0
	
	var xLabels = ["Ca", "CHO", "Chol", "KCal", "Fat", "Prot", "Sugar", "Vit C"]
	
	var barChart = PNBarChart()
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		barChart = PNBarChart(frame: self.chartView.frame)
		
		barChart.xLabels = xLabels
		barChart.yValues = [calcium,carbohydrate,cholesterol,energy,fatTotal,protein,sugar,vitaminC]
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
		nameLabel.text = ndbItem.name!

		
		let nutrients = ndbItem.nutrients
		
		for nutrient in nutrients! {
			if nutrient.id == 301 {
				calcium = nutrient.value as! Double
			}
			if nutrient.id == 205 {
				carbohydrate = nutrient.value as! Double
			}
			if nutrient.id == 601 {
				cholesterol = nutrient.value as! Double
			}
			if nutrient.id == 208 {
				energy = nutrient.value as! Double
			}
			if nutrient.id == 204 {
				fatTotal = nutrient.value as! Double
			}
			if nutrient.id == 203 {
				protein = nutrient.value as! Double
			}
			if nutrient.id == 269 {
				sugar = nutrient.value as! Double
			}
			if nutrient.id == 401 {
				vitaminC = nutrient.value as! Double
			}
		}
	}

	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
		
	}
	
}
