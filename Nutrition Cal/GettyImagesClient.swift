//
//  GettyImagesClient.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 12/2/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import UIKit


// ttps://api.gettyimages.com:443/v3/ search/ images? exclude_nudity=true  & file_types=jpg%2Cpng &number_of_people=none & phrase=Baked%20Products& sort_order=best_match


class GettyImagesClient {
	
	// MARK: - Shared Instance
	class func sharedInstance() -> GettyImagesClient {
		
		struct Singleton {
			static var sharedInstance = GettyImagesClient()
		}
		
		return Singleton.sharedInstance
	}
	
	// shared NSURLSessionTask
	var sharedTask: NSURLSessionTask?
	
	struct GettyImagesConstants {
		static let apiKey = "ef8cu9rcewzngh2aknfw2qvm"
		static let Secret = "kuv3uHfz3BPxGKY6yBXzwMNDeWUt5fzBja2TnQnDmvSR9"
		static let baseURL = "https://api.gettyimages.com:443/v3/"
	}
	
	struct GettyImagesMethods {
		static let search = "search/images"
	}
	
	struct GettyImagesParameterKeys {
		static let apiKey = "Api-Key"
		static let excludeNudity = "exclude_nudity"
		static let fileTypes = "file_types"
		static let numberOfPeople = "number_of_people"
		static let phrase = "phrase"
		static let sortOrder = "sort_order"
		
	}
	
	struct GettyImagesParameterValues {
		static let yes = "true"
		static let no = "false"
		static let none = "none"
		static let bestMatch = "best_match"
		static let allowedFileTypes = "jpg%2Cpng"
	}
	
	
	func imageFromString(searchString: String, completionHandler: (success: Bool, image: UIImage?, errorString: String?) -> Void) {
		
		let escapedSearchString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!.lowercaseString
		
		
		// ttps://api.gettyimages.com:443/v3/ search/ images? exclude_nudity=true  & file_types=jpg%2Cpng &number_of_people=none & phrase=Baked%20Products& sort_order=best_match
	
		let params: [String: AnyObject] = [
			GettyImagesParameterKeys.apiKey				:	GettyImagesConstants.apiKey,
			GettyImagesParameterKeys.excludeNudity		:	GettyImagesParameterValues.yes,
			GettyImagesParameterKeys.fileTypes			:	GettyImagesParameterValues.allowedFileTypes,
			GettyImagesParameterKeys.numberOfPeople		:	GettyImagesParameterValues.none,
			GettyImagesParameterKeys.sortOrder			:	GettyImagesParameterValues.bestMatch,
			GettyImagesParameterKeys.phrase				:	escapedSearchString
			
		]
		
		
		let urlString = GettyImagesConstants.baseURL + GettyImagesMethods.search + NDBClient.escapedParameters(params)
		
		let request = NSURLRequest(URL: NSURL(string: urlString)!)
		
		print(request.URL!)
		
		let session = NSURLSession.sharedSession()
		
//		
//		sharedTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//			
//			/* GUARD: Was there an error? */
//			guard (error == nil) else {
//				print("There was an error with your request: \(error!.localizedDescription)")
//				completionHandler(success: false, result: nil, errorString: error?.localizedDescription)
//				return
//			}
//			
//			var parsedResults: AnyObject?
//			
//			NDBClient.parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) -> Void in
//				
//				/* GUARD: Was there an error? */
//				guard (error == nil) else {
//					print("Error parsing JSON: \(error!.localizedDescription)")
//					completionHandler(success: false, result: nil, errorString: error?.localizedDescription)
//					return
//				}
//				parsedResults = result
//			})
//			
//			if let errors = parsedResults?.valueForKey("errors") {
//				
//				if let error = errors.valueForKey("error") {
//					
//					if let message = error.valueForKey("message") {
//						
//						let errorMessage = message.firstObject as! NSString
//						completionHandler(success: false, result: nil, errorString: errorMessage as String)
//						return
//					}
//				}
//			}
//			
//			if let error = parsedResults!.valueForKey("error") {
//				
//				if let message = error.valueForKey("message") {
//					
//					let errorMessage = message as! NSString
//					completionHandler(success: false, result: nil, errorString: errorMessage as String)
//					return
//				}
//			}
//			
//			guard let list = parsedResults?.valueForKey("list") as? [String: AnyObject] else {
//				print("Couldn't find list in: \(parsedResults)")
//				completionHandler(success: false, result: nil, errorString: "Couldn't find list in parsedResults")
//				return
//			}
//			
//			guard let items = list["item"] as? NSArray else {
//				print("Couldn't find item in: \(list)")
//				completionHandler(success: false, result: nil, errorString: "Couldn't find item in list")
//				return
//			}
//			completionHandler(success: true, result: items, errorString: nil)
//		}
//		sharedTask!.resume()
//		
	}
	
}