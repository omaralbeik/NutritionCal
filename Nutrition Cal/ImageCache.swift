//
//  ImageCache.swift
//  Nutrition Cal
//
//  Created by Omar Albeik on 12/1/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

// Source code from FavoriteActors App by Jason on 1/31/15. Copyright (c) 2015 Udacity. All rights reserved.


import UIKit

class ImageCache {
	
	class func sharedInstance() -> ImageCache {
		struct Singleton {
			static var sharedInstance = ImageCache()
		}
		return Singleton.sharedInstance
	}
	
	// MARK: - Shared Image Cache
	struct Caches {
		static let imageCache = ImageCache()
	}
	
	private var inMemoryCache = NSCache()
	
	// MARK: - Retreiving images
	
	func imageWithIdentifier(identifier: String?) -> UIImage? {
		
		// If the identifier is nil, or empty, return nil
		if identifier == nil || identifier! == "" {
			return nil
		}
		
		let path = pathForIdentifier(identifier!)
		
		// First try the memory cache
		if let image = inMemoryCache.objectForKey(path) as? UIImage {
			return image
		}
		
		// Next Try the hard drive
		if let data = NSData(contentsOfFile: path) {
			return UIImage(data: data)
		}
		
		return nil
	}
	
	// MARK: - Saving images
	
	func storeImage(image: UIImage?, withIdentifier identifier: String) {
		let path = pathForIdentifier(identifier)
		
		// If the image is nil, remove images from the cache
		if image == nil {
			inMemoryCache.removeObjectForKey(path)
			
			do {
				try NSFileManager.defaultManager().removeItemAtPath(path)
			} catch {}
			
			return
		}
		
		// Otherwise, keep the image in memory
		inMemoryCache.setObject(image!, forKey: path)
		
		// And in documents directory
		let data = UIImagePNGRepresentation(image!)!
		data.writeToFile(path, atomically: true)
	}
	
	// MARK: - Deleting an image
	func deleteImageWithIdentifier(identifier: String) {
		
		let fileManager = NSFileManager.defaultManager()
		let path = pathForIdentifier(identifier)
		
		if fileManager.fileExistsAtPath(path) {
			do {
				try fileManager.removeItemAtPath(path)
				print("\(identifier) image deleted")
			}
			catch {
				print("\(identifier) couldn't be deleted")
			}
		}
	}
	
	
	// MARK: - Helper
	
	func pathForIdentifier(identifier: String) -> String {
		let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
		
		return fullURL.path!
	}
}
