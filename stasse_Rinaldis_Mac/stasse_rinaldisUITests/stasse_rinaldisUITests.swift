//
//  stasse_rinaldisUITests.swift
//  stasse_rinaldisUITests
//
//  Created by Damien Rinaldis on 29/05/2026.
//

import XCTest

final class stasse_rinaldisUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testMainTabsAreAvailable() throws {
        let app = XCUIApplication()
        app.launch()

        let cardsTab = app.tabBars.buttons["Cards"]
        let arenasTab = app.tabBars.buttons["Arenas"]
        let statsTab = app.tabBars.buttons["Stats"]

        XCTAssertTrue(cardsTab.waitForExistence(timeout: 5))
        XCTAssertTrue(arenasTab.exists)
        XCTAssertTrue(statsTab.exists)

        statsTab.tap()
        XCTAssertTrue(app.staticTexts["Total Cartes"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
