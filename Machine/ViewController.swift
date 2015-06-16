import UIKit
import HealthKit

class ViewController: UIViewController {
  let healthManager:HealthManager = HealthManager()
  
  @IBOutlet weak var weightLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    healthManager.authorizeHealthKit { (success, error) -> Void in
      self.updateWeight()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func updateWeight() {
    // 1. Construct an HKSampleType for weight
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
    
    // 2. Call the method to read the most recent weight sample
    self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
      
      if( error != nil )
      {
        print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var weightLocalizedString = "Fegis"
      // 3. Format the weight to display it on the screen
      let weight = mostRecentWeight as? HKQuantitySample;
      if let kilograms = weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
        let weightFormatter = NSMassFormatter()
        weightFormatter.forPersonMassUse = true;
        weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
        print(weightLocalizedString)
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.weightLabel.text = weightLocalizedString
        //self.updateBMI()
        
      });
    });

  }
  
//  func updateBMI() {
//    if weight != nil && height != nil {
//      // 1. Get the weight and height values from the samples read from HealthKit
//      let weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
//      let heightInMeters = height!.quantity.doubleValueForUnit(HKUnit.meterUnit())
//      // 2. Call the method to calculate the BMI
//      bmi  = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
//    }
//    // 3. Show the calculated BMI
//    var bmiString = kUnknownString
//    if bmi != nil {
//      bmiLabel.text =  String(format: "%.02f", bmi!)
//    }
//  }

}

