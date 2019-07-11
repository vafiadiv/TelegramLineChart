//
//  Stack.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import Foundation

struct Stack<T> {
    private var array = Array<T>()

    mutating func push(_ element: T) {
        array.append(element)
    }

    mutating func pop() -> T? {
        if let element = array.last {
            array.removeLast()
            return element
        } else {
            return nil
        }
    }
}
