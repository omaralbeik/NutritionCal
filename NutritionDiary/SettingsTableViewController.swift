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
