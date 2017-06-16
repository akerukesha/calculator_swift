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
    private var pbo: PendingBinaryOperation?
    private var resultIsPending: Bool?
    private var descriptionText: [String] = []
    private var prevOperation: OperationDescription = .clear
    
    // закачиваем операнд в модельку
    mutating func setOperand(_ operand: Double) {
        if prevOperation == .unaryOperation || prevOperation == .constant || prevOperation == .number {
            descriptionText = []
        }
        prevOperation = .number
        accumulator = operand
        descriptionText.append(String(operand))
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear
    }
    
    private enum OperationDescription {
        case clear
        case number
        case constant
        case unaryOperation
        case binaryOperation
        case result
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "rand": Operation.constant(Double(arc4random_uniform(1000) + 1000) / 10000),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "±": Operation.unaryOperation({ -$0 }),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result,
        "AC": Operation.clear
    ]
    
    private struct PendingBinaryOperation {
        var firstOperand: Double
        var function: (Double, Double) -> Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    // выполняем операцию
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                if prevOperation != .binaryOperation, prevOperation != .clear {
                    descriptionText = []
                }
                prevOperation = .constant
                descriptionText.append(symbol)
                accumulator = value
            case .unaryOperation(let function):
                //25 + √ √ = 27.23...
//                if pbo != nil, accumulator == nil{
//                    accumulator = pbo!.firstOperand
//                }
                if accumulator != nil {
                    if descriptionText.count == 0 {
                        descriptionText.append("0")
                    }
                    placeBrackets(symbol: symbol, currentOperation: OperationDescription.unaryOperation)
                    prevOperation = .unaryOperation
                    accumulator = function(accumulator!);

                }
            case .binaryOperation(let function):
                //5 + 5 - 10 = -10 bug
                
                //почему так?
                //pbo?.function = function
                
                if accumulator != nil {
                    if prevOperation == .result {
                        resultIsPending = true
                    }
                    if prevOperation == .clear{
                        descriptionText.append("0")
                    }
                    placeBrackets(symbol: symbol, currentOperation: OperationDescription.binaryOperation)
                    prevOperation = .binaryOperation
                    resultIsPending = true
                    descriptionText.append(symbol)
                    if pbo != nil {
                        accumulator = pbo?.perform(with: accumulator!)
                    }
                    pbo = PendingBinaryOperation(firstOperand: accumulator!, function: function)
                }
            case .result:
                //2 + 3 + 4 + + + + + = 9
                if accumulator != nil {
                    prevOperation = .result
                    resultIsPending = false
                    descriptionText.append(symbol)
                    accumulator = pbo?.perform(with: accumulator!)
                    pbo = nil
                    //2 + 2 + 2 = = = = = = * 3 = 18
                }
            case .clear:
                prevOperation = .clear
                accumulator = 0
                pbo = nil
                descriptionText = []
                resultIsPending = false
            }
        }
    }
    
    mutating private func placeBrackets(symbol: String, currentOperation: OperationDescription){
        if prevOperation == .result || prevOperation == .binaryOperation {
            descriptionText.remove(at: descriptionText.count - 1)
        }
        
        if currentOperation == .binaryOperation, symbol == "×" || symbol == "÷" {
            if resultIsPending == true {
                descriptionText.insert(")", at: descriptionText.count)
                descriptionText.insert("(", at: 0)
            }
        }else if currentOperation == .unaryOperation {
//            print("unary")
            if prevOperation == .result || prevOperation == .unaryOperation {
                descriptionText.insert(symbol, at: 0)
                descriptionText.insert("(", at: 1)
                descriptionText.insert(")", at: descriptionText.count)
            } else {
                descriptionText.insert(symbol, at: descriptionText.count - 1)
                descriptionText.insert("(", at: descriptionText.count - 1)
                descriptionText.insert(")", at: descriptionText.count)
            }
        }
    }
    
    var result: Double? {
        return accumulator
    }
    
    var description: String? {
        get {
            if resultIsPending != nil, resultIsPending == true {
                return descriptionText.joined(separator: " ") + " ..."
            }
            return descriptionText.joined(separator: " ")
        }
    }
    
}

//25 + √ = 30 description bug
//25 = 6 = description bug
//25 = + does not change to + logical bug
