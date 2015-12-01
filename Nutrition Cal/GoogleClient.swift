//
//  GoogleClient.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 12/1/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit

// http://stackoverflow.com/questions/4868815/google-ajax-api-how-do-i-get-more-than-4-results
// http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=searchString

class GoogleClient {
	
	// MARK: - Shared Instance
	class func sharedInstance() -> GoogleClient {
		
		struct Singleton {
			static var sharedInstance = GoogleClient()
		}
		return Singleton.sharedInstance
	}
	
	// shared NSURLSessionTask
	var sharedTask: NSURLSessionTask?
	
	func getImageFromString(searchString: String, completionHandler: (success: Bool, image: UIImage?, errorString: String?) -> Void) {
		
		let escapedSearchString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!.lowercaseString
		
		let urlString = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=" + escapedSearchString + "stock+food"
		let url = NSURL(string: urlString)!
		
		print(url)
		
		let session = NSURLSession.sharedSession()
		
		sharedTask = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				print("There was an error with your request: \(error!.localizedDescription)")
				completionHandler(success: false, image: nil, errorString: error?.localizedDescription)
				return
			}
			
			var parsedResults: AnyObject?
			NDBClient.parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
				
				/* GUARD: Was there an error? */
				guard (error == nil) else {
					print("Error parsing JSON: \(error!.localizedDescription)")
					completionHandler(success: false, image: nil, errorString: error?.localizedDescription)
					return
				}
				parsedResults = result
			})
			
			guard let responseData = parsedResults!.valueForKey("responseData") as? [String: AnyObject] else {
				print("Error finding report")
				completionHandler(success: false, image: nil, errorString: "Error finding responseData")
				return
			}
			
			guard let results = responseData["results"] as? [[String: AnyObject]] else {
				print("Error finding results")
				completionHandler(success: false, image: nil, errorString: "Error finding results")
				return
			}
			
			guard results.count > 0 else {
				print("No images found")
				completionHandler(success: false, image: nil, errorString: "No images found")
				return
			}
			
			guard let imageURLString = results.first!["url"] as? String else {
				print("Error finding imageURLString")
				completionHandler(success: false, image: nil, errorString: "Error finding imageURLString")
				return
			}
			
			guard let imageURL = NSURL(string: imageURLString) else {
				print("Error getting URL from imageURLString")
				completionHandler(success: false, image: nil, errorString: "Error getting URL from imageURLString")
				return
			}
			
			guard let imageData = NSData(contentsOfURL: imageURL) else {
				print("Error getting data from imageURL")
				completionHandler(success: false, image: nil, errorString: "Error getting data from imageURL")
				return
			}
			
			guard let imageFromData = UIImage(data: imageData) else {
				print("Error getting image from imageData")
				completionHandler(success: false, image: nil, errorString: "Error getting image from imageData")
				return
			}
			
			completionHandler(success: true, image: imageFromData, errorString: nil)
			
		})
		sharedTask?.resume()
	}
}