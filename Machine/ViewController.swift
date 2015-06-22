import UIKit
import HealthKit

class ViewController: UIViewController {
  let healthManager:HealthManager = HealthManager()
  
  var weight:HKQuantitySample?
  var height:HKQuantitySample?
  var calculatedBmi:Double?
  var bmi:HKQuantitySample?
  
  @IBOutlet weak var weightLabel: UILabel!
  @IBOutlet weak var heightLabel: UILabel!
  @IBOutlet weak var bmiLabel: UILabel!
  @IBOutlet weak var calculatedBmiLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    healthManager.authorizeHealthKit { (success, error) -> Void in
      self.updateWeight()
      self.updateBmi()
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
      
      if( error != nil ) {
        print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var weightLocalizedString = "Fegis"
      // 3. Format the weight to display it on the screen
      self.weight = mostRecentWeight as? HKQuantitySample;
      if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
        let weightFormatter = NSMassFormatter()
        weightFormatter.forPersonMassUse = true;
        weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
        print(weightLocalizedString)
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.weightLabel.text = weightLocalizedString
        self.updateHeight()
      });
    });
  }
  
  func updateHeight() {
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
    
    self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
      
      if( error != nil ) {
        print("Error reading height from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var heightLocalizedString = "Fegis!";
      self.height = mostRecentHeight as? HKQuantitySample;
      if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
        let heightFormatter = NSLengthFormatter()
        heightFormatter.forPersonHeightUse = true;
        heightLocalizedString = heightFormatter.stringFromMeters(meters);
      }
      
      // 4. Update UI in the main thread
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.heightLabel.text = heightLocalizedString
        self.calculateBMI()
      });
    });
  }

  func updateBmi() {
    let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
    
    self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentBmi, error) -> Void in
      
      if( error != nil ) {
        print("Error reading BMI from HealthKit Store: \(error.localizedDescription)")
        return;
      }
      
      var bmiLocalizedString = "Fegis!";
      self.bmi = mostRecentBmi as? HKQuantitySample;
      if let bmiValue = self.bmi?.quantity.doubleValueForUnit(HKUnit.countUnit()) {
        bmiLocalizedString = String(format:"%.02f", bmiValue)
      }
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.bmiLabel.text = bmiLocalizedString
      });
    });
  }

  func calculateBMI() {
    if weight != nil && height != nil {
      let weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
      let heightInMeters = height!.quantity.doubleValueForUnit(HKUnit.meterUnit())
      calculatedBmi  = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
    }
    if calculatedBmi != nil {
      calculatedBmiLabel.text =  String(format: "%.02f", calculatedBmi!)
    }
  }
 
  func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double? {
    if heightInMeters == 0 {
      return nil;
    }
    return (weightInKilograms/(heightInMeters*heightInMeters));
  }
  
  @IBAction func saveBmiDataPoint() {
    if calculatedBmi != nil {
      healthManager.saveBMISample(calculatedBmi!, date: NSDate())
    } else {
      print("There is no BMI data to save")
    }
  }
}

