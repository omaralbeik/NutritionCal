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

class ItemDetailsViewController: UIViewController, PNChartDelegate {
	
	var ndbItem: NDBItem!
	
	var calcium : Double = 0
	var carbohydrate : Double = 0
	var cholesterol : Double = 0
	var energy : Double = 0
	var fatTotal : Double = 0
	var protein : Double = 0
	var sugar : Double = 0
	var vitaminC : Double = 0
	
	var calciumUnit = "Ca"
	var carbohydrateUnit = "CHO"
	var cholesterolUnit = "Chol"
	var energyUnit = "Enrg"
	var fatTotalUnit = "Fat"
	var proteinUnit = "Prot"
	var sugarUnit = "Sugar"
	var vitaminCUnit = "Vit C"
	
	var loadingIndicator: NVActivityIndicatorView!
	
	@IBOutlet weak var itemNameLabel: UILabel!
	@IBOutlet weak var chartView: UIView!
	
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		loadingIndicator.stopAnimation()
		
		let barChart = PNBarChart(frame: self.chartView.frame)
		
		barChart.xLabels = [calciumUnit,carbohydrateUnit,cholesterolUnit,energyUnit,fatTotalUnit,proteinUnit,sugarUnit,vitaminCUnit]
		barChart.yValues = [calcium,carbohydrate,cholesterol,energy,fatTotal,protein,sugar,vitaminC]
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
		
		barChart.legendFontColor = UIColor.blackColor()
		barChart.labelTextColor = UIColor.blackColor()
		
		barChart.barBackgroundColor = MaterialDesignColor.grey300
		barChart.barWidth = 25
		
		barChart.isShowNumbers = true
		
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
				calciumUnit += "\n[\(nutrient.unit!)]"
			}
			if nutrient.id == 205 {
				carbohydrate = nutrient.value as! Double
				carbohydrateUnit += "\n[\(nutrient.unit!)]"
				
			}
			if nutrient.id == 601 {
				cholesterol = nutrient.value as! Double
				cholesterolUnit += "\n[\(nutrient.unit!)]"
			}
			if nutrient.id == 208 {
				energy = nutrient.value as! Double
				energyUnit += "\n[\(nutrient.unit!)]"
				
				for measure in nutrient.measures! {
					print(measure.label)
				}
				
			}
			if nutrient.id == 204 {
				fatTotal = nutrient.value as! Double
				fatTotalUnit += "\n[\(nutrient.unit!)]"
			}
			if nutrient.id == 203 {
				protein = nutrient.value as! Double
				proteinUnit += "\n[\(nutrient.unit!)]"
			}
			if nutrient.id == 269 {
				sugar = nutrient.value as! Double
				sugarUnit += "\n[\(nutrient.unit!)]"
			}
			if nutrient.id == 401 {
				vitaminC = nutrient.value as! Double
				vitaminCUnit += "\n[\(nutrient.unit!)]"
			}
		}
		
		
	}
	
	@IBAction func fullInfoButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("toFullItemDetailsViewControllerSegue", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "toFullItemDetailsViewControllerSegue" {
			
			let fullDetailsVC = segue.destinationViewController as! FullItemDetailsViewController
			fullDetailsVC.ndbItem = self.ndbItem
			
		}
	}
	
	
	@IBAction func eatItBarButtonItemTapped(sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: "Select Size:", message: "\(ndbItem.name!) has many sizes, Please choose one to eat:", preferredStyle: .ActionSheet)
		
		let nutrients = ndbItem.nutrients
		
		for nutrient in nutrients! {
			
			if nutrient.id == 208 {
				
				for measure in nutrient.measures! {
					let action = UIAlertAction(title: measure.label!, style: .Default, handler: { (action) -> Void in
						print("Should eat: \(measure.label!)")
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
	
}
