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

let useTestData = true

struct FileNames {
    static let zipCode = "ZipCodeCityCountyMiles25.csv"
    static let enrollment = "StudentEnrollmentFall2021.csv"
    static let studentInfo = "StudentInfoFall2021.csv"
    static let coursesWithTutors = "CourseListForNewtonCampusTutoring.txt"
    static let finalEmailList = "FinalList.txt"

    static let testStudentInfo = "StudentInfoTestFile.csv"
    static let testEnrollment = "StudentEnrollmentTestFile.csv"
}

let dataDirectoryPath = "/Users/shon/Desktop/student-data/".expandingTildeInPath

let zipCodeFilePath =           dataDirectoryPath.appendingPathComponent( FileNames.zipCode )
let zipCodeFD = CsvFileDescription(path: zipCodeFilePath)

let coursesWithTutorsPath =     dataDirectoryPath.appendingPathComponent( FileNames.coursesWithTutors )
let coursesWithTutorsFD = CsvFileDescription(path: coursesWithTutorsPath)

let studentInfoFilePath =       dataDirectoryPath.appendingPathComponent( FileNames.studentInfo )
let studentInfoFD = CsvFileDescription(path: studentInfoFilePath, header: true)

let studentEnrollmentFilePath = dataDirectoryPath.appendingPathComponent( FileNames.enrollment )
let studentEnrollmentFD = CsvFileDescription(path: studentEnrollmentFilePath, header: true)


let testStudentInfoPath =       dataDirectoryPath.appendingPathComponent( FileNames.testStudentInfo )
let testStudentInfoFD = CsvFileDescription(path: testStudentInfoPath, header: true)

let testEnrollmentPath =        dataDirectoryPath.appendingPathComponent( FileNames.testEnrollment )
let testEnrollmentFD = CsvFileDescription(path: testEnrollmentPath, header: true)


let finalListDir =              dataDirectoryPath.appendingPathComponent("Final")


var localZipCodes = readZipCodes(from: zipCodeFD)
print("\n\(#line) localZipCodes.count: \(localZipCodes.count)\n")

var tutoringLabCourses = readCourses(from: coursesWithTutorsFD)
print("\n\(#line) tutoringLabCourses.count: \(tutoringLabCourses.count)\n")

var allStudents: [Student] = {
    if useTestData {
        return readStudents(from: testStudentInfoFD)
    } else {
        return readStudents(from: studentInfoFD)
    }
}()
print("\(#line) allStudents.count: \(allStudents.count)")

if useTestData {
    readStudentEnrollment(from: testEnrollmentFD, students: allStudents)
} else {
    readStudentEnrollment(from: studentEnrollmentFD, students: allStudents)
}

// Operations stored in vars
var localStudents = Array<Student>(allStudents.filter { localZipCodes.contains($0.zipCode) })
print("\(#line) localStudents.count: \(localStudents.count)")

var countByCourses = [String:Int]()
for s in localStudents {
    for c in s.courses {
        if tutoringLabCourses.contains(c) {
            let count = countByCourses[c] ?? 0
            countByCourses[c] = count + 1
        }
    }
}
print("\(#line) countByCourses: \(countByCourses.debugDescription)")

for student in localStudents {
    student.courses = student.courses.filter { tutoringLabCourses.contains($0) }
}


var enrolledInTutorableCourses = localStudents.filter { $0.courses.count > 0 }
var emailList = enrolledInTutorableCourses.map { $0.email }
var emailNoDupe = emailList.removingDuplicates()

var (_, totalStudentCourseNeed) = countByCourses.reduce(("",0), { return ("", $0.1 + $1.1) })

print("Total student/course need: \(totalStudentCourseNeed)")

// Operations chained
var emails: [String] = allStudents
    .filter { localZipCodes.contains($0.zipCode) }  // local students...
    .filter { student in
        student.courses.filter { course in
            tutoringLabCourses.contains(course)
        }
        .count > 0
    }                                               // ...enrolled in courses having a tutor
    .map { $0.email }                               // just their emails
    .removingDuplicates()

do {
    try write(list: emails, to: finalListDir, maxPerFile: 500)
} catch (let error) {
    print("Error writing file to path \(finalListDir)\n\t\(error)")
}
