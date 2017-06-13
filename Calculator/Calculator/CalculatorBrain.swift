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
    
    // закачиваем операнд в модельку
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.result
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
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                pbo?.function = function
                
                if accumulator != nil {
                    pbo = PendingBinaryOperation(firstOperand: pbo == nil ? accumulator! : pbo!.perform(with: accumulator!), function: function)
                    accumulator = nil
                }
            case .result:
                if accumulator != nil {
                    accumulator = pbo?.perform(with: accumulator!)
                    pbo = nil
                }
            }
        }
    }
    
    var result: Double? {
        return accumulator
    }
    
}
