//
//  SettingsTableViewController.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
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
			
			if HKHealthStore.isHealthDataAvailable() {
				
				syncWithHealthKitSwitch.enabled = true
				
				if healthStoreSync == true {
					self.syncWithHealthKitSwitch.setOn(true, animated: false)
				}
				if healthStoreSync == false {
					self.syncWithHealthKitSwitch.setOn(false, animated: false)
				}
				
			} else {
				
				syncWithHealthKitSwitch.enabled = false
				
			}
			

		}
		
	}
	
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "replayTutorialSettingCell" {
			
			let tutorialVC = storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
			self.presentViewController(tutorialVC, animated: true, completion: nil)
		}
		
		
		if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "shareSettingsCell" {
			
			let textToShare = "I'm using Nutrition Cal, check it out!"
			
			if let websiteToShare = NSURL(string: "http://www.omaralbeik.com/nutrition-cal") {
				
				let imageToShare = UIImage(named: "nutritionCal")
				
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
		
		if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "moreAppsSettingsCell" {
			let url = NSURL(string: "https://itunes.apple.com/us/developer/omar-albeik/id898234691")!
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
