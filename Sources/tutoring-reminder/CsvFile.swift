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

struct CsvFile : CustomDebugStringConvertible {
    private let fileDescription: CsvFileDescription

    private let hasHeader: Bool

    private var lineNumber = 0 // one-based
    private var fields = [String:String]()
    private var fieldNames = [String]() // ordered; stringified Ints when there's no header
    var hasMoreLines: Bool {
        lineNumber < lines.count
    }

    private var lines: [String]

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
        lines = substrings.map { "\($0)".trimmingCharacters(in: CharacterSet.whitespaces) }

        lineNumber += fd.skipLines

        if fd.skipLines > 0 {
            fd.skippedLines = Array<String>(lines[0..<fd.skipLines])
        }

        self.hasHeader = fd.hasCsvHeader
        if self.hasHeader {
            self.advance()
        }
    }

    private func split(line: String) -> [String] {
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

    mutating func advance() {
        if fieldNames.count == 0 {
            let columns = split(line: lines[lineNumber])
            if hasHeader {
                columns.forEach { name in
                    let lowerName = name.lowercased()
                    fieldNames.append(lowerName)
                }
                lineNumber += 1
            } else {
                for i in 0..<columns.count {
                    let name = "\(i)"
                    fieldNames.append(name)
                }
            }
        }

        let columns = split(line: lines[lineNumber])
        for i in 0..<columns.count {
            let name = fieldNames[i]
            fields[name] = columns[i]
        }

        lineNumber += 1
    }

    func get(field name: String) -> String? {
        return fields[name.lowercased()]
    }

    func get(field index: Int) -> String? {
        return get(field: "\(index)")
    }

    var debugDescription: String {
        return "\(fields.count) fields:\n - \(fieldNames.joined(separator: "\n - "))\n\(fileDescription.debugDescription)"
    }
}
