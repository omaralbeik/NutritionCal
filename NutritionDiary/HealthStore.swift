//
//  HealthStore.swift
//  NutritionDiary
//
//  Created by Omar Albeik on 24/11/15.
//  Copyright © 2015 Omar Albeik. All rights reserved.
//

import Foundation
import HealthKit

class HealthStore {
	
	class func sharedInstance() -> HealthStore {
		struct Static {
			static let instance = HealthStore()
		}
		
		return Static.instance
	}
	
	let healthStore: HKHealthStore? = HKHealthStore()
	
	func addNDBItemToHealthStore(item: NDBItem,selectedMeasure: NDBMeasure , qty: Int, completionHandler: (success: Bool, errorString: String?) -> Void) {
		
		let timeFoodWasEntered = NSDate()
		
		let foodMetaData = [
			HKMetadataKeyFoodType : item.name!,
			"HKFoodTypeID": item.ndbNo!
		]
		
		func getCalcium() -> HKQuantitySample? {
			
			// check if calcium nutrient available
			if let calcium = item.nutrients?.find({$0.id == 301}) {
				
				// check if selected measure available
				if let measure = calcium.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli), doubleValue: value)
					let calciumSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return calciumSample
				}
				return nil
			}
			return nil
		}
		
		func getCarbohydrate() -> HKQuantitySample? {
			
			// check if carbohydrate nutrient available
			if let carbohydrate = item.nutrients?.find({$0.id == 205}) {
				
				// check if selected measure available
				if let measure = carbohydrate.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: value)
					let carbohydrateSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return carbohydrateSample
				}
				return nil
			}
			return nil
		}
		
		func getCholesterol() -> HKQuantitySample? {
			
			// check if cholesterol nutrient available
			if let cholesterol = item.nutrients?.find({$0.id == 601}) {
				
				// check if selected measure available
				if let measure = cholesterol.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli), doubleValue: value)
					let cholesterolSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return cholesterolSample
				}
				return nil
			}
			return nil
		}
		
		func getEnergy() -> HKQuantitySample? {
			
			// check if energy nutrient available
			if let energy = item.nutrients?.find({$0.id == 208}) {
				
				// check if selected measure available
				if let measure = energy.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: value)
					let energySample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return energySample
				}
				return nil
			}
			return nil
		}
		
		func getFatTotal() -> HKQuantitySample? {
			
			// check if fatTotal nutrient available
			if let fatTotal = item.nutrients?.find({$0.id == 204}) {
				
				// check if selected measure available
				if let measure = fatTotal.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: value)
					let fatTotalSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return fatTotalSample
				}
				return nil
			}
			return nil
		}
		
		func getProtein() -> HKQuantitySample? {
			
			// check if protein nutrient available
			if let protein = item.nutrients?.find({$0.id == 203}) {
				
				// check if selected measure available
				if let measure = protein.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: value)
					let proteinSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return proteinSample
				}
				return nil
			}
			return nil
		}
		
		func getSugar() -> HKQuantitySample? {
			
			// check if sugar nutrient available
			if let sugar = item.nutrients?.find({$0.id == 269}) {
				
				// check if selected measure available
				if let measure = sugar.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: value)
					let sugarSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return sugarSample
				}
				return nil
			}
			return nil
		}
		
		func getVitaminC() -> HKQuantitySample? {
			
			// check if vitamin C nutrient available
			if let vitaminC = item.nutrients?.find({$0.id == 401}) {
				
				// check if selected measure available
				if let measure = vitaminC.measures?.find({$0.label == selectedMeasure.label}) {
					
					let value: Double = Double(qty) * (measure.value as! Double)
					let unit = HKQuantity(unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli), doubleValue: value)
					let vitaminCSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)!,
						quantity: unit,
						startDate: timeFoodWasEntered,
						endDate: timeFoodWasEntered)
					
					return vitaminCSample
				}
				return nil
			}
			return nil
		}
		
		
		if HKHealthStore.isHealthDataAvailable() {
			
			var nutrientsArray: [HKQuantitySample] = []
			
			if let calcium = getCalcium() {
				nutrientsArray.append(calcium)
			}
			
			if let carbohydrates = getCarbohydrate() {
				nutrientsArray.append(carbohydrates)
			}
			
			if let cholesterol = getCholesterol() {
				nutrientsArray.append(cholesterol)
			}
			
			if let energy = getEnergy() {
				nutrientsArray.append(energy)
			}
			
			if let fatTotal = getFatTotal() {
				nutrientsArray.append(fatTotal)
			}
			
			if let protein = getProtein() {
				nutrientsArray.append(protein)
			}
			
			if let sugar = getSugar() {
				nutrientsArray.append(sugar)
			}
			
			if let vitaminC = getVitaminC() {
				nutrientsArray.append(vitaminC)
			}
			
			let foodDataSet = NSSet(array: nutrientsArray)
			
			let foodCoorelation = HKCorrelation(type: HKCorrelationType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood)!, startDate: timeFoodWasEntered, endDate: timeFoodWasEntered, objects: foodDataSet as! Set<HKSample>, metadata : foodMetaData)
			
			healthStore?.saveObject(foodCoorelation, withCompletion: { (success, error) -> Void in
				
				
				if success {
					
					print("Item saved to Heath App successfully")
					completionHandler(success: true, errorString: nil)
					
				} else {
					
					print(error?.localizedDescription)
					
					if error!.code == 4 {
						
						completionHandler(success: false, errorString: "Access to Health App denied, You can allow access from Health App -> Sources -> NutritionDiary.")
					} else {
						completionHandler(success: false, errorString: "\(error!.code)")
					}
					
				}
				
				
			})
			
			
		}
		else {
			completionHandler(success: false, errorString: "Health App is not available, Device is not compatible.")
		}
		
	}
	
	func requestAuthorizationForHealthStore() {
		
		let dataTypesToWrite: [AnyObject] = [
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCalcium)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCholesterol)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietarySugar)!,
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryVitaminC)!
		]
		
		healthStore?.requestAuthorizationToShareTypes(NSSet(array: dataTypesToWrite) as? Set<HKSampleType>, readTypes: nil, completion: { (success, error) -> Void in
			
			if success {
				print("User completed authorization request.")
				
				NSUserDefaults.standardUserDefaults().setObject(true, forKey: "healthStoreSync")
				NSUserDefaults.standardUserDefaults().synchronize()
				
			} else {
				print("User canceled the request \(error!.localizedDescription)")
				
				NSUserDefaults.standardUserDefaults().setObject(false, forKey: "healthStoreSync")
				NSUserDefaults.standardUserDefaults().synchronize()
				
			}
			
		})
		
	}
	
	
}