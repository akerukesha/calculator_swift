//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Akerke Okapova on 6/13/17.
//  Copyright © 2017 Akerke Okapova. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    
    var brain = CalculatorBrain()
    var userInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let currentTextInDisplay = displayLabel.text!
        
        if !userInTheMiddleOfTyping {
            displayLabel.text = digit
            if digit != "0"{
                userInTheMiddleOfTyping = true
            }
        } else {
            displayLabel.text = currentTextInDisplay + digit
        }
    }
    
    var displayValue: Double {
        get { return Double(displayLabel.text!)! }
        set { displayLabel.text = String(newValue) }
    }

    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
            
            if let result = brain.result {
                displayValue = result
            }
        }
    }
}
