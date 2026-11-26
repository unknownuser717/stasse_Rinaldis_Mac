//
//  stasse_rinaldisUITestsLaunchTests.swift
//  stasse_rinaldisUITests
//
//  Created by Damien Rinaldis on 29/05/2026.
//

import XCTest

final class stasse_rinaldisUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        // La ligne de carte est un seul bouton (NavigationLink) : son texte n'est pas
        // toujours exposé comme un staticText séparé. On utilise son identifiant.
        XCTAssertTrue(app.descendants(matching: .any)["card-row-26000000"].waitForExistence(timeout: 10))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
