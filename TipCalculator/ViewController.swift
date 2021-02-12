//
//  ViewController.swift
//  TipCalculator
//
//  Created by jackson on 2/11/21.
//

import UIKit

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
    @IBOutlet var tipAmountLabel: AnimatedLabel!
    @IBOutlet var totalAmountLabel: AnimatedLabel!
    
    @IBOutlet var tipSliderPercentContainerView: UIView!
    @IBOutlet var tipContainerView: UIView!
    @IBOutlet var totalContainerView: UIView!
    var billAmountPlaceholder = "$"
    let segmentTipPercentages = [0.15, 0.18, 0.20]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        billAmountPlaceholder = getCurrencySymbol() + "0.00"
        
        billAmountTextField.delegate = self
        billAmountTextField.keyboardType = .decimalPad
        billAmountTextField.clearButtonMode = .whileEditing
        billAmountTextField.placeholder = billAmountPlaceholder
        
        addDoneButton(textField: billAmountTextField)
        
        tipSliderPercentContainerView.addRoundedCorners()
        tipContainerView.addRoundedCorners()
        totalContainerView.addRoundedCorners()
        
        tipPercentSegmentControl.selectedSegmentIndex = 0
        
        tipAmountLabel.decimalPoints = .two
        totalAmountLabel.decimalPoints = .two
        
        tipAmountLabel.countingMethod = .linear
        totalAmountLabel.countingMethod = .linear
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
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.placeholder = ""
        textField.text = addCurrencySymbol(textField.text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return Double((getBillAmountText() ?? "") + string) != nil
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        if getBillAmountText() != nil, let doubleValue = Double(getBillAmountText()!)
        {
            textField.text = addCurrencySymbol(getDecimalRoundedString(doubleValue: doubleValue, placesToRound: 2))
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
        textField.text = getCurrencySymbol()
        calculateTip(textField)
        return false
    }
    
    @IBAction func tipSegmentControlValueChanged(_ sender: Any)
    {
        if tipPercentSegmentControl.selectedSegmentIndex == UISegmentedControl.noSegment { return }
        
        let tipPercentage = segmentTipPercentages[tipPercentSegmentControl.selectedSegmentIndex]*100
        
        tipPercentSlider.setValue(Float(tipPercentage), animated: true)
        tipPercentLabel.text = String(Int(tipPercentage.rounded())) + "%"
    }
    
    @IBAction func tipSliderValueChanged(_ sender: Any)
    {
        tipPercentSegmentControl.selectedSegmentIndex = UISegmentedControl.noSegment
        
        let tipPercentage = tipPercentSlider.value
        tipPercentLabel.text = String(Int(tipPercentage.rounded())) + "%"
    }
    
    @IBAction func calculateTip(_ sender: Any)
    {
        guard let billAmountString = getBillAmountText() else { return }
                
        let billAmount = Double(billAmountString) ?? 0.0
        
        var tipPercentage = segmentTipPercentages.first ?? 0.15
        if tipPercentSegmentControl.selectedSegmentIndex != UISegmentedControl.noSegment
        {
            tipPercentage = segmentTipPercentages[tipPercentSegmentControl.selectedSegmentIndex]
        }
        else
        {
            tipPercentage = Double(tipPercentSlider.value.rounded()/100.0)
        }
        
        //tipAmountLabel.text = addCurrencySymbol(getDecimalRoundedString(doubleValue: billAmount*tipPercentage, placesToRound: 2))
        //totalAmountLabel.text = addCurrencySymbol(getDecimalRoundedString(doubleValue: billAmount*(1+tipPercentage), placesToRound: 2))
        
        tipAmountLabel.countFromCurrent(to: Float(billAmount*tipPercentage), duration: .superbrisk)
        totalAmountLabel.countFromCurrent(to: Float(billAmount*(1+tipPercentage)), duration: .superbrisk)
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
        return billAmountString.replacingOccurrences(of: getCurrencySymbol(), with: "")
    }
    
    func addCurrencySymbol(_ amountString: String?) -> String
    {
        guard let amountString = amountString else {
            return getCurrencySymbol()
        }
        
        if amountString.hasPrefix(getCurrencySymbol()) { return amountString }
        
        return getCurrencySymbol() + amountString
    }
    
    func getCurrencySymbol() -> String
    {
        return Locale.current.currencySymbol ?? "$"
    }
}

