/*
 Copyright (c) 2021 Shon Frazier

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import Foundation

class Course : Hashable, CustomStringConvertible /*, CustomDebugStringConvertible*/ {
    let name: String
    var sections = [Section]()

    init(name: String) {
        self.name = name.lowercased()
    }

    func append(section: Section) {
        sections.append(section)
    }

    var debugDescription: String {
        return description
    }

    var description: String { "Course: < \(name) \(sections.count) section\(sections.count != 1 ? "s" : "") >" }

    func hash(into hasher: inout Hasher) {
        return description.hash(into: &hasher)
    }

    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.description == rhs.description
    }
}
