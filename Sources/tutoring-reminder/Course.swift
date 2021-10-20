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
    let name: String // course name
    let section: String // course section
    var startDate: String // course startDate

    init(name: String, section: String = "", startDate: String = "") {
        self.name = name.lowercased()
        self.section = section.lowercased()
        self.startDate = startDate
    }

    var debugDescription: String {
        return "\(name):\(section) \(startDate)"
    }

    var description: String { name }

    func hash(into hasher: inout Hasher) {
        return name.hash(into: &hasher)
    }

    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.name == rhs.name
    }
}
