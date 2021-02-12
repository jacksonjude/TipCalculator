//
//  CurrencyAnimatedLabel.swift
//  TipCalculator
//
//  Created by jackson on 2/11/21.
//

import UIKit

class CurrencyAnimatedLabel: AnimatedLabel
{    
    override func setTextValue(value: Float) {
        super.setTextValue(value: value)
        text = CurrencySymbolHelper.addCurrencySymbol(text)
    }
}
