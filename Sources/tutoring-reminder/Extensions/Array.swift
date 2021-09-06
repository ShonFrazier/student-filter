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

extension Array where Element: Comparable {
    func removingDuplicates() -> Array {
        var last: Element? = nil
        let filtered: Array = self
            .sorted()
            .filter { e in
                let include = (e != last)
                last = e
                return include
            }

        return filtered
    }

    mutating func removeDuplicates() {
        self.sort()

        var last: Element? = nil
        var index: Int = 0
        var indexesForDeletion: [Int] = self.map { e in
            defer {
                last = e
                index += 1
            }

            if e != last {
                return -1
            }
            return index
        }

        indexesForDeletion = indexesForDeletion.filter { $0 != -1 }.reversed()

        for i in indexesForDeletion {
            self.remove(at: i)
        }
    }
}
