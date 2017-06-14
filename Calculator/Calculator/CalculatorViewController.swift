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
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var brain = CalculatorBrain()
    var userInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let currentTextInDisplay = displayLabel.text!
        
        if !userInTheMiddleOfTyping {
            displayLabel.text = digit
            
            //9 + 3 = 12, 0 + 3 = 15 bug
            userInTheMiddleOfTyping = true
        } else {
            
            //нужно реализовать по-другому
            if currentTextInDisplay == "0"{
                displayLabel.text = digit
            } else {
                displayLabel.text = currentTextInDisplay + digit
            }
        }
    }
    
    var displayDescription: String {
        get { return displayLabel.text! }
        set { descriptionLabel.text = newValue }
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
            if let description = brain.description {
                displayDescription = description
            }
        }
    }
    
    @IBAction func makeDouble(_ sender: Any) {
        // displayLabel!.text? или displayLabel!.text!  почему?
        if displayLabel != nil, displayLabel!.text!.contains(".") == false {
            let currentTextInDisplay = displayLabel.text!
            displayLabel.text = currentTextInDisplay + "."
        }
    }
}
