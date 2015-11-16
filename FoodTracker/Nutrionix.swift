//
//  Nutrionix.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation

struct NutrionixConstants {
	
	static let AppId = "dde6ae21"
	static let AppKey = "6da5a785dc8ed987fea671c27caea5e0"
	static let baseURL = "https://api.nutritionix.com/v1_1/search/"
	static let searchLimit = 50
}

class Nutrionix {
	
	class func searchForFood(searchString: String) {
		
		let request = NSMutableURLRequest(URL: NSURL(string: NutrionixConstants.baseURL)!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
		let params = [
			"appId" : NutrionixConstants.AppId,
			"appKey" : NutrionixConstants.AppKey,
			"fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
			"limit"  : "\(NutrionixConstants.searchLimit)",
			"query"  : searchString,
			"filters": ["exists":["usda_fields": true]]]

		do {
			try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
		}
		catch {
			print("Error getting foods for: \(searchString)")
		}
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
			let stringData = NSString(data: data!, encoding: NSUTF8StringEncoding)
			print(stringData)
		})
		task.resume()
	}
}