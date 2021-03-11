//
//  Collection.swift
//  Brewed
//
//  Created by Rick Kerkhof on 12/03/2021.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
