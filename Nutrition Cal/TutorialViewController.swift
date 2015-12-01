//
//  TutorialViewController.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	var pageViewController: UIPageViewController!
	var pageTitles: [String]!
	var pageImages: [UIImage]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		pageTitles = [
			"Search for foods and drinks you ate.",
			"Swipe to add an eaten item, or save it in Favorites.",
			"See All your favorite foods in one place.",
			"See major nutritions in chart, or dive in and find All.",
			"Allow Health Access to sync with Apple Health App.",
			"Keep track of what you ate in History tab.",
			""
		]
		
		pageImages = [
			UIImage(named: "tutorial_1")!,
			UIImage(named: "tutorial_2")!,
			UIImage(named: "tutorial_3")!,
			UIImage(named: "tutorial_4")!,
			UIImage(named: "tutorial_6")!,
			UIImage(named: "tutorial_5")!,
			UIImage(named: "tutorial_7")!
		]
		
		self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialPageViewController") as! UIPageViewController
		self.pageViewController.dataSource = self
		self.pageViewController.delegate = self
		
		let initialContentVC = contentControllerForIndex(0)
		let viewControllers = NSArray(object: initialContentVC)
		
		self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
		
		self.pageViewController.view.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 50)
		self.addChildViewController(self.pageViewController)
		self.view.addSubview(self.pageViewController.view)
		self.pageViewController.didMoveToParentViewController(self)
		
	}
	
	// set status bar color to white
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	// UIPageViewController Data Source
	func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
		return pageTitles.count
	}
	func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
		return 0
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		let vc = viewController as! TutorialContentViewController
		
		var index = vc.index as Int
		
		if (index == 0 || index == NSNotFound) {
			return nil
		}
		
		index--
		return self.contentControllerForIndex(index)
		
	}
	
	func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
		let vc = pendingViewControllers.first as! TutorialContentViewController
		
		UIView.animateWithDuration(0.3) { () -> Void in
			vc.imageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
		}
		
	}
	
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		
		let vc = previousViewControllers.first as! TutorialContentViewController
		vc.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9)
	}
	
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		
		let vc = viewController as! TutorialContentViewController
		var index = vc.index as Int
		
		if (index == NSNotFound) {
			return nil
		}
		
		index++
		
		if (index == self.pageImages.count)
		{
			return nil
		}
		
		return self.contentControllerForIndex(index)
	}
	
	// Helper to return tutorial page for an index
	func contentControllerForIndex(index: Int) -> TutorialContentViewController {
		
		if (self.pageTitles.count == 0 || index >= self.pageTitles.count) {
			return TutorialContentViewController()
		}
		
		let contentVC = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialContentViewController") as! TutorialContentViewController
		
		contentVC.image = pageImages[index]
		contentVC.titleText = pageTitles[index]
		contentVC.index = index
		
		return contentVC
	}
	
	@IBAction func xButtonTapped(sender: UIButton) {
		
		let mainTabBar = storyboard?.instantiateViewControllerWithIdentifier("mainTabBar") as! UITabBarController
		presentViewController(mainTabBar, animated: true, completion: nil)
		HealthStore.sharedInstance().requestAuthorizationForHealthStore()
	}
	
}
