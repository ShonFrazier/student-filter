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

extension String {
    public var expandingTildeInPath: String {
        var result = self

        if nil != self.range(of: "~/") {
            if let home = Process().environment?["HOME"] {
                result = self.replacingOccurrences(of: "~/", with: "\(home)/")
            }
        }

        return result
    }

    public func appendingPathComponent(_ c: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(c).path
    }
}
