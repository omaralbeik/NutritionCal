//
//  USDA.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation

struct USDAConstants {
	
	static let apiKey = "gXkPv1EdLTfdGajqGh87A8ywB6VBbsSoiuVgPEVX"
	static let baseURL = "http://api.nal.usda.gov/ndb/search/"
	static let resultsLimit = 100
}

//http://api.nal.usda.gov/ndb/search/?format=json&q=butter&sort=n&max=25&offset=0&api_key=

class USDA {
	
	class func searchFoodForString(searchString: String, completionHandler: (success: Bool, result: [String]?, error: String?) -> Void) {
		
		let escapedString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+")
		
		let request = NSURLRequest(URL: NSURL(string: "\(USDAConstants.baseURL)?format=json&q=\(escapedString)&sort=r&max=\(USDAConstants.resultsLimit)&offset=0&api_key=\(USDAConstants.apiKey)")!)
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				print("There was an error with your request: \(error!.localizedDescription)")
				completionHandler(success: false, result: nil, error: error?.localizedDescription)
				return
			}
			
			parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
				
				guard (error == nil) else {
					print("There was an error with your request: \(error!.localizedDescription)")
					completionHandler(success: false, result: nil, error: error?.localizedDescription)
					return
				}
				
				guard let list = result.valueForKey("list") as? NSDictionary else {
					if let err = result.valueForKey("error") as? NSDictionary {
						if let errorCode = err.valueForKey("code") as? String {
							if errorCode == "OVER_RATE_LIMIT" {
								print("Server busy, please try again later")
								completionHandler(success: false, result: nil, error: "Server busy, please try again later")
								return
							}
						}
					} else {
						completionHandler(success: false, result: nil, error: error?.localizedDescription)
						return
					}
					return
				}
				
				guard let items = list.valueForKey("item") as? NSArray else {
					print("Couldn't find item in: \(list)")
					completionHandler(success: false, result: nil, error: error?.localizedDescription)
					return
				}
				
				var searchItems: [String] = []
				
				for item in items {
					
					if let name = item.valueForKey("name") as? String {
						searchItems.append(name)
					}
					
					completionHandler(success: true, result: searchItems, error: nil)
				}
				
			})
			
		}
		task.resume()
	}
	
	/* Helper: Given raw JSON, return a usable Foundation object */
	class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		
		var parsedResult: AnyObject!
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		} catch {
			let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
			completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
		}
		
		completionHandler(result: parsedResult, error: nil)
	}
	
}


//class Nutrionix {
//
//	class func searchForFood(searchString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
//
//		let request = NSMutableURLRequest(URL: NSURL(string: NutrionixConstants.baseURL)!)
//		let session = NSURLSession.sharedSession()
//		request.HTTPMethod = "POST"
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//		let params = [
//			"appId" : NutrionixConstants.AppId,
//			"appKey" : NutrionixConstants.AppKey,
//			"fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
//			"limit"  : "\(NutrionixConstants.searchLimit)",
//			"query"  : searchString,
//			"filters": ["exists":["usda_fields": true]]]
//
//		do {
//			request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
//		}
//
//		/* Make the request */
//		let task = session.dataTaskWithRequest(request) { (data, response, error) in
//
//			/* GUARD: Was there an error? */
//			guard (error == nil) else {
//				print("There was an error with your request: \(error?.localizedDescription)")
//				return
//			}
//
//			/* GUARD: Did we get a successful 2XX response? */
//			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
//				if let response = response as? NSHTTPURLResponse {
//					print("Your request returned an invalid response! Status code: \(response.statusCode)!")
//				} else if let response = response {
//					print("Your request returned an invalid response! Response: \(response)!")
//				} else {
//					print("Your request returned an invalid response!")
//				}
//				return
//			}
//
//			/* GUARD: Was there any data returned? */
//			guard let data = data else {
//				print("No data was returned by the request!")
//				return
//			}
//
//			/* Parse the data and use the data (happens in completion handler) */
//
//			parseJSONWithCompletionHandler(data, completionHandler: { (result, error) -> Void in
//
//				guard (error == nil) else {
//					print("There was an error with your request: \(error!.localizedDescription)")
//					return
//				}
//
//				guard let hits = result.valueForKey("hits") as? NSArray else {
//					print("Couldn't find hits in: \(result)")
//					return
//				}
//
//				for item in hits {
//
//					guard let fields = item.valueForKey("fields") as? NSDictionary else {
//						print("Couldn't find fields in: \(item)")
//						return
//					}
//
//					guard let itemName = fields.valueForKey("item_name") as? String else {
//						print("Couldn't find item name in: \(fields)")
//						return
//					}
//
//					print(itemName)
//
//				}
//
//			})
//		}
//
//		/* Start the request */
//		task.resume()
//}
//