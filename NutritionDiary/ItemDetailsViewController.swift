//
//  ItemDetailsViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 23/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView
import PNChart
import MaterialDesignColor

class ItemDetailsViewController: UIViewController {
	
	var ndbItem: NDBItem!
	
	var calcium : Double = 0
	var carbohydrate : Double = 0
	var cholesterol : Double = 0
	var energy : Double = 0
	var fatTotal : Double = 0
	var protein : Double = 0
	var sugar : Double = 0
	var vitaminC : Double = 0
	
	var loadingIndicator: NVActivityIndicatorView!
	
	@IBOutlet weak var itemNameLabel: UILabel!
	@IBOutlet weak var chartView: UIView!
	
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		loadingIndicator.stopAnimation()
		
		let barChart = PNBarChart(frame: self.chartView.frame)
		
		barChart.xLabels = ["Ca", "CHO", "Chol", "KCal", "Fat", "Prot", "Sugar", "Vit C"]
		barChart.yValues = [calcium,carbohydrate,cholesterol,energy,fatTotal,protein,sugar,vitaminC]
		barChart.isShowNumbers = false
		barChart.isGradientShow = false
		
		barChart.legendFontColor = UIColor.orangeColor()
		barChart.labelTextColor = UIColor.orangeColor()
		
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
		barChart.barWidth = 22
		
		barChart.strokeChart()
		
		view.addSubview(barChart)
		
		
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		itemNameLabel.text = ndbItem.name
		
		// initilizing the loadingIndicator
		let frame = CGRect(x: CGRectGetMidX(view.frame)-20, y: CGRectGetMidY(view.frame)-20, width: 40, height: 40)
		loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallBeat, color: MaterialDesignColor.green500)
		loadingIndicator.startAnimation()
		
		view.addSubview(loadingIndicator)
		
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
