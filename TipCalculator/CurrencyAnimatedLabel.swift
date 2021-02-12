//
//  CurrencyAnimatedLabel.swift
//  TipCalculator
//
//  Created by jackson on 2/11/21.
//

import UIKit

class CurrencyAnimatedLabel: AnimatedLabel
{
    var currentAmount = 0.0
    
    override func setTextValue(value: Float) {
        super.setTextValue(value: value)
        text = addCurrencySymbol(text)
    }
    
    func addCurrencySymbol(_ amountString: String?) -> String
    {
        guard let amountString = amountString else {
            return getCurrencySymbol()
        }
        
        if amountString.hasPrefix(getCurrencySymbol()) { return amountString }
        
        return getCurrencySymbol() + amountString
    }
    
    override func countFromCurrent(to: Float, duration: AnimationDuration = .strolling) {
        super.count(from: Float(currentAmount), to: to, duration: duration)
        
        currentAmount = Double(to)
    }
    
    func getCurrencySymbol() -> String
    {
        return Locale.current.currencySymbol ?? "$"
    }
}
