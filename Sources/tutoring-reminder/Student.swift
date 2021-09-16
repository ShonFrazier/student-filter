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

class Student: Hashable, CustomStringConvertible/*, CustomDebugStringConvertible*/ {
    var email: String
    var zipCode: String
    var name: String
    var courses = [Course]()
    var sections = [Course]()
    var startDates = String()

    var debugDescription: String { "\(name) \(email) \(zipCode)" }
    var description: String { email }

    init(email: String, zipCode: String, name: String) {
        self.email = email
        self.zipCode = zipCode
        self.name = name
    }

    func append(course: Course) {
        courses.append(course)
    }
    
    func append(section: Course){
        sections.append(section)
    }
    
    
    func append(startDate: String){
        startDates.append(startDate)
    }
    

    func hash(into hasher: inout Hasher) {
        email.hash(into: &hasher)
    }

    static func < (lhs: Student, rhs: Student) -> Bool {
        return lhs.email < rhs.email
    }

    static func > (lhs: Student, rhs: Student) -> Bool {
        return lhs.email > rhs.email
    }

    static func == (lhs: Student, rhs: Student) -> Bool {
        return lhs.email == rhs.email
    }

    static func != (lhs: Student, rhs: Student) -> Bool {
        return lhs.email != rhs.email
    }
}
