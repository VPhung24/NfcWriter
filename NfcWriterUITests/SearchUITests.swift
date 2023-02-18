//
//  SearchUITests.swift
//  NfcWriterUITests
//
//  Created by Vivian Phung on 10/19/22.
//

import XCTest

final class SearchUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        app.buttons["twitter"].tap()
        app.tables["Empty list"].searchFields["search for twitter handle"].tap()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testSearch() throws {
        // This is an example test method.
        let app = XCUIApplication()

        app.keys["T"].tap()
        app.keys["w"].tap()
        app.keys["i"].tap()
        app.keys["t"].tap()
        app.keys["t"].tap()
        app.keys["e"].tap()
        app.keys["r"].tap()

        snapshot("01SearchTwitterHandle")

        app.tables.element.cells.element(boundBy: 0).tap()

        snapshot("02TwitterProfile")
    }

    func testProfileView() throws {
        let app = XCUIApplication()

        app.keys["T"].tap()

        app.tables.element.cells.element(boundBy: 4).tap()

        snapshot("03TwitterProfileT")
    }

    func testTwitterVC() {

        let app = XCUIApplication()

        app.keys["H"].tap()
        app.keys["e"].tap()
        app.keys["l"].tap()
        app.keys["l"].tap()
        app.keys["o"].tap()

    }
}
