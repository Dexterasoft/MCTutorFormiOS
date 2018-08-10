//
//  MCLookup.swift
//  MCTutorFormiOS
//
//  Created by Brett Allen on 7/29/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import Foundation
import SQLite3

let DEBUG_MODE = false
let DATABASE_NAME = "MCDatabase"
let DATABASE_FILE = "MCDatabase.sqlite"

/*
 dictBannerData[“StuID”] = “\(vBanner1[0])”
 dictBannerData[“course”] = “\(vBanner1[1])”
 dictBannerData[“Section”] = “\(vBanner1[2])”
 dictBannerData[“stuFName”] = “\(vBanner1[3])”
 dictBannerData[“stuLName”] = “\(vBanner1[4])”
 dictBannerData[“profName”] = “\(vBanner1[5])”
 dictBannerData[“mcCaMpus”] = “\(vBanner1[6])”
 */

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

// Allow tables to be created
// Add DDL commands here, i.e., CREATE, DROP, ALTER
protocol SQLTable {
    static var createStatement: String { get }
    
    // Add any aditional operations to give all tables different abilities, i.e., dropStatement
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    fileprivate let dbPointer: OpaquePointer?
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        // 1
        if sqlite3_open(path, &db) == SQLITE_OK {
            // 2
            return SQLiteDatabase(dbPointer: db)
        } else {
            // 3
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    /**
     Destroy the most resently opened database file
     */
    static func destroyDatabase(path: String) {
        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
                print("Successfully destroyed database \(path)")
            }
        } catch {
            print("Could not destroy \(path) Database file.")
        }
    }
    
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    public func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
    // Table creation
    public func createTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        // 2 ensure that your statements are always finalized
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3 lets you write a more expressive check for the SQLite status codes
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("\(table) table created.")
    }
    
    //MARK Wrapping Insertions
    /**
     Insert course info into the database. CourseInfo table has the following fields:
     section CHAR(6) PRIMARY KEY NOT NULL,
     course CHAR(255)
     
     @param courseInfo the course information from the CourseInfo table to be inserted into the CourseInfo Table
     */
    public func insertCourseInfo(courseInfo: CourseInfo) throws {
        let insertSql = """
        INSERT INTO CourseInfo (section, course)
        VALUES (?, ?);
        """
        
        let insertStatement = try prepareStatement(sql: insertSql)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let section: NSString = courseInfo.section
        let course: NSString = courseInfo.course
        
        // Determine if the insert statement is valid
        // 1 = first ? (arg)
        // 2 = second ? (arg)
        let isSqliteOK = sqlite3_bind_text(insertStatement, 1, section.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, course.utf8String, -1, nil) == SQLITE_OK
        
        guard isSqliteOK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        if DEBUG_MODE {
            print("Successfully inserted course info.")
        }
    }
    
    /**
     Insert course into the database. Course table has the following fields:
     courseID INT PRIMARY KEY AUTOINCREMENT,
     FOREIGN KEY(stuID) REFERENCES Student(stuID),
     FOREIGN KEY(section) REFERENCES CourseInfo(section),
     profName CHAR(255),
     mcCampus CHAR(2)
     
     @param course the course to inserted into the Course table
     */
    public func insertCourse(course: Course) throws {
        let insertSql = """
        INSERT INTO Course (stuID, section, profName, mcCampus)
        VALUES (?, ?, ?, ?);
        """
        
        let insertStatement = try prepareStatement(sql: insertSql)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let stuID: NSString = course.stuID
        let section: NSString = course.section
        let profName: NSString = course.profName
        let mcCampus: NSString = course.mcCampus
        
        let isSqliteOK = sqlite3_bind_text(insertStatement, 1, stuID.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, section.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, profName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, mcCampus.utf8String, -1, nil) == SQLITE_OK
        
        guard isSqliteOK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        if DEBUG_MODE {
            print("Successfully inserted course.")
        }
    }
    
    /**
     Insert student into the database. Student table has the following fields:
     stuID CHAR(10) PRIMARY KEY NOT NULL,
     stuFName CHAR(255),
     stuLName CHAR(255)
     
     @param student the student to inserted into the Student table
     */
    public func insertStudent(student: Student) throws {
        let insertSql = """
        INSERT INTO Student (stuID, stuFName, stuLName)
        VALUES (?, ?, ?);
        """
        
        let insertStatement = try prepareStatement(sql: insertSql)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let stuID: NSString = student.stuID
        let stuFName: NSString = student.stuFName
        let stuLName: NSString = student.stuLName
        
        let isSqliteOK = sqlite3_bind_text(insertStatement, 1, stuID.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, stuFName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, stuLName.utf8String, -1, nil) == SQLITE_OK
        
        guard isSqliteOK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        if DEBUG_MODE {
            print("Successfully inserted student.")
        }
    }
    
    //MARK - Allow database querying
    /**
     A general query that will act as the default call to extract all the necessary information for
     the output.
     
     This function can be used by itself or by a helper function to nest desired queries, i.e., to grab key data.
     
     @param querySql the SQL query to be executed.
     @return an array of dictionaries with keys and values of type NSString. This ensures the versatility and scalability
     of this function. Multiple rows can be returned with a variable number of columns. It is dependant on the
     invoker to perform any remaining parsing on the returned query results.
     */
    public func query(querySql: String) -> [[NSString : NSString]] {
        var results: [[NSString : NSString]] = []
        let queryStatement = try? prepareStatement(sql: querySql)
        
        defer {
            sqlite3_finalize(queryStatement!)
        }
        
        // Get all columns
        let columns = sqlite3_column_count(queryStatement!)
        
        if DEBUG_MODE {
            print("Query selects \(sqlite3_column_count(queryStatement!)) columns")
        }
        
        // Get all rows
        while sqlite3_step(queryStatement!) == SQLITE_ROW {
            // Each row will contain a dictionary with keys being the field names and values being the field content
            var rowDict: [NSString : NSString] = [:]
            
            for col in 0...columns - 1 {
                let key = String(cString: sqlite3_column_name(queryStatement!, col)) as NSString
                let value = String(cString: sqlite3_column_text(queryStatement!, col)) as NSString
                rowDict[key] = value
            }
            
            results.append(rowDict)
        }
        
        if DEBUG_MODE {
            print("Query returned \(results.count) rows")
        }
        
        return results
    }
    
    /**
     A query function that allows for sql queries in the format of SELECT, FROM, WHERE
     for the Student table
     
     Student (stuID, stuFName, stuLName)
     
     @param selectClause the table fields to be displayed, i.e., selected
     @return the query results with the type of the specified Student table
     */
    public func getStudentById(id: String) -> Student? {
        let querySql = "SELECT * FROM Student WHERE stuID = ?;"
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        // This will insert whatever you want into the question mark (?) within the querySql string
        // In this case the id will be replacing the question mark (?)
        guard sqlite3_bind_text(queryStatement, 1, id, -1, nil) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        let stuID = String(cString: sqlite3_column_text(queryStatement, 0)) as NSString
        let stuFName = String(cString: sqlite3_column_text(queryStatement, 1)) as NSString
        let stuLName = String(cString: sqlite3_column_text(queryStatement, 2)) as NSString
        
        return Student(stuID: stuID, stuFName: stuFName, stuLName: stuLName)
    }
}

