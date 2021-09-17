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

class CsvFile : CustomDebugStringConvertible {
    private let fileDescription: CsvFileDescription
    private let hasHeader: Bool
    private var fieldNames = [String]() // ordered; stringified Ints when there's no header

    public let lines: [CsvLine]

    init?(_ fd: CsvFileDescription) throws {
        self.fileDescription = fd

        let allData: Data
        do {
            let data = try Data(contentsOf: fd.location)
            if fd.convert.0, let le = fd.convert.1 {
                allData = data.convertingLineEndings(with: le)
            } else {
                allData = data
            }
        } catch (let error) {
            print("\(error)")
            return nil
        }

        guard let allString = String(data: allData, encoding: .utf8) else {
            print("Can't convert contents to a string")
            return nil
        }

        let substrings = allString.split(separator: "\n", omittingEmptySubsequences: false)
        var lines = substrings.map { "\($0)".trimmingCharacters(in: CharacterSet.whitespaces) }

        if fd.skipLines > 0 {
            fd.skippedLines = Array<String>(lines[0..<fd.skipLines])
            lines = Array<String>(lines[fd.skipLines..<lines.count])
        }

        var fieldNames = [String]() // ordered; stringified Ints when there's no header

        self.hasHeader = fd.hasCsvHeader
        let columns = CsvLine.split(line: lines[0])
        if self.hasHeader {
            columns.forEach { name in
                let lowerName = name.lowercased()
                fieldNames.append(lowerName)
            }
            lines.remove(at: 0)
        } else {
            for i in 0..<columns.count {
                let name = "\(i)"
                fieldNames.append(name)
            }
        }

        self.lines = lines
                        .filter { $0.lengthOfBytes(using: .utf8) > 0 }
                        .map { CsvLine(line: $0, columnNames: fieldNames) }
        self.fieldNames = fieldNames
    }

    var debugDescription: String {
        return "\(lines[0].columns.count) fields:\n - \(fieldNames.joined(separator: "\n - "))\n\(fileDescription.debugDescription)"
    }
}

class CsvLine {
    let columns: [String: String]

    init(line: String, columnNames: [String]) {
        let columnValues = CsvLine.split(line: line)
        var columns = [String:String]()
        if columnValues.count != columnNames.count {
            print("Column values or Column names is the wrong size")
            self.columns = columns
            return
        }

        for i in 0..<columnNames.count {
            columns[columnNames[i]] = columnValues[i]
        }

        self.columns = columns
    }

    func get(field name: String) -> String? {
        return columns[name.lowercased()]
    }

    func get(field index: Int) -> String? {
        return get(field: "\(index)")
    }

    public static func split(line: String) -> [String] {
        var s = ""
        var allStrings = [String]()
        var ignoreCommas = false
        for c in line {
            if c == "\"" {
                ignoreCommas = !ignoreCommas
                continue
            }

            if c == "," && !ignoreCommas {
                allStrings.append(s)
                s = ""
                continue
            }

            s += "\(c)"
        }
        allStrings.append(s)
        return allStrings
    }
}
