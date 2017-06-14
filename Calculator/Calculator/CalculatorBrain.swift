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
    private var descriptionText: String?
    
    // закачиваем операнд в модельку
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
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
                accumulator = value
            case .unaryOperation(let function):
                //25 + √ √ = 27.23...
                if pbo != nil, accumulator == nil{
                    accumulator = pbo!.firstOperand
                }
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                //5 + 5 - 10 = -10 bug
                //почему так?
                //pbo?.function = function
                
                if accumulator != nil {
                    resultIsPending = true
                    pbo = PendingBinaryOperation(firstOperand: pbo == nil ? accumulator! : pbo!.perform(with: accumulator!), function: function)
                    accumulator = nil
                }
            case .result:
                //2 + 3 + 4 + + + + + = 9
                if accumulator != nil {
                    resultIsPending = false
                    accumulator = pbo?.perform(with: accumulator!)
                    pbo = nil
                } else {
                    if pbo != nil {
                        accumulator = pbo?.firstOperand
                    }
                }
            case .clear:
                accumulator = 0
                pbo = nil
                descriptionText = ""
                resultIsPending = false
            }
        }
    }
    
    var result: Double? {
        return accumulator
    }
    
    var description: String? {
        return descriptionText
    }
    
}
