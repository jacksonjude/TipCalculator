//
//  ViewController.swift
//  TipCalculator
//
//  Created by jackson on 2/11/21.
//

import UIKit
import CoreHaptics

extension UIView
{
    func addRoundedCorners(cornerAmount: Double = 10.0)
    {
        self.layer.cornerRadius = CGFloat(cornerAmount)
    }
}

class ViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet var billAmountTextField: UITextField!
    @IBOutlet var tipPercentSegmentControl: UISegmentedControl!
    @IBOutlet var tipPercentSlider: UISlider!
    @IBOutlet var tipPercentLabel: UILabel!
    @IBOutlet var tipAmountLabel: CurrencyAnimatedLabel!
    @IBOutlet var totalAmountLabel: CurrencyAnimatedLabel!
    
    @IBOutlet var tipSliderPercentContainerView: UIView!
    @IBOutlet var tipContainerView: UIView!
    @IBOutlet var totalContainerView: UIView!
    
    var previousSliderValue: Int?
    
    var hapticEngine: CHHapticEngine?
    var hapticPattern: CHHapticPattern?
    
    var billAmountPlaceholder = "$"
    let segmentTipPercentages = [0.15, 0.18, 0.20]
    let maxBillAmountCharacters = 8
    let fallbackTipPercentage = 0.15
    let valueSaveTime = 1.0*60*20
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        billAmountPlaceholder = CurrencySymbolHelper.getCurrencySymbol() + "0.00"
        
        billAmountTextField.delegate = self
        billAmountTextField.keyboardType = .decimalPad
        billAmountTextField.clearButtonMode = .whileEditing
        billAmountTextField.placeholder = billAmountPlaceholder
        
        billAmountTextField.becomeFirstResponder()
                
        tipSliderPercentContainerView.addRoundedCorners()
        tipContainerView.addRoundedCorners()
        totalContainerView.addRoundedCorners()
        
        tipPercentSegmentControl.selectedSegmentIndex = 0
        
        tipAmountLabel.decimalPoints = .two
        totalAmountLabel.decimalPoints = .two
        
        tipAmountLabel.countingMethod = .linear
        totalAmountLabel.countingMethod = .linear
        
        fetchSavedValues()
        
        hapticEngine = try? CHHapticEngine()
        let hapticDict = [
            CHHapticPattern.Key.pattern: [
                [CHHapticPattern.Key.event: [
                    CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
                    CHHapticPattern.Key.time: 0.01,
                    CHHapticPattern.Key.eventDuration: 1] // End of first event
                ] // End of first dictionary entry in the array
            ] // End of array
        ] // End of haptic dictionary

        hapticPattern = try? CHHapticPattern(dictionary: hapticDict)
    }
    
    func addDoneButton(textField: UITextField)
    {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    func fetchSavedValues()
    {
        guard let savedValuesUpdatedAt = UserDefaults.standard.object(forKey: "valuesUpdatedAt") as? TimeInterval else { return }
        
        if Date().timeIntervalSince1970-savedValuesUpdatedAt > valueSaveTime { return }
        
        guard let billAmount = UserDefaults.standard.object(forKey: "billAmount") as? Double else { return }
        guard let tipPercentage = UserDefaults.standard.object(forKey: "tipPercentage") as? Double else { return }
        
        billAmountTextField.text = formatCurrency(billAmount)
        if (segmentTipPercentages.contains(tipPercentage))
        {
            tipPercentSegmentControl.selectedSegmentIndex = segmentTipPercentages.firstIndex(of: tipPercentage)!
            tipSegmentControlValueChanged(tipPercentSegmentControl!)
        }
        else
        {
            tipPercentSlider.value = Float(tipPercentage*100)
            tipSliderValueChanged(tipPercentSlider!)
        }
        
        calculateTip(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.placeholder = ""
        textField.text = CurrencySymbolHelper.addCurrencySymbol(textField.text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newAmountString = (getBillAmountText() ?? "") + string
        let shouldChangeCharacters = Double(newAmountString) != nil && newAmountString.count <= maxBillAmountCharacters
        
        if shouldChangeCharacters
        {
            try? playHapticFromPattern(hapticPattern)
        }
        return shouldChangeCharacters
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        if getBillAmountText() != nil, let doubleValue = Double(getBillAmountText()!)
        {
            textField.text = formatCurrency(doubleValue)
        }
        else if getBillAmountText() == nil || getBillAmountText() == ""
        {
            textField.text = ""
        }
        
        textField.placeholder = billAmountPlaceholder
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.endEditing(true)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        textField.text = CurrencySymbolHelper.getCurrencySymbol()
        calculateTip(textField)
        
        try? playHapticFromPattern(hapticPattern)
        
        return false
    }
    
    @IBAction func tipSegmentControlValueChanged(_ sender: Any)
    {
        if tipPercentSegmentControl.selectedSegmentIndex == UISegmentedControl.noSegment { return }
        
        let tipPercentage = segmentTipPercentages[tipPercentSegmentControl.selectedSegmentIndex]*100
        
        tipPercentSlider.setValue(Float(tipPercentage), animated: true)
        tipPercentLabel.text = String(Int(tipPercentage.rounded())) + "%"
        
        try? playHapticFromPattern(hapticPattern)
    }
    
    @IBAction func tipSliderValueChanged(_ sender: Any)
    {
        tipPercentSegmentControl.selectedSegmentIndex = UISegmentedControl.noSegment
        
        let tipPercentage = tipPercentSlider.value
        let roundedTipPercentage = Int(tipPercentage.rounded())
        tipPercentLabel.text = String(roundedTipPercentage) + "%"
        
        if previousSliderValue != roundedTipPercentage
        {
            try? playHapticFromPattern(hapticPattern)
        }
        previousSliderValue = roundedTipPercentage
    }
    
    @IBAction func calculateTip(_ sender: Any)
    {
        guard let billAmountString = getBillAmountText() else { return }
                
        let billAmount = Double(billAmountString) ?? 0.0
        
        var tipPercentage = segmentTipPercentages.first ?? fallbackTipPercentage
        if tipPercentSegmentControl.selectedSegmentIndex != UISegmentedControl.noSegment
        {
            tipPercentage = segmentTipPercentages[tipPercentSegmentControl.selectedSegmentIndex]
        }
        else
        {
            tipPercentage = Double(tipPercentSlider.value.rounded()/100.0)
        }
        
        tipAmountLabel.countFromCurrent(to: Float(billAmount*tipPercentage), duration: .superbrisk)
        totalAmountLabel.countFromCurrent(to: Float(billAmount*(1+tipPercentage)), duration: .superbrisk)
        
        UserDefaults.standard.setValue(billAmount, forKey: "billAmount")
        UserDefaults.standard.setValue(tipPercentage, forKey: "tipPercentage")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: "valuesUpdatedAt")
    }
    
    func playHapticFromPattern(_ pattern: CHHapticPattern?) throws
    {
        guard let hapticEngine = hapticEngine else { return }
        guard let pattern = pattern else { return }
        
        try hapticEngine.start()
        let player = try hapticEngine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }
    
    func getDecimalRoundedString(doubleValue: Double, placesToRound: Int) -> String
    {
        let multiplyDivideValue = pow(10.0, Double(placesToRound))
        let roundedDoubleValue = (doubleValue*multiplyDivideValue).rounded()/multiplyDivideValue
        let roundedString = String(format: "%." + String(placesToRound) + "f", roundedDoubleValue)
        return roundedString
    }
    
    func getBillAmountText() -> String?
    {
        guard let billAmountString = billAmountTextField.text else { return nil }
        return billAmountString.replacingOccurrences(of: CurrencySymbolHelper.getCurrencySymbol(), with: "")
    }
    
    func formatCurrency(_ value: Double) -> String
    {
        return CurrencySymbolHelper.addCurrencySymbol(getDecimalRoundedString(doubleValue: value, placesToRound: 2))
    }
}

class CurrencySymbolHelper
{
    static func addCurrencySymbol(_ amountString: String?) -> String
    {
        guard let amountString = amountString else {
            return getCurrencySymbol()
        }
        
        if amountString.hasPrefix(getCurrencySymbol()) { return amountString }
        
        return getCurrencySymbol() + amountString
    }
    
    static func getCurrencySymbol() -> String
    {
        return Locale.current.currencySymbol ?? "$"
    }
}
