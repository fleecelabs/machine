import HealthKit

struct HealthManager {
  let healthKitStore:HKHealthStore = HKHealthStore()
  
  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {
    var healthKitTypesToWrite: Set<HKSampleType> = Set()
    var healthKitTypesToRead: Set<HKObjectType> = Set()
    healthKitTypesToWrite.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!)
    healthKitTypesToWrite.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!)
    healthKitTypesToRead.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!)
    healthKitTypesToRead.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!)
    
    if !HKHealthStore.isHealthDataAvailable() {
      let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil ) {
        completion(success:false, error:error)
      }
      return;
    }
    
    healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
      
      if( completion != nil ) {
        completion(success:success,error:error)
      }
    }
  }
  
  func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
    
    // 1. Build the Predicate
    let past = NSDate.distantPast() as NSDate
    let now   = NSDate()
    let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
    
    // 2. Build the sort descriptor to return the samples in descending order
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
    let limit = 1
    
    // 4. Build samples query
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in
        
        if let _ = error {
          completion(nil,error)
          return;
        }
        
        // Get the first sample
        let mostRecentSample = results!.first as? HKQuantitySample
        
        // Execute the completion closure
        if completion != nil {
          completion(mostRecentSample,nil)
        }
    }
    // 5. Execute the Query
    self.healthKitStore.executeQuery(sampleQuery)
  }
}
