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

class CsvFileDescription : CustomDebugStringConvertible {
    var location: URL
    var hasCsvHeader: Bool
    var skipLines: Int
    var convert: (Bool, LineEndingConversion?)

    var skippedLines = [String]()

    init(location: URL, header: Bool = false, convertingLineEndings: (Bool, LineEndingConversion?) = (false, nil), skipping lines: Int = 0) {
        self.location = location
        self.hasCsvHeader = header
        self.skipLines = lines
        self.convert = convertingLineEndings
    }

    convenience init(path: String, header: Bool = false, convertingLineEndings: (Bool, LineEndingConversion?) = (false, nil), skipping lines: Int = 0) {
        self.init(location: URL(fileURLWithPath: path), header: header, convertingLineEndings: convertingLineEndings, skipping: lines)
    }

    var debugDescription: String {
        return "\(location.lastPathComponent) at \(location.deletingLastPathComponent().path)\n" +
            "\thas \(hasCsvHeader ? "a" : "no") header\n\t" + {
                if skippedLines.count > 0 {
                    return "skipped \(skippedLines.count) lines:\n" +
                        "\t\"\(skippedLines.map { $0.replacingOccurrences(of: "\"", with: "\\\"") }.joined(separator: "\"\n\t\""))" + "\""
                } else {
                    return "skips \(skipLines) lines"
                }
            }()
    }
}
