//
//  Observable.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 21/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

class Observable<T> {
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    typealias Observer = (T) -> Void
    var observer: Observer? {
        didSet {
            observer?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
}
