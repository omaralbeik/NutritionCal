//
//  NDBConvenience.swift
//  FoodTracker
//
//  Created by Omar Albeik on 20/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation
import CoreData

extension NDBClient {
	
	class func requestNDBItemsFromString(searchString: String, type: NDBSearchType, completionHandler: (success: Bool, result: AnyObject?, errorString: String?) -> Void) {
		
		let escapedString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+")
		
		var searchType: String {
			switch type {
			case .ByFoodName:	return "n"
			case .ByRelevance:	return "r"
			}
		}
		
		let params: [String : AnyObject] = [
			NDBParameterKeys.format			: "json",
			NDBParameterKeys.searchTerm		: escapedString,
			NDBParameterKeys.sort			: searchType,
			NDBParameterKeys.limit			: NDBConstants.resultsLimit,
			NDBParameterKeys.offset			: 0,
			NDBParameterKeys.apiKey			: NDBConstants.apiKey
		]
		
		let urlString = NDBConstants.baseURL + NDBMethods.search + NDBClient.escapedParameters(params)
		
		let request = NSURLRequest(URL: NSURL(string: urlString)!)
		
		//		print(request.URL)
		
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				print("There was an error with your request: \(error!.localizedDescription)")
				completionHandler(success: false, result: nil, errorString: error?.localizedDescription)
				return
			}
			
			var parsedResults: AnyObject?
			
			parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
				
				/* GUARD: Was there an error? */
				guard (error == nil) else {
					print("Error parsing JSON: \(error!.localizedDescription)")
					completionHandler(success: false, result: nil, errorString: error?.localizedDescription)
					return
				}
				parsedResults = result
			})
			
			if let errors = parsedResults!.valueForKey("errors") {
				
				if let error = errors.valueForKey("error") {
					
					if let message = error.valueForKey("message") {
						
						let errorMessage = message.firstObject as! NSString
						completionHandler(success: false, result: nil, errorString: errorMessage as String)
						return
					}
				}
			}
			
			if let error = parsedResults!.valueForKey("error") {
				
				if let message = error.valueForKey("message") {
					
					let errorMessage = message as! NSString
					completionHandler(success: false, result: nil, errorString: errorMessage as String)
					return
				}
			}
			
			guard let list = parsedResults?.valueForKey("list") as? NSDictionary else {
				print("Couldn't find list in: \(parsedResults)")
				completionHandler(success: false, result: nil, errorString: "Couldn't find list in parsedResults")
				return
			}
			
			guard let items = list.valueForKey("item") as? NSArray else {
				print("Couldn't find item in: \(list)")
				completionHandler(success: false, result: nil, errorString: "Couldn't find item in list")
				return
			}
			completionHandler(success: true, result: items, errorString: nil)
		}
		task.resume()
	}
	
	
	class func NDBReportForItem(ndbNo: String, type: NDBReportType, completionHandler: (success: Bool, result: AnyObject?, errorString: String?) -> Void) {
		
		var reportType: String {
			switch type {
			case .Basic: return "b"
			case .Full:  return "f"
			}
		}
		
		let params: [String : AnyObject] = [
			NDBParameterKeys.format			: "json",
			NDBParameterKeys.NDBNo			: ndbNo,
			NDBParameterKeys.reportType		: reportType,
			NDBParameterKeys.apiKey			: NDBConstants.apiKey
		]
		
		let urlString = NDBConstants.baseURL + NDBMethods.reports + NDBClient.escapedParameters(params)
		
		let request = NSURLRequest(URL: NSURL(string: urlString)!)
		
//		print(request.URL)
		
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				print("There was an error with your request: \(error!.localizedDescription)")
				completionHandler(success: false, result: nil, errorString: error?.localizedDescription)
				return
			}
			
			var parsedResults: AnyObject?
			
			parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
				
				/* GUARD: Was there an error? */
				guard (error == nil) else {
					print("Error parsing JSON: \(error!.localizedDescription)")
					completionHandler(success: false, result: nil, errorString: error?.localizedDescription)
					return
				}
				parsedResults = result
			})
			
			if let errors = parsedResults?.valueForKey("errors") {
				
				if let error = errors.valueForKey("error") {
					
					if let message = error.valueForKey("message") {
						
						let errorMessage = message.firstObject as! NSString
						completionHandler(success: false, result: nil, errorString: errorMessage as String)
						return
					}
				}
				
				completionHandler(success: false, result: nil, errorString: nil)
			}
			
			if let error = parsedResults!.valueForKey("error") {
				
				if let message = error.valueForKey("message") {
					
					let errorMessage = message as! NSString
					completionHandler(success: false, result: nil, errorString: errorMessage as String)
					return
				}
			}
			
			guard let report = parsedResults!.valueForKey("report") as? NSDictionary else {
				print("Error finding report")
				completionHandler(success: false, result: nil, errorString: "Error finding report")
				return
			}
			
			guard let food = report.valueForKey("food") as? NSDictionary else {
				print("Error finding food")
				completionHandler(success: false, result: nil, errorString: "Error finding food")
				return
			}
			
			guard let nutrients = food.valueForKey("nutrients") as? NSArray else {
				print("Error finding nutrients")
				completionHandler(success: false, result: nil, errorString: "Error finding nutrients")
				return
			}
			
			completionHandler(success: true, result: nutrients, errorString: nil)
		}
		task.resume()
	}
	
}