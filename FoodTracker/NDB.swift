//
//  NDB.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.

import Foundation
import CoreData

struct NDBConstants {
	
	static let apiKey = "gXkPv1EdLTfdGajqGh87A8ywB6VBbsSoiuVgPEVX"
	static let baseURL = "http://api.nal.usda.gov/ndb/"
	static let resultsLimit = 50
}

struct NDBMethods {
	static let search = "search"
	static let reports = "reports"
}

enum NDBReportType {
	case Full
	case Stats
	case Basic
	
}

enum NDBSearchType {
	case ByFoodName
	case ByRelevance
}

// Shared Context from CoreDataStackManager
var sharedContext: NSManagedObjectContext {
	return CoreDataStackManager.sharedInstance().managedObjectContext
}

class NDB {
	
	class func requestNDBItemsFromString(searchString: String, type: NDBSearchType, completionHandler: (success: Bool, items: AnyObject?, errorString: String?) -> Void) {
		
		let escapedString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+")
		
		var searchType: String {
			switch type {
			case .ByFoodName:
				return "n"
			case .ByRelevance:
				return "r"
			}
		}
		
		let request = NSURLRequest(URL: NSURL(string: "\(NDBConstants.baseURL)\(NDBMethods.search)/?format=json&q=\(escapedString)&sort=\(searchType)&max=\(NDBConstants.resultsLimit)&offset=0&api_key=\(NDBConstants.apiKey)")!)
		
//		print(request.URL)
		
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				print("There was an error with your request: \(error!.localizedDescription)")
				completionHandler(success: false, items: nil, errorString: error?.localizedDescription)
				return
			}
			
			var parsedResults: AnyObject?
			
			parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
				
				/* GUARD: Was there an error? */
				guard (error == nil) else {
					print("Error parsing JSON: \(error!.localizedDescription)")
					completionHandler(success: false, items: nil, errorString: error?.localizedDescription)
					return
				}
				parsedResults = result
			})
			
			
			if let errors = parsedResults!.valueForKey("errors") {
				
				if let error = errors.valueForKey("error") {
					
					if let message = error.valueForKey("message") {
						
						let errorMessage = message.firstObject as! NSString
						completionHandler(success: false, items: nil, errorString: errorMessage as String)
						return
					}
				}
				
				completionHandler(success: false, items: nil, errorString: nil)
			}
			
			guard let list = parsedResults?.valueForKey("list") as? NSDictionary else {
				print("Couldn't find list in: \(parsedResults)")
				completionHandler(success: false, items: nil, errorString: "Couldn't find list in parsedResults")
				return
			}
			
			guard let items = list.valueForKey("item") as? NSArray else {
				print("Couldn't find item in: \(list)")
				completionHandler(success: false, items: nil, errorString: "Couldn't find item in list")
				return
			}
			
			completionHandler(success: true, items: items, errorString: nil)
			
//			var ndbItems: [NDBItem] = []
//			
//			for item in items {
//				let ndbItem = NDBItem(dictionary: item as! [String : AnyObject], context: sharedContext)
//				ndbItems.append(ndbItem)
//			}
//			
//			completionHandler(success: true, items: ndbItems, errorString: nil)
			
		}
		task.resume()
	}
	
	
	class func NDBReportForItem(ndbNo: String, type: NDBReportType, completionHandler: (success: Bool, result: AnyObject?, error: String?) -> Void) {
		
		var reportType: String {
			switch type {
			case .Basic: return "b"
			case .Full:  return "f"
			case .Stats: return "s"
			}
		}
		
		let request = NSURLRequest(URL: NSURL(string: "\(NDBConstants.baseURL)\(NDBMethods.reports)/?ndbno=\(ndbNo)&type=\(reportType)&format=json&api_key=\(NDBConstants.apiKey)")!)
		
		print(request.URL)
		
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				print("There was an error with your request: \(error!.localizedDescription)")
				completionHandler(success: false, result: nil, error: error?.localizedDescription)
				return
			}
			
			var parsedResults: AnyObject?
			
			parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
				
				/* GUARD: Was there an error? */
				guard (error == nil) else {
					print("Error parsing JSON: \(error!.localizedDescription)")
					completionHandler(success: false, result: nil, error: error?.localizedDescription)
					return
				}
				parsedResults = result
			})
			
			completionHandler(success: true, result: parsedResults!, error: nil)
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