//
//  NDBClient.swift
//  FoodTracker
//
//  Created by Omar Albeik on 16/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.

import Foundation
import CoreData

class NDBClient {
	
	struct NDBConstants {
		static let apiKey = "gXkPv1EdLTfdGajqGh87A8ywB6VBbsSoiuVgPEVX"
		static let baseURL = "http://api.nal.usda.gov/ndb/"
		static let resultsLimit = 50
	}
	
	struct NDBMethods {
		static let search = "search"
		static let reports = "reports"
	}
	
	struct NDBParameterKeys {
		static let format = "format"
		static let searchTerm = "q"
		static let sort = "sort"
		static let limit = "max"
		static let offset = "offset"
		static let apiKey = "api_key"
		static let NDBNo = "ndbno"
		static let reportType = "type"
	}
	
	enum NDBReportType {
		case Full
		case Basic
	}
	
	enum NDBSearchType {
		case ByFoodName
		case ByRelevance
	}
	
	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	class func escapedParameters(parameters: [String : AnyObject]) -> String {
		
		var urlVars = [String]()
		
		for (key, value) in parameters {
			
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			
			/* Append it */
			urlVars += [key + "=" + "\(escapedValue!)"]
			
		}
		
		return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
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