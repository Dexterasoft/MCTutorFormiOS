//
//  MCLookup.swift
//  MCTutorFormiOS
//
//  Created by Brett Allen on 7/29/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import Foundation

class MCLookup {
    private let STUDENT_ID = "student_id"
    private let COURSE = "course"
    private let COURSES = "courses"
    private let SECTION = "section"
    private let STUDENT_FNAME = "student_fname"
    private let STUDENT_LNAME = "student_lname"
    private let STUDENT_NAME = "student_name"
    private let PROF_NAME = "professor_name"
    private let PROFESSORS = "professors"
    private let CAMPUS_CODE = "campus_code"
    
    // Will iterate over the keys for each line delimited by CRLF or LF
    private var m_keys: [String] = []
    
    private var m_mcDict: [String : [String]] = [:]
    private var m_studentDict: [String : [String : [String]]] = [:]
    private var m_courseDict: [String : [String : String]] = [:] // [section : ["professor_name" : professor_name, "course" : course]]
    private var m_sectionLookupBycourse: [String : String] = [:] // [course : section]
    private var m_sectionLookupByprof: [String : String] = [:] // [professor : section]
    
    private var m_currentDate: String = ""
    
    private var m_csvFile: String = ""
    
    init(file: String) {
        m_keys = [STUDENT_ID, COURSE, SECTION, STUDENT_FNAME, STUDENT_LNAME, PROF_NAME, CAMPUS_CODE]
        
        m_csvFile = file
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        m_currentDate = formatter.string(from: date)
        
        initLookupTables()
    }
    
    /**
     Read through CSV data that has already been read in to a string from a file.
     Parse out the data specified in the KEYS array
     
     @param data the raw data read in from a CSV file
     @param delimiter the character that is used to denote fields in the CSV file, i.e., a comma or a tab. Delimiter is a comma by default
     @return the dictionary containing all the data retrieved from the CSV
     */
    public func readCSVData(data: String, delimiter: Character = ",") -> [String : [String]]{
        var strIdentifier = ""     // Build a string until delimiter is found
        var quoteMode = false      // Toggle quote mode when quotes are found to extract data between quotes (omitting delimiters)
        var charNum = 0            // Keep track of the character number
        var keyIndex = 0           // Iterate through the keys with wrap-around functionality
        
        var csvDict: [String : [String]] = [:] // A dictionary to store separate lists with respect to the given keys
        
        // Read 1-grams
        // Delimiters to look for: \" \n \t \, (tab or comma will be specified in delimiter variable)
        for char in data {
            if char == "\"" {
                quoteMode = !quoteMode
            }
            
            if char != delimiter || quoteMode {
                // Get rid of quotation marks
                if char != "\"" {
                    strIdentifier.append(char)
                }
            }else{
                if csvDict[m_keys[keyIndex]] == nil {
                    csvDict[m_keys[keyIndex]] = []
                }
                
                csvDict[m_keys[keyIndex]]?.append(strIdentifier)
                
                keyIndex = (keyIndex + 1) % m_keys.count
                strIdentifier = ""
            }
            
            // Extract last item when CRLF, LF, or last character in data is found outside any of the items, i.e., not within a pair of quotes
            if (char == "\n" && !quoteMode) || charNum == data.count - 1 {
                if csvDict[m_keys[keyIndex]] == nil {
                    csvDict[m_keys[keyIndex]] = []
                }
                
                csvDict[m_keys[keyIndex]]?.append(strIdentifier)
                
                keyIndex = (keyIndex + 1) % m_keys.count
                strIdentifier = ""
            }
            
            charNum += 1
        }
        
        return csvDict
    }
    
    /**
     Reads contents of a CSV file by opening the specified CSV file and extracting its raw data.
     Uses readCSVData function as a helper function to parse the raw CSV data
     
     @param file the CSV file to extract the raw data from to be parsed
     */
    public func readCSV(file: String) -> [String : [String]]{
        do {
            let data = try String(contentsOfFile: file, encoding: .utf8)
            return readCSVData(data: data)
        } catch {
            print(error)
        }
        
        return [:]
    }
    
