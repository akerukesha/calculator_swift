//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Akerke Okapova on 6/13/17.
//  Copyright © 2017 Akerke Okapova. All rights reserved.
//
import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double? = 0
    private var resultIsPending: Bool = false
    
    private var currentResult: Double? = 0
    private var resultText: String = ""
    private var accumulatorText: String? = ""
    
    private var currentFunction: (Double, Double) -> Double = {$0 + $1}
    private var currentSymbol: String = ""
    
    // закачиваем операнд в модельку
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        accumulatorText = formatter.string(from: operand as NSNumber!)
    }
    
    private enum Operation {
        case constant(Double)
        case random(() -> Double)
        case unaryOperation((Double, String) -> (Double, String))
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "rand": Operation.random{ Double(arc4random()) / Double(UInt32.max) },
        "√": Operation.unaryOperation{(sqrt($0), "√(" + $1 + ")")},
        "cos": Operation.unaryOperation{(cos($0), "cos(" + $1 + ")")},
        "sin": Operation.unaryOperation{(sin($0), "sin(" + $1 + ")")},
        "±": Operation.unaryOperation{(-$0, "±(" + $1 + ")")},
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result,
        "AC": Operation.clear
    ]
    
    // выполняем операцию
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulatorText = symbol
                accumulator = value
            case .random(let function):
                accumulator = function()
                accumulatorText = formatter.string(from: accumulator! as NSNumber!)
            case .unaryOperation(let function):
                if resultIsPending == true && accumulator == nil {
                    accumulator = currentResult
                    accumulatorText = resultText
                }
                if accumulator != nil {
                    let currentOperation = function(accumulator!, accumulatorText!)
                    accumulator = currentOperation.0
                    accumulatorText = currentOperation.1
                } else {
                    let currentOperation = function(currentResult!, resultText)
                    currentResult = currentOperation.0
                    resultText = currentOperation.1
                }
            case .binaryOperation(let function):
                if resultIsPending == true {
                    if accumulator != nil {
                        currentResult = currentFunction(currentResult!, accumulator!)
                        resultText += currentSymbol + accumulatorText!
                        print(symbol)
                        if symbol == "×" || symbol == "÷" {
                            resultText = "(" + resultText + ")"
                        }
                    }
                } else if resultText.isEmpty == false {
                    resultText = "(" + resultText + ")"
                } else if resultText.isEmpty {
                    if accumulator == 0 {
                        accumulatorText = "0"
                    }
                    currentResult = accumulator
                    resultText = accumulatorText!
                }
                currentFunction = function
                currentSymbol = symbol
                resultIsPending = true
                accumulator = nil
                accumulatorText = nil
            case .result:
                if resultIsPending == true {
                    if accumulator != nil {
                        currentResult = currentFunction(currentResult!, accumulator!)
                        resultText += currentSymbol + accumulatorText!
                        accumulator = nil
                        accumulatorText = nil
                    }
                    resultIsPending = false
                }
            case .clear:
                accumulator = 0
                currentResult = nil
                accumulatorText = ""
                resultText = ""
                
                resultIsPending = false
                currentFunction = {$0 + $1}
                currentSymbol = ""
            }
        }
    }
    
    var result: Double? {
        if accumulator != nil{
            return accumulator
        }
        return currentResult
    }
    
    var description: String? {
        var currentText: [String] = []
        
        currentText.append(resultText)
        if resultIsPending == true || resultText.isEmpty {
            currentText.append(currentSymbol)
            if accumulator != nil {
                currentText.append(accumulatorText!)
            }
            currentText.append("...")
        } else {
            if accumulator != nil {
                currentText.append(accumulatorText!)
            }
            currentText.append("=")
        }
        return currentText.joined()
    }
    
}