// Begin Student Table
struct Student {
    let stuID: NSString
    let stuFName: NSString
    let stuLName: NSString
}

extension Student: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE Student(
        stuID CHAR(10) PRIMARY KEY NOT NULL,
        stuFName CHAR(255),
        stuLName CHAR(255)
        );
        """
    }
    
    // NB: add dropStatement here if desired ability to drop table (must be added in protocol SQLTable first)
}
// End Student Table

// Begin CourseInfo Table
struct CourseInfo {
    let section: NSString
    let course: NSString
}

extension CourseInfo: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE CourseInfo(
        section CHAR(6) PRIMARY KEY NOT NULL,
        course CHAR(255)
        );
        """
    }
    
    // NB: add dropStatement here if desired ability to drop table (must be added in protocol SQLTable first)
}
// End CourseInfo Table

// Begin Course Table
struct Course {
    let stuID: NSString
    let section: NSString
    let profName: NSString
    let mcCampus: NSString
}

extension Course: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE Course(
        courseID INTEGER PRIMARY KEY AUTOINCREMENT,
        stuID CHAR(10),
        section CHAR(6),
        profName CHAR(255),
        mcCampus CHAR(2),
        CONSTRAINT student_fk FOREIGN KEY(stuID) REFERENCES Student(stuID),
        CONSTRAINT courseInfo_fk FOREIGN KEY(section) REFERENCES CourseInfo(section)
        );
        """
    }
    
    // NB: add dropStatement here if desired ability to drop table (must be added in protocol SQLTable first)
}
// End Course Table

// Struct for obtaining all returned key data from generalized query
struct KeyData {
    let stuID: NSString
    let stuFName: NSString
    let stuLName: NSString
    let course: NSString
    let section: NSString
    let profName: NSString
    let mcCampus: NSString
}

class MCLookup {
    private let STUDENT_ID = "student_id"
    private let COURSE = "course"
    private let SECTION = "section"
    private let STUDENT_FNAME = "student_fname"
    private let STUDENT_LNAME = "student_lname"
    private let PROF_NAME = "professor_name"
    private let CAMPUS_CODE = "campus_code"
    
    public let TARGET_DB = Bundle.main.path(forResource: DATABASE_NAME, ofType: "sqlite") ?? "NONE"
    
    private var m_db: SQLiteDatabase
    
    // Will iterate over the keys for each line delimited by CRLF or LF
    private var m_keys: [String] = []
    
    private var m_currentDate: String = ""
    
    private var m_csvFile: String = ""
    
    init(file: String) throws {
        m_keys = [STUDENT_ID, COURSE, SECTION, STUDENT_FNAME, STUDENT_LNAME, PROF_NAME, CAMPUS_CODE]
        
        m_csvFile = file
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        m_currentDate = formatter.string(from: date)
        
        // Attempt to connect to specified database
//        do {
//            m_db = try SQLiteDatabase.open(path: TARGET_DB)
//            print("Successfully opened connection to database.")
//        } catch SQLiteError.OpenDatabase( _) {
//            print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
//            m_db = SQLiteDatabase(dbPointer: nil)
//        }
        m_db = SQLiteDatabase(dbPointer: nil)
        
        // TEST CODE VVVV
        // Determining if the sqlite database file exists (need to initialize database if not)
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        
        let filePath = "\(path)/MCDatabase.sqlite"
        let fileManager = FileManager.default
        
        // Determine if the database file exists and take the necessary course of action
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
        }
    }
    
    /**
     Initialize the database either when the database has become corrupted or does not exist
     */
    public func initDatabase() throws {
        // Initialize database
        SQLiteDatabase.destroyDatabase(path: TARGET_DB)
        
        // Attempt to connect to specified database
        do {
            m_db = try SQLiteDatabase.open(path: TARGET_DB)
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase( _) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
        }
        
        // Create the Student, CourseInfo, and Course tables
        try createDatabaseTables()
        
        // Read csv and load data into database
        readCSV(file: m_csvFile)
    }
    
    /**
     Get the core database object to gain access to raw database function such as the query function
     */
    public func getDB() -> SQLiteDatabase {
        return m_db
    }
    
    /**
     Read through CSV data that has already been read in to a string from a file.
     Parse out the data specified in the KEYS array
     
     @param data the raw data read in from a CSV file
     @param delimiter the character that is used to denote fields in the CSV file, i.e., a comma or a tab. Delimiter is a comma by default
     @return the dictionary containing all the data retrieved from the CSV
     */
    private func readCSVData(data: String, delimiter: Character = ","){
        var keyIndex = 0                                        // Iterate through the keys with wrap-around functionality
        let rows = data.components(separatedBy: .newlines)      // Get all the rows to parse data from
        
        // A hash set to keep track of student keys; used to prevent inserting duplicates into student table
        var studentPKSet = Set<NSString>()
        var courseInfoPKSet = Set<NSString>()
        
        for row in rows {
            // Handle corner case when CSV data has extra spaces at the end of it when spliting on newline characters by skipping that line
            // This case will result in empty rows, i.e., ""
            if row.isEmpty {
                continue
            }
            
            let quotes = row.indicesOf(string: "\"")
            var modRow = row
            var professor = "NULL" // May want to initialize to N/A, None, or NULL so that it won't be inserted as blank into dictionary
            
            // Use a temporary dictionary to index when inserting into database
            var rowDict: [String : NSString] = [:]
            
            // Extract tokens between quotes, i.e., professor names before tokenizing entire row
            if row.contains("\"") {
                // EXAMPLE:
                // Original row: 20949014,ENGL190,20320,Anewo-Ande,Coswhawpe,"Rosado, Emily K.",D
                // Extracted part I: 20949014,ENGL190,20320,Anewo-Ande,Coswhawpe
                // Extracted part II: ,D
                // Concatonated part I and part II: 20949014,ENGL190,20320,Anewo-Ande,Coswhawpe,D
                // Extracted professor: Rosado, Emily K.
                
                modRow = "\(row.prefix(quotes[0] - 1))\(row.suffix(row.count - quotes[1] - 1))"
                professor = row.slice(from: "\"", to: "\"")!
            }
            
            // Extract tokens from modded row based on specified delimited, i.e., commas or tabs
            let tokens = modRow.split(separator: delimiter)
            
            for token in tokens {
                // Insert professor when current key is the professor name and jump to the next index to properly capture the campus code
                if m_keys[keyIndex] == PROF_NAME {
                    rowDict[m_keys[keyIndex]] = professor as NSString
                    keyIndex = (keyIndex + 1) % m_keys.count
                }
                
                rowDict[m_keys[keyIndex]] = token as NSString
                keyIndex = (keyIndex + 1) % m_keys.count
            }
            
            // Get the NSString version of csv data
            let stuID = rowDict[STUDENT_ID]!
            let stuFName = rowDict[STUDENT_FNAME]!
            let stuLName = rowDict[STUDENT_LNAME]!
            let section = rowDict[SECTION]!
            let course = rowDict[COURSE]!
            let profName = rowDict[PROF_NAME]!
            let mcCampus = rowDict[CAMPUS_CODE]!
            
            // Database insertions
            // NB: ensure that any primary data that foreign keys are relying on exist before inserting foreign key data
            // The following should always be the order of insertion: Student, CourseInfo, Course
            // Avoid inserting duplicate id's in Student table
            if !studentPKSet.contains(stuID) {
                do {
                    try m_db.insertStudent(student: Student(stuID: stuID, stuFName: stuFName, stuLName: stuLName))
                } catch {
                    print(m_db.errorMessage)
                }
                
                studentPKSet.insert(stuID)
            }
            
            // Avoid inserting duplicate id's in CourseInfo table
            if !courseInfoPKSet.contains(section) {
                do {
                    try m_db.insertCourseInfo(courseInfo: CourseInfo(section: section, course: course))
                } catch {
                    print(m_db.errorMessage)
                }
                
                courseInfoPKSet.insert(section)
            }
            
            // Don't have to worry about unique constraint violation for pk of Course table since course id autoincrements
            do {
                try m_db.insertCourse(course: Course(stuID: stuID, section: section, profName: profName, mcCampus: mcCampus))
            } catch {
                print(m_db.errorMessage)
            }
        }
        
        print("Processed \(rows.count) lines")
        print("All data inserted successfully.")
    }
    
    /**
     Reads contents of a CSV file by opening the specified CSV file and extracting its raw data.
     Uses readCSVData function as a helper function to parse the raw CSV data
     
     @param file the CSV file to extract the raw data from to be parsed
     */
    private func readCSV(file: String){
        do {
            let data = try String(contentsOfFile: file, encoding: .utf8)
            readCSVData(data: data)
        } catch {
            print(error)
        }
    }
    
    private func createDatabaseTables() throws{
        // Create the tables
        do {
            try m_db.createTable(table: Student.self)
            try m_db.createTable(table: CourseInfo.self)
            try m_db.createTable(table: Course.self)
        } catch {
            print(m_db.errorMessage)
        }
    }
    
    /**
     Get key data based on a student ID.
     Results will return rows containing the student's first name, last name, id, course, section
     professor, and campus
     
     @param id the student's id to be used as the baseline of the query
     */
    public func getKeyDataByStudentID(id: String) -> [KeyData] {
        let querySql = """
        SELECT Student.stuID, Student.stuFName, Student.stuLName,
        CourseInfo.section, CourseInfo.course,
        Course.profName, Course.mcCampus
        FROM Student, Course, CourseInfo
        WHERE Student.stuID = \(id) AND Student.stuID = Course.stuID AND Course.section = CourseInfo.section
        """
        
        let results = m_db.query(querySql: querySql)
        
        // To conform to KeyData array
        var keyDataConformity: [KeyData] = []
        
        // NB: Keys derived from select statement
        for result in results {
            let keyData = KeyData(stuID: result["stuID"] ?? "NULL", stuFName: result["stuFName"] ?? "NULL", stuLName: result["stuLName"] ?? "NULL", course: result["course"] ?? "NULL", section: result["section"] ?? "NULL", profName: result["profName"] ?? "NULL", mcCampus: result["mcCampus"] ?? "NULL")
            
            keyDataConformity.append(keyData)
        }
        
        // Return the results of querying the database
        return keyDataConformity
    }
    
    /**
     Get the current system date in the format of MM/DD/YYYY
     
     @return the current system date
     */
    public func getCurrentDate() -> String {
        return m_currentDate
    }
    
    /**
     A debugging function to test implementations and display desired data
     */
    public func dump() {}
}

/**
 A class to keep track of how long a program takes to run.
 */
class ParkBenchTimer {
    
    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
