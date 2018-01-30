//
//  ViewController.swift
//  RegistrationForm
//
//  Created by Biokod Lab on 26.01.2018.
//  Copyright © 2018 Biokod Lab. All rights reserved.
//

import UIKit
import SQLite3
import Foundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    var db: SQLiteDatabase!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        birthDateTextField.delegate = self
        passwordTextField.delegate = self
        
        nameTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        birthDateTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        
        registerButton.isUserInteractionEnabled = false
        registerButton.alpha = 0.6
        
        openDatabase()
        createTable()
        
    }
    
    //MARK: Actions
    
    @IBAction func saveFormData(_ sender: UIButton) {
        if checkRegisterFields() {
            insertData()
            readRegisterForm(numberOfRecords: 3)
        }
    }
    
    //MARK: Database
    
    //Open database
    func openDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("RegisterForm.sqlite").relativePath
    
        do {
            db = try SQLiteDatabase.open(path: fileURL)
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
        } catch {
            
        }
    }
    
    //Create table
    func createTable() {
        do {
            try db.createTable(table: RegisterForm.self)
        } catch {
            print(db.errorMessage)
        }
    }
    
    //Insert Data
    
    func insertData() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let birthDate = birthDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try db.insertRegisterForm(registerForm: RegisterForm(name: name!, lastName: lastName!, email: email!, birthDate: birthDate!, password: password!))
        } catch {
            print(db.errorMessage)
        }
    }
    
    //Drop Table
    
    func dropRegisterFormTable() {
        do {
            try db.dropTable()
        } catch {
            print(db.errorMessage)
        }
    }
    
    //MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showGreeting" {
            return checkRegisterFields()
        }
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            birthDateTextField.becomeFirstResponder()
        case birthDateTextField:
            passwordTextField.becomeFirstResponder()
        default:
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: Validation
    
    func checkRegisterFields() -> Bool{
        let fields = [nameTextField, lastNameTextField, emailTextField, birthDateTextField, passwordTextField]
        
        for field in fields {
            let validatedField = validateRegisterField(textField: field!)
            if validatedField != nil {
                displayAlert(message: validatedField!)
                return false
            }
        }
        return true
    }
    
    func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func validateRegisterField(textField: UITextField) -> String? {
        guard let text = textField.text else {
            return nil
        }
        
        switch textField {
        case nameTextField:
            let nameFormat = "^[a-zA-Z]+$"
            let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameFormat)
            if !namePredicate.evaluate(with: text)  {
                return "Name can only contain letters"
            }
        case lastNameTextField:
            let lastNameFormat = "^[a-zA-Z]+$"
            let lastNamePredicate = NSPredicate(format:"SELF MATCHES %@", lastNameFormat)
            if !lastNamePredicate.evaluate(with: text)  {
                return "Lastname can only contain letters"
            }
        case emailTextField:
            let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
            if !emailPredicate.evaluate(with: text) {
                return "Wrong email format \n Your email must look like: email@example.com"
            }
        case birthDateTextField:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if dateFormatter.date(from: text) == nil {
                return "Wrong birth date format \n Valid format: year-month-day"
            }
        case passwordTextField:
            if text.count < 8 {
                return "Your password is too short. \n Password must have at least 8 characters"
            }
        default:
            return nil
        }
        
        return nil
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let name = nameTextField.text, !name.isEmpty,
            let lastName = lastNameTextField.text, !lastName.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let birthDate = birthDateTextField.text, !birthDate.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            registerButton.isUserInteractionEnabled = false
            registerButton.alpha = 0.6
            return
        }
        registerButton.isUserInteractionEnabled = true
        registerButton.alpha = 1
    }
    
    //MARK: Read Sample Data
    func readRegisterForm(numberOfRecords: Int) {
        for id in 1..<numberOfRecords + 1 {
            print(db.registerForm(id: Int32(id)))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: Database
enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

struct RegisterForm {
    
    let name: String
    let lastName: String
    let email: String
    let birthDate: String
    let password: String
}

//Database Connection
class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    
    private init(dbPointer: OpaquePointer) {
        self.dbPointer = dbPointer
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db!)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let message: String? = String(cString: sqlite3_errmsg(db)!) {
                throw SQLiteError.OpenDatabase(message: message!)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    var errorMessage: String {
        if let errorMessage: String? = String(cString: sqlite3_errmsg(dbPointer)!) {
            return errorMessage!
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    func prepareStatement(sql: String) throws -> OpaquePointer {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement!
    }
    
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer {
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("\(table) table created.")
    }
    
    func insertRegisterForm(registerForm: RegisterForm) throws {
        let insertSql = "INSERT INTO RegisterForm (name, lastName, email, birthDate, password) VALUES (?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }

        let name: NSString = registerForm.name as NSString
        let lastName: NSString = registerForm.lastName as NSString
        let email: NSString = registerForm.email as NSString
        let birthDate: NSString = registerForm.birthDate as NSString
        let password: NSString = registerForm.password as NSString
        guard
            sqlite3_bind_text(insertStatement, 1, name.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, lastName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, email.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, birthDate.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, password.utf8String, -1, nil) == SQLITE_OK else {
                throw SQLiteError.Bind(message: errorMessage)
        }

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }

        print("Successfully inserted row.")
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
}

protocol SQLTable {
    static var createStatement: String { get }
}

extension RegisterForm: SQLTable {
    static var createStatement: String {
        return "CREATE TABLE RegisterForm(" +
            "Id INTEGER PRIMARY KEY AUTOINCREMENT," +
            "name CHAR(255)," +
            "lastName CHAR(255)," +
            "email CHAR(255)," +
            "birthDate CHAR(255)," +
            "password CHAR(255)" +
        ");"
    }
}

//Read Register Form
extension SQLiteDatabase {
    func registerForm(id: Int32) -> RegisterForm? {
        let querySql = "SELECT * FROM RegisterForm WHERE Id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }

        defer {
            sqlite3_finalize(queryStatement)
        }

        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            return nil
        }

        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }

        let id = sqlite3_column_int(queryStatement, 0)

        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
        let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
        let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
        let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
        let queryResultCol5 = sqlite3_column_text(queryStatement, 5)
        
        let name = String(cString: queryResultCol1!)
        let lastName = String(cString: queryResultCol2!)
        let email = String(cString: queryResultCol3!)
        let birthDate = String(cString: queryResultCol4!)
        let password = String(cString: queryResultCol5!)

        return RegisterForm(name: name, lastName: lastName, email: email, birthDate: birthDate, password: password)
    }
}

extension SQLiteDatabase {
    func dropTable() throws {
        let querySql = "DROP TABLE IF EXISTS RegisterForm;"
        let dropTableStatement = try prepareStatement(sql: querySql)
        // 2
        defer {
            sqlite3_finalize(dropTableStatement)
        }
        // 3
        guard sqlite3_step(dropTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("Table was successfully dropped.")
    }
}
