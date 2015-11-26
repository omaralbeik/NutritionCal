//
//  TutorialContentViewController.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit
import HealthKit

class TutorialContentViewController: UIViewController {
	
	var image: UIImage!
	var titleText: String!
	var index :Int!
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var letsGoButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let healthStore = HealthStore.sharedInstance()
		
		imageView.image = self.image
		titleLabel.text = titleText
		
		
		if index == 6 {
			healthStore.requestAuthorizationForHealthStore()
			letsGoButton.hidden = false
		}
	}
	
	@IBAction func letsGoButtonTapped(sender: UIButton) {
		
		let mainTabBar = storyboard?.instantiateViewControllerWithIdentifier("mainTabBar") as! UITabBarController
		presentViewController(mainTabBar, animated: true, completion: nil)
		
	}
	
}
