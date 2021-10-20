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
//public var countCurrentStudentsCourses = 0

func readZipCodes(from fileDescription: CsvFileDescription) -> Set<String> { print("\(clock()) begin \(#function)"); defer {print("\(clock()) end   \(#function)")}
    guard let file = try? CsvFile(fileDescription) else {
        return Set<String>()
    }

    var zipCodes = Set<String>()
    for line in file.lines {
        if let zipcode = line.get(field: 0) {
            zipCodes.insert(zipcode)
        }
    }

    return zipCodes
}

func readSections(from fileDescription: CsvFileDescription) -> Set<String> { print("\(clock()) begin \(#function)"); defer {print("\(clock()) end   \(#function)")}
    guard let file = try? CsvFile(fileDescription) else {
        return Set<String>()
    }

    var sections = Set<String>()
    for line in file.lines {
        if let section = line.get(field: 0)?.lowercased() {
            sections.insert(section)
        }
    }

    return sections
}

func readCourses(from fileDescription: CsvFileDescription) -> Set<Course> { print("\(clock()) begin \(#function)"); defer {print("\(clock()) end   \(#function)")}
    guard let file = try? CsvFile(fileDescription) else {
        return Set<Course>()
    }

    var courses = Set<Course>()
    for line in file.lines {
        if let courseName = line.get(field: 0)?.lowercased() {
            let course = Course(name: courseName)
            courses.insert(course)
        }
    }

    return courses
}

func readStudents(from fileDescription: CsvFileDescription) -> Set<Student> { print("\(clock()) begin \(#function)"); defer {print("\(clock()) end   \(#function)")}
    guard let file = try? CsvFile(fileDescription) else {
        return Set<Student>()
    }

    var studentList = Set<Student>()

    for line in file.lines {
        guard let email = line.get(field: "student e-mail")?.lowercased() else {
            continue
        }
        guard let name = line.get(field: "student name") else {
            continue
        }
        guard let zipCode = line.get(field: "zip") else {
            continue
        }

        let student = Student(email: email, zipCode: zipCode, name: name)
        studentList.insert(student)
    }

    return studentList
}

func readStudentEnrollment(from fileDescription: CsvFileDescription, students: Set<Student>) { print("\(clock()) begin \(#function)"); defer {print("\(clock()) end   \(#function)")}
    guard let file = try? CsvFile(fileDescription) else {
        return
    }

    var studentsByEmail = [String:Student]()
    for student in students {
        studentsByEmail[student.email] = student
    }

    for line in file.lines {
        guard let email: String = line.get(field: "student e-mail")?.trimmingCharacters(in: CharacterSet.whitespaces).lowercased() else {
            continue
        }
        guard let courseName = line.get(field: "course number")?.trimmingCharacters(in: CharacterSet.whitespaces).lowercased() else {
            continue
        }
        guard let section = line.get(field: "section")?.trimmingCharacters(in: CharacterSet.whitespaces).lowercased() else {
            continue
        }
        guard let startDate = line.get(field: "start date")?.trimmingCharacters(in: CharacterSet.whitespaces).lowercased() else {
            continue
        }
        guard let student = studentsByEmail[email] else {
            continue
        }

        let course = Course(name: courseName, section: section, startDate: startDate)
        student.append(course: course) // add course to student's list

        //if startDate != "" {
            //student.append(course: course) // add course to student's list
            //countCurrentStudentsCourses += 1
            student.append(section: section)    //      **** without this lines nothing goes in the Student.swift's 'sections' also changing 'course' to 'section' or 'startDate' gives an error for both lines
            student.append(startDate: section)      //  **** without this lines nothing goes in the Student.swift's 'startDate'
       // }
 
    }
}

func write(list: [String], to dirPath: String, maxPerFile max: Int = 500) throws { print("\(clock()) begin \(#function)"); defer {print("\(clock()) end   \(#function)")}
    // Clear the previous results by deleting and recreating the folder
    let url = URL(fileURLWithPath: finalListDir)

    do {
        // Remove the folder and its contents
        try FileManager.default.removeItem(at: url)
    } catch _ {}

    do {
        // Recreate the folder
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    } catch let error {
        print("Error creating \(url):\n\t\(error)")
    }

    // Break the full list into lists sized according to maxPerFile
    var slices = [[String]]()
    var count = 0

    while count < list.count {
            let start = count
            let end = min(count + max, list.count)
            let slice = list[start ..< end]
            slices.append(Array(slice))
            count += max
    }

    // Re-purpose count for file names
    count = 1
    var nameFormat = "emails.txt"
    if slices.count > 1 {
        nameFormat = "emails-%03d.txt"
    }

    for list in slices {
        defer { count += 1 }

        // Append all strings in one list putting \n between
        let contents = list.joined(separator: "\n")

        try FileManager.default.createDirectory(at: URL(fileURLWithPath: dirPath), withIntermediateDirectories: true)

        let filePath = dirPath.expandingTildeInPath.appendingPathComponent(String(format: nameFormat, count) )
        FileManager.default.createFile(atPath: filePath, contents: contents.data(using: .utf8))
    }
}
