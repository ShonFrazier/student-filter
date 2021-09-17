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
    static let campusSections = "CampusSections.txt"
    static let tutorableSections = "TutorableSections.txt"

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

let campusSectionsFilePath = dataDirectoryPath.appendingPathComponent( FileNames.campusSections )
let campusSectionsFD = CsvFileDescription(path: campusSectionsFilePath)

let tutorableSectionsFilePath = dataDirectoryPath.appendingPathComponent( FileNames.tutorableSections )
let tutorableSectionsFD = CsvFileDescription(path: tutorableSectionsFilePath)


let testStudentInfoPath =       dataDirectoryPath.appendingPathComponent( FileNames.testStudentInfo )
let testStudentInfoFD = CsvFileDescription(path: testStudentInfoPath, header: true)

let testEnrollmentPath =        dataDirectoryPath.appendingPathComponent( FileNames.testEnrollment )
let testEnrollmentFD = CsvFileDescription(path: testEnrollmentPath, header: true)


let finalListDir =              dataDirectoryPath.appendingPathComponent("Final")


var localZipCodes = readZipCodes(from: zipCodeFD)
print("\n\(#line) localZipCodes.count: \(localZipCodes.count)\n")

var (tutoringLabCourses, coursesByName) = readCourses(from: coursesWithTutorsFD)
print("\n\(#line) tutoringLabCourses.count: \(tutoringLabCourses.count)\n")

var campusSections = readSections(from: campusSectionsFD)
print("\n\(#line) campusSections.count: \(campusSections.count)\n")

var tutorableSection = readSections(from: tutorableSectionsFD)
print("\n\(#line) tutorableSection.count: \(tutorableSection.count)\n")


let allStudents: Set<Student>
if useTestData {
    allStudents = readStudents(from: testStudentInfoFD)
} else {
    allStudents = readStudents(from: studentInfoFD)
}
print("\n\(#line) allStudents.count: \(allStudents.count)\n")

let coursesBySection: [Section:Course]
if useTestData {
    coursesBySection = readStudentEnrollment(from: testEnrollmentFD, students: allStudents, coursesByName: coursesByName)
} else {
    coursesBySection = readStudentEnrollment(from: studentEnrollmentFD, students: allStudents, coursesByName: coursesByName)
}
print("\n\(#line) coursesBySection: \(abbreviate(coursesBySection, prefix:"\t"))\n")

// Operations stored in vars
var localStudents = Array<Student>(allStudents.filter { localZipCodes.contains($0.zipCode) })
print("\n\(#line) localStudents.count: \(localStudents.count)\n")

var countBySections = [Section:Int]()
for s in localStudents {
    for sect in s.sections {
        if campusSections.contains(sect) {
            let count = countBySections[sect] ?? 0
            countBySections[sect] = count + 1
        }
    }
}
print("\n\(#line) countBySections: \(countBySections)\n")

for student in localStudents { // remove courses that are not available in the tutoring lab
    student.sections = student.sections.filter { campusSections.contains($0) || $0.startDate != ""}
}

var campusStudents = allStudents.filter { s in
    var keep = false
    for section in s.sections {
        if campusSections.contains(section) {
            keep = true
            break
        }
    }
    return keep
}
print("\n\(#line) campusStudents.count: \(campusStudents.count)\n")

var enrolledInTutorableSections = campusStudents.filter { $0.sections.count > 0 }
var emailList = enrolledInTutorableSections.map { $0.email }
var emailNoDupe = emailList.removingDuplicates()

var (_, totalStudentCourseNeed) = countBySections.reduce(("",0), { return ("", $0.1 + $1.1) })

print("\n\(#line) Total student/course need: \(totalStudentCourseNeed)\n")

// Operations chained
var emails: [String] = allStudents
    .filter { localZipCodes.contains($0.zipCode) }  // local students...
    .filter { student in
        student.sections.filter { section in
            campusSections.contains(section)
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
