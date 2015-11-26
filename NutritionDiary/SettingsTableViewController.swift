//
//  SettingsTableViewController.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 22/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import HealthKit
import MaterialDesignColor

class SettingsTableViewController: UITableViewController {
	
	@IBOutlet weak var syncWithHealthKitSwitch: UISwitch!
	
	let healthStore = HealthStore.sharedInstance()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.syncWithHealthKitSwitch.setOn(false, animated: false)
		
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		
		// UI customizations
		tabBarController?.tabBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.tintColor = MaterialDesignColor.green500
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MaterialDesignColor.green500]
		
		if let healthStoreSync = NSUserDefaults.standardUserDefaults().valueForKey("healthStoreSync") as? Bool {
			
			if healthStoreSync == true {
				self.syncWithHealthKitSwitch.setOn(true, animated: false)
			}
			if healthStoreSync == false {
				self.syncWithHealthKitSwitch.setOn(false, animated: false)
			}
		}
		
	}
	
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "shareSettingsCell" {
			print("should share")
			
			let textToShare = "I'm using Nutrition Diary, check it out!"
			
			if let websiteToShare = NSURL(string: "http://www.nutritiondiary.com") {
				
				let imageToShare = UIImage(named: "nutritionDiary")
				
				let shareVC = UIActivityViewController(activityItems: [textToShare, websiteToShare, imageToShare!], applicationActivities: nil)
				
				shareVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard]
				
				shareVC.view.tintColor = MaterialDesignColor.green500
				
				self.presentViewController(shareVC, animated: true, completion: nil)
				
			}

		}
		
		if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "rateSettingsCell" {
			let url = NSURL(string: "https://itunes.apple.com/us/app/nutrition-cal/id1062592953?ls=1&mt=8")!
			UIApplication.sharedApplication().openURL(url)
		}
 	}
	
	
	@IBAction func syncWithHealthKitSwitchChanged(sender: UISwitch) {
		
		//TODO: - handle if user didn't authorise use of Helth Kit
		
		if sender.on {
			print("Sync On")
			NSUserDefaults.standardUserDefaults().setObject(true, forKey: "healthStoreSync")
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			print("Sync Off")
			NSUserDefaults.standardUserDefaults().setObject(false, forKey: "healthStoreSync")
			NSUserDefaults.standardUserDefaults().synchronize()
		}
		
	}
	
	
	
	
	
}
