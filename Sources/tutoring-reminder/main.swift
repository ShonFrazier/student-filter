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

let dataDirectoryPath = "~/Documents/Programming/Swift Projects".expandingTildeInPath

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
print("\n\(#line) localZipCodes File count: \(localZipCodes.count)\n")

var tutoringLabCourses = readCourses(from: coursesWithTutorsFD)
print("\n\(#line) tutoringLabCourses File count: \(tutoringLabCourses.count)\n")

var campusSections = readSections(from: campusSectionsFD) // campusSections set of Strings
print("\n\(#line) campusSections File count: \(campusSections.count)\n")

var tutorableSection = readSections(from: tutorableSectionsFD)
print("\n\(#line) tutorableSection File count: \(tutorableSection.count)\n")

// Read the StudentInfo file allStudents = StudentInfo file
var allStudents: Set<Student> = {
    if useTestData {
        return readStudents(from: testStudentInfoFD)
    } else {
        return readStudents(from: studentInfoFD)
    }
}()
print("\n\(#line) allStudents in StudentInfo File count: \(allStudents.count)\n")

// Read StudentEnrollment file
if useTestData {
    readStudentEnrollment(from: testEnrollmentFD, students: allStudents)
} else {
    readStudentEnrollment(from: studentEnrollmentFD, students: allStudents)
}

func shouldKeepStudent(student: Student) -> Bool {
    return student.hasCoursesWithStartDate
}

// 1. Take current students from allStudents and put into currentStudents
// 2. get count of currentStudents (this is all Perimeter Students for the Current Semester)

// notes from conversation Wed. 10-20-21
// currentcourses = courses.filter{$0.startDate != ""}
//currentStudents = students.filter{for $0.startDate != ""}
var isCurrentStudent = false
var currentStudents = Set<Student>(
    allStudents.filter( shouldKeepStudent )
)
print("\n\(#line) Total Current Students: \(currentStudents.count)\n") // 14 correct

// Operations stored in vars

// 3. filter currentStudents into campusStudents using CampusSections file
// 4. get count of Campus Students and Campus Sections
// 5. filter CampusSections to tutorableSections
// 6. get count of tutorableSections by section and a sum of tutorableSections
// 7. filter currentStudents into Students in 25 mile radius
// 8. get count of Students in 25 mile radius
// 9. filter Students in 25 mile radius into tutorableCourses
// 10 get count by Course and a sum of courses

var countCurrentStudentsCourses = 0
// CAMPUS DATA
var countBySection = [String:Int]()
var sumCountBySection = 0
var countCurrentStudentsOnCampus = 0
var isCurrentSemesterCourse = false
var isCampusCourse = false
var courseSection = ""

for student in currentStudents {
    for course in student.courses {
        if course.startDate != "" {
            isCurrentSemesterCourse = true
            countCurrentStudentsCourses += 1 // 22 correct

            for section in student.sections{
                if campusSections.contains(section) { // is never true *** tried to compare c.section
                    print("\(#line) section is on campus \(section) start date \(course.startDate) \(student.email)")
                    isCampusCourse = true
                    let count = countBySection[section] ?? 0
                    countBySection[section] = count + 1
                    sumCountBySection += 1
                } else {
                     print("\(#line) campusSections does not contain \(section) \(student.email)")
                }
            }
        }
        isCurrentSemesterCourse = false
    }
    if isCampusCourse {
        countCurrentStudentsOnCampus += 1
        isCampusCourse = false
    }
}

print("\n\(#line) Total Current Student Courses with start date: \(countCurrentStudentsCourses)") // 22 working
print("\n\(#line) Total Current Students on Campus: \(countCurrentStudentsOnCampus)") // 6 not working
print("\n\(#line) countBySection on Campus: \(countBySection)") // not working [85515: 2, 97005: 2, 86235: 1, 93567: 1, 87661: 1, 85855: 1, 95134: 2]
print("\n\(#line) sumCountBySection on Campus: \(sumCountBySection)") // 10 not working

// gives a count of enrollment in each tutorable section on Campus
var countByTutorableSection = [String:Int]() // ??? Does this reset to 0's
var sumCountByTutorableSection = 0
for student in allStudents {
    for section in student.sections { // element in sections(Student)
        if tutorableSection.contains(section) {
            let count = countByTutorableSection[section] ?? 0
            countByTutorableSection[section] = count + 1
            sumCountByTutorableSection += 1
        }

    }
}
print("\n\(#line) countByTutorableSection on Campus: \(countByTutorableSection)\n")
print("\(#line) sumCountByTutorableSection on Campus: \(sumCountByTutorableSection)\n")

// total Students in

// 25 MILE RADIUS DATA
// reduce allStudents to localStudents in 25 mile radius
let localStudents = Array<Student>(allStudents.filter { localZipCodes.contains($0.zipCode) })
print("\(#line) localStudents in 25 mile radius count: \(localStudents.count)") // 12 sb 11

// gives a count by course name *** THIS WORKS ***
var countByCourses = [Course:Int]()
var sumCountByCourses = 0
for s in localStudents {
    for c in s.courses {
        if tutoringLabCourses.contains(c) {
            let count = countByCourses[c] ?? 0
            countByCourses[c] = count + 1
            sumCountByCourses += 1
        }
    }
}
print("\n\(#line) countByCourses in localStudents: \(countByCourses)\n") // [engl-1101: 3, math-2652: 1, econ-2105: 2, math-1113: 1, math-1111: 1, acct-2102: 1, acct-2101: 1]
print("\(#line) sumCountByCourses in localStudents: \(sumCountByCourses)\n")

// That takes each student’s course list and keeps only those courses with a start date
for student in localStudents { // remove courses that are not available in the tutoring lab
    student.courses = student.courses.filter { tutoringLabCourses.contains($0) || $0.startDate != ""}
}

var enrolledInTutorableCourses = localStudents.filter { $0.courses.count > 0 }
var emailList = enrolledInTutorableCourses.map { $0.email }
var emailNoDupe = emailList.removingDuplicates()

// Operations chained
var emails: [String] = allStudents // should be coming from current students
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
