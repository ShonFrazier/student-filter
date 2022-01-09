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

/*
 // 1. Take current students from allStudents and put into currentStudents
 // 2. get count of currentStudents (this is all Perimeter Students for the Current Semester)
 // 3. filter currentStudents into campusStudents using CampusSections file
 // 4. get count of Campus Students and Campus Sections
 // 5. filter CampusSections to tutorableSections
 // 6. get count of tutorableSections by section and a sum of tutorableSections
 // 7. filter currentStudents into Students in 25 mile radius
 // 8. get count of Students in 25 mile radius
 // 9. filter Students in 25 mile radius into tutorableCourses
 // 10 get count by Course and a sum of courses
 */

/*
 Format for CourseListForNewtonCampusTutoring.txt
 String: subject name
 ACCT-2101

 Format for CampusSections.txt
 String: section, String: subject name
 "86466",ACCT-2101

 Format for TutorableSections.txt
 String: section, String: subject name
 "86466",ACCT-2101
 
 Format for StudentEmailList.txt ? student or Faculty
 
 
 Format for FacultyEmailList.txt
 
 
 Format for Report
 
 */


import Foundation

let useTestData = true

struct FileNames {
    static let zipCode = "ZipCodeCityCountyMiles25.csv"
    //static let enrollment = "StudentEnrollmentFall2021.csv"
    static let enrollment = "campus-v2report-enrollment-2022-01-06.csv"
    //static let studentInfo = "StudentInfoFall2021.csv"
    static let studentInfo = "campus-v2report-student-2022-01-06.csv"
    static let coursesWithTutors = "CourseListForNewtonCampusTutoring.txt"
    static let finalEmailList = "StudentEmailList.txt"
    static let campusSections = "CampusSections.csv"
    static let tutorableSections = "TutorableSections.csv" // used in readSections

    static let testStudentInfo = "StudentInfoTestFile.csv"
    static let testEnrollment = "StudentEnrollmentTestFile.csv"
}

let dataDirectoryPath = "~/Documents/Programming/Swift Projects".expandingTildeInPath

let zipCodeFilePath =           dataDirectoryPath.appendingPathComponent( FileNames.zipCode )
let zipCodeFD = CsvFileDescription(path: zipCodeFilePath, convertingLineEndings: (true, .dos2unix))

let coursesWithTutorsPath =     dataDirectoryPath.appendingPathComponent( FileNames.coursesWithTutors )
let coursesWithTutorsFD = CsvFileDescription(path: coursesWithTutorsPath, convertingLineEndings: (true, .dos2unix))

let studentInfoFilePath =       dataDirectoryPath.appendingPathComponent( FileNames.studentInfo )
let studentInfoFD = CsvFileDescription(path: studentInfoFilePath, header: true, convertingLineEndings: (true, .dos2unix), skipping: 2)

let studentEnrollmentFilePath = dataDirectoryPath.appendingPathComponent( FileNames.enrollment )
let studentEnrollmentFD = CsvFileDescription(path: studentEnrollmentFilePath, header: true, convertingLineEndings: (true, .dos2unix), skipping: 2)

let campusSectionsFilePath = dataDirectoryPath.appendingPathComponent( FileNames.campusSections )
let campusSectionsFD = CsvFileDescription(path: campusSectionsFilePath, convertingLineEndings: (true, .dos2unix))

let tutorableSectionsFilePath = dataDirectoryPath.appendingPathComponent( FileNames.tutorableSections )
let tutorableSectionsFD = CsvFileDescription(path: tutorableSectionsFilePath, convertingLineEndings: (true, .dos2unix))

let testStudentInfoPath =       dataDirectoryPath.appendingPathComponent( FileNames.testStudentInfo )
let testStudentInfoFD = CsvFileDescription(path: testStudentInfoPath, header: true, convertingLineEndings: (true, .dos2unix))

let testEnrollmentPath =        dataDirectoryPath.appendingPathComponent( FileNames.testEnrollment )
let testEnrollmentFD = CsvFileDescription(path: testEnrollmentPath, header: true, convertingLineEndings: (true, .dos2unix))

let finalListDir =              dataDirectoryPath.appendingPathComponent("Final")


let localZipCodes = readZipCodes(from: zipCodeFD)
print("\(#line) localZipCodes File count: \(localZipCodes.count)\n")

let tutoringLabCourses = readCourses(from: coursesWithTutorsFD)
print("\(#line) tutoringLabCourses File count: \(tutoringLabCourses.count)\n")

let campusSections = readSections(from: campusSectionsFD) // campusSections set of Strings
print("\(#line) campusSections File count: \(campusSections.count)\n")

let tutorableSection = readSections(from: tutorableSectionsFD)
print("\(#line) tutorableSection File count: \(tutorableSection.count)\n")

// Read the StudentInfo file allStudents = StudentInfo file
let allStudents: Set<Student> = {
    if useTestData {
        return readStudents(from: testStudentInfoFD)
    } else {
        return readStudents(from: studentInfoFD)
    }
}()
print("\(#line) allStudents in StudentInfo File count: \(allStudents.count)\n")

// Read StudentEnrollment file
if useTestData {
    readStudentEnrollment(from: testEnrollmentFD, students: allStudents)
} else {
    readStudentEnrollment(from: studentEnrollmentFD, students: allStudents)
}

let currentStudents = Set<Student>(
    allStudents.filter { student in student.hasCoursesWithStartDate}
)
print("\(#line) Current Student count: \(currentStudents.count)\n") // 14 correct

let currentCampusStudents = currentStudents.filter { student in
    for section in student.sections {
        if campusSections.contains(section) {
            return true
        }
    }
    
    return false
}
print("\(#line) Current Campus Student count: \(currentCampusStudents.count)\n") // 12 correct

// ******** Don't need this *********
// reduce allStudents to localStudents (25mi radius)
let localStudents = Set<Student>(allStudents.filter { student in localZipCodes.contains(student.zipCode) })
print("\(#line) localStudents in 25 mile radius count: \(localStudents.count)\n")

// reduce currentStudents to localCurrentStudents (25mi radius)
let localCurrentStudents = Set<Student>(currentStudents.filter { localZipCodes.contains($0.zipCode) })
print("\(#line) localCurrentStudents in 25 mile radius enrolled on campus count: \(localCurrentStudents.count)\n")

assert(localCurrentStudents == (localStudents.intersection(currentStudents)))

// Operations stored in vars

var countCurrentStudentsCourses = 0
var countBySection = [String:Int]()
var sumCountBySection = 0
var countCurrentStudentsOnCampus = 0
var isCampusSection = false
var courseSection = ""

for student in currentStudents {
    countCurrentStudentsCourses += student.coursesWithStartDate.count

    for section in student.sections { // campusSections comes from "CampusSections.txt"
        if campusSections.contains(section) { 
            isCampusSection = true
            let count = countBySection[section] ?? 0
            countBySection[section] = count + 1
            sumCountBySection += 1
        } else {
            continue
        }
    }
    if isCampusSection {
        countCurrentStudentsOnCampus += 1 // calculated on line 151 don't need this
        isCampusSection = false
    }
}

print("\(#line) Total Current Student Courses with start date: \(countCurrentStudentsCourses)\n")
print("\(#line) countBySection on Campus: \(countBySection)\n")
print("\(#line) sumCountBySection on Campus: \(sumCountBySection)\n")

// gives a count of enrollment in each tutorable section on Campus
var countByTutorableSection = [String:Int]() // ??? Does this reset to 0's - no, it resets to empty
var sumCountByTutorableSection = 0
for student in currentStudents {
    for section in student.sections { // element in sections(Student)
        if tutorableSection.contains(section) {
            let count = countByTutorableSection[section] ?? 0 // and if it's empty, then we assume 0
            countByTutorableSection[section] = count + 1 // and if it was zero, we now store a 1
            sumCountByTutorableSection += 1
        }

    }
}
print("\(#line) countByTutorableSection on Campus: \(countByTutorableSection)\n")
print("\(#line) sumCountByTutorableSection on Campus: \(sumCountByTutorableSection)\n")

// 25 MILE RADIUS DATA

// gives a count by course name *** THIS WORKS ***
var countByCourses = [Course:Int]()
var sumCountByCourses = 0
for s in currentStudents {
    for c in s.courses {
        if tutoringLabCourses.contains(c) {
            let count = countByCourses[c] ?? 0
            countByCourses[c] = count + 1
            sumCountByCourses += 1
        }
    }
}
print("\(#line) countByCourses in currentStudents: \(countByCourses)\n")
print("\(#line) sumCountByCourses in currentStudents: \(sumCountByCourses)\n") // 10 working


for student in localStudents { // remove courses that are not available in the tutoring lab
    student.courses = student.courses.filter { tutoringLabCourses.contains($0) || $0.startDate != ""}
}

var enrolledInTutorableCourses = localStudents.filter { $0.courses.count > 0 }
var emailList = enrolledInTutorableCourses.map { $0.email }
var emailNoDupe = emailList.removingDuplicates()

// Operations chained

var emails: [String] = currentStudents // will include all students in tutorable classes on Newton campus and should include students not on Newton campus but are in 25 mile radius.
    //.filter { localZipCodes.contains($0.zipCode) }  // local students...
        .filter { student in student.courses.filter { course in tutoringLabCourses.contains(course)}
            .count > 0
}                                               // ...enrolled in courses having a tutor
    .map { $0.email }                               // just their emails
    .removingDuplicates()
    print("\(#line) local students in tutorable sections \n\temails.count =  \(emails.count)\n")

do {
    try write(list: emails, to: finalListDir, maxPerFile: 500)
} catch (let error) {
    print("Error writing file to path \(finalListDir)\n\t\(error)")
}
