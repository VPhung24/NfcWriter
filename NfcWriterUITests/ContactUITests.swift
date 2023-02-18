//
//  ContactUITests.swift
//  NfcWriterUITests
//
//  Created by Vivian Phung on 2/18/23.
//

import XCTest

final class ContactUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        UserDefaults.resetStandardUserDefaults()

        app.buttons["contact"].tap()

        continueAfterFailure = false
    }

//    func testContactEdit() throws {
//        let app = XCUIApplication()
//        app.navigationBars["CNContactView"].buttons["Edit"].tap()
//        snapshot("04Contact")
//    }
//
//    func testCreateContact() throws {
//        let app = XCUIApplication()
//
//        let firstnameTextField = app.secureTextFields["First name"]
//        firstnameTextField.tap()
//        firstnameTextField.typeText("Tim")
//
//        let lastnameTextField = app.textFields["Last name"]
//        lastnameTextField.tap()
//        lastnameTextField.typeText("Apple")
//    }

    func testFastlaneContactSnapshot() throws {
        let app = XCUIApplication()
        snapshot("04CreateContact")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
