//
//  NDBClient.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 11/26/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation
import CoreData

class NDBClient {
	
	// MARK: - Shared Instance
	class func sharedInstance() -> NDBClient {
		
		struct Singleton {
			static var sharedInstance = NDBClient()
		}
		
		return Singleton.sharedInstance
	}
	
	// shared NSURLSessionTask
	var sharedTask: NSURLSessionTask?
	
	struct NDBConstants {
		static let apiKey = "gXkPv1EdLTfdGajqGh87A8ywB6VBbsSoiuVgPEVX"
		static let baseURL = "http://api.nal.usda.gov/ndb/"
		static let resultsLimit = 50
	}
	
	struct NDBMethods {
		static let search = "search/"
		static let reports = "reports/"
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
	
	struct NDBParameterValues {
		static let json = "json"
	}
	
	enum NDBReportType {
		case Full
		case Basic
	}
	
	enum NDBSearchType {
		case ByFoodName
		case ByRelevance
	}
	
	//MARK: - Helper, cancel task
	func cancelTask() {
		if let task = sharedTask {
			task.cancel()
		}
	}
	
	//MARK: - Helper function: Given a dictionary of parameters, convert to a string for a url
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
	
	
	//MARK: - Helper: Given raw JSON, return a usable Foundation object
	class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		var parsingError: NSError? = nil
		
		let parsedResult: AnyObject?
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
		} catch let error as NSError {
			parsingError = error
			parsedResult = nil
		}
		
		if let error = parsingError {
			completionHandler(result: nil, error: error)
		} else {
			completionHandler(result: parsedResult, error: nil)
		}
	}

}