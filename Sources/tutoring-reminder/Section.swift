//
//  File.swift
//  File
//
//  Created by Shon on 9/16/21.
//

import Foundation

class Section : CustomDebugStringConvertible, CustomStringConvertible, Hashable {
    let name: String
    let startDate: String

    init(name: String, startDate: String) {
        self.name = name
        self.startDate = startDate
    }

    var debugDescription: String {
        return description
    }

    var description: String { "Section < \(name) \(startDate == "" ? "<<>>" : startDate) >" }

    func hash(into hasher: inout Hasher) {
        return description.hash(into: &hasher)
    }

    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.description == rhs.description
    }
}