    /**
     Initialze the lookup tables to ensure effective and efficient information retrieval
     */
    private func initLookupTables() {
        m_mcDict = readCSV(file: m_csvFile)
        
        for (index, _) in (m_mcDict[STUDENT_ID]?.enumerated())! {
            // Initialize the student dictionary
            if m_studentDict[m_mcDict[STUDENT_ID]![index]] == nil {
                m_studentDict[m_mcDict[STUDENT_ID]![index]] = [:]
            }
            
            // Initialize the student names
            if m_studentDict[m_mcDict[STUDENT_ID]![index]]![STUDENT_NAME] == nil {
                m_studentDict[m_mcDict[STUDENT_ID]![index]]![STUDENT_NAME] = []
            }
            
            // Intialize the courses list
            if m_studentDict[m_mcDict[STUDENT_ID]![index]]![COURSES] == nil {
                m_studentDict[m_mcDict[STUDENT_ID]![index]]![COURSES] = []
            }
            
            // Initialize the professors list
            if m_studentDict[m_mcDict[STUDENT_ID]![index]]![PROFESSORS] == nil {
                m_studentDict[m_mcDict[STUDENT_ID]![index]]![PROFESSORS] = []
            }
            
            // Initialize course dictionary
            if m_courseDict[m_mcDict[SECTION]![index]] == nil {
                m_courseDict[m_mcDict[SECTION]![index]] = [:]
            }
            
            // Populate section lookup tables
            m_sectionLookupBycourse[m_mcDict[COURSE]![index]] = m_mcDict[SECTION]![index]
            m_sectionLookupByprof[m_mcDict[PROF_NAME]![index]] = m_mcDict[SECTION]![index]
            
            // Populate course data
            m_courseDict[m_mcDict[SECTION]![index]]![PROF_NAME] = m_mcDict[PROF_NAME]![index]
            m_courseDict[m_mcDict[SECTION]![index]]![COURSE] = m_mcDict[COURSE]![index]
            
            // Only append one name (achieve constant time retrieval of one name)
            if m_studentDict[m_mcDict[STUDENT_ID]![index]]![STUDENT_NAME]?.count != 1 {
                let studentName = "\(m_mcDict[STUDENT_FNAME]![index]) \(m_mcDict[STUDENT_LNAME]![index])"
                m_studentDict[m_mcDict[STUDENT_ID]![index]]![STUDENT_NAME]?.append(studentName)
            }
            
            // Append courses and professors for each unique students' id
            m_studentDict[m_mcDict[STUDENT_ID]![index]]![COURSES]?.append(m_mcDict[COURSE]![index])
            m_studentDict[m_mcDict[STUDENT_ID]![index]]![PROFESSORS]?.append(m_mcDict[PROF_NAME]![index])
        }
    }
    
    /**
     Get a professor name by using the section lookup table by course.
     Initiate search by using a course
     
     @return the professor's name; returns None if their is not a professor listed for the respective course
     */
    public func getProfessorNameByCourse(course: String) -> String {
        return m_courseDict[m_sectionLookupBycourse[course]!]![PROF_NAME] ?? "None"
    }
    
    /**
     Get the current system date in the format of MM/DD/YYYY
     
     @return the current system date
     */
    public func getCurrentDate() -> String {
        return m_currentDate
    }
    
    /**
     Get a student's first name given a student id
     @return the respective student's first name
     */
    public func getStudentFNameById(id: String) -> String {
        // Detect if the user is querying with an M appended to student id, i.e., M20240084 and only use 20240084 if so
        let usableID = id.lowercased().index(of: "m") == nil ? id : String(id.suffix(id.count - 1))
        
        let fullName = m_studentDict[usableID]![STUDENT_NAME]?.first
        return String(fullName!.split(separator: " ")[0])
    }
    
    /**
     Get a student's last name given a student id
     @return the respective student's last name
     */
    public func getStudentLNameById(id: String) -> String {
        // Detect if the user is querying with an M appended to student id, i.e., M20240084 and only use 20240084 if so
        let usableID = id.lowercased().index(of: "m") == nil ? id : String(id.suffix(id.count - 1))
        
        let fullName = m_studentDict[usableID]![STUDENT_NAME]?.first
        return String(fullName!.split(separator: " ")[1])
    }
    
    /**
     A debugging function to test implementations and display desired data
     */
    public func dump() {
        for (index, _) in (m_mcDict[STUDENT_ID]?.enumerated())! {
            // First section of the Tutoring Slip document
            print("Student's First Name: \(m_mcDict[STUDENT_FNAME]![index]) \tLast Name: \(m_mcDict[STUDENT_LNAME]![index])")
            print("MC# M\(m_mcDict[STUDENT_ID]![index])")
            print("Course (E.g., ENGL101A): \(m_mcDict[COURSE]![index]) \tSection: \(m_mcDict[SECTION]![index])")
            print("Professor (LAST NAME, First name): \(m_mcDict[PROF_NAME]![index])")
            print("Date (MM/DD/YYYY): \(m_currentDate) \tCircle if:    Appointment      Referral      Group ")
            print("tutoring")
            print()
        }
    }
}
