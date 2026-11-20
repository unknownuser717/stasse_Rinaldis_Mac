import XCTest

final class stasse_rinaldisUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainTabsAreAvailable() {
        let app = launchApp()

        XCTAssertTrue(app.tabBars.buttons["Cards"].exists)
        XCTAssertTrue(app.tabBars.buttons["Arenas"].exists)
        XCTAssertTrue(app.tabBars.buttons["Stats"].exists)
    }

    @MainActor
    func testCardsListShowsSeededCards() {
        let app = launchApp()

        XCTAssertTrue(cardRow(26000000, in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(cardRow(26000001, in: app).exists)
        XCTAssertTrue(cardRow(28000000, in: app).exists)
    }

    @MainActor
    func testRarityFilterAndAllChipShowExpectedCards() {
        let app = launchApp()

        app.buttons["rarity-filter-common"].tap()
        XCTAssertTrue(cardRow(26000000, in: app).exists)
        XCTAssertTrue(cardRow(26000001, in: app).exists)
        XCTAssertFalse(cardRow(28000000, in: app).exists)

        app.buttons["rarity-filter-tous"].tap()
        XCTAssertTrue(cardRow(28000000, in: app).exists)
    }

    @MainActor
    func testSearchFiltersCardsByName() {
        let app = launchApp()
        let searchField = app.searchFields.firstMatch

        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Knight")

        XCTAssertTrue(cardRow(26000000, in: app).exists)
        XCTAssertFalse(cardRow(26000001, in: app).exists)
        XCTAssertFalse(cardRow(28000000, in: app).exists)
    }

    @MainActor
    func testElixirSortPutsLowerCostCardsFirst() {
        let app = launchApp()
        let sortPicker = app.segmentedControls["card-sort-picker"]

        XCTAssertTrue(sortPicker.waitForExistence(timeout: 5))
        sortPicker.buttons["Elixir"].tap()

        let archers = cardRow(26000001, in: app)
        let knight = cardRow(26000000, in: app)
        let fireball = cardRow(28000000, in: app)
        XCTAssertTrue(archers.exists && knight.exists && fireball.exists)
        XCTAssertLessThan(archers.frame.minY, fireball.frame.minY)
        XCTAssertLessThan(knight.frame.minY, fireball.frame.minY)
    }

    @MainActor
    func testSelectingCardOpensItsDetails() {
        let app = launchApp()
        let knight = cardRow(26000000, in: app)

        XCTAssertTrue(knight.waitForExistence(timeout: 5))
        knight.tap()

        XCTAssertTrue(app.staticTexts["STATISTIQUES"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Niveau maximum"].exists)
        XCTAssertTrue(app.staticTexts["A tough melee fighter."].exists)
        XCTAssertTrue(app.navigationBars["Knight"].exists)
    }

    @MainActor
    func testArenaListHidesUnusedArenasAndShowsEmptyState() {
        let app = launchApp()
        app.tabBars.buttons["Arenas"].tap()

        XCTAssertTrue(app.staticTexts["Training Camp"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Bone Pit"].exists)
        XCTAssertFalse(app.staticTexts["Unused Arena"].exists)

        arenaRow(2, in: app).tap()
        XCTAssertTrue(app.staticTexts["No cards for this arena"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testArenaDetailShowsCardsUnlockedThere() {
        let app = launchApp()
        app.tabBars.buttons["Arenas"].tap()

        let trainingCamp = arenaRow(1, in: app)
        XCTAssertTrue(trainingCamp.waitForExistence(timeout: 5))
        trainingCamp.tap()

        XCTAssertTrue(app.staticTexts["CARDS UNLOCKED"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Knight"].exists)
    }

    @MainActor
    func testStatsShowTotalsAverageAndRarityBreakdown() {
        let app = launchApp()
        app.tabBars.buttons["Stats"].tap()

        XCTAssertTrue(app.staticTexts["Total Cartes"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Elixir Moyen"].exists)
        XCTAssertTrue(app.staticTexts["PAR RARETÉ"].exists)
        XCTAssertTrue(app.staticTexts["PAR TYPE"].exists)
        XCTAssertTrue(app.staticTexts["3.3"].exists)
        XCTAssertTrue(app.staticTexts["Common"].exists)
        XCTAssertTrue(app.staticTexts["Rare"].exists)
    }

    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["-ui-testing"]
            app.launch()
        }
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    @MainActor
    private func cardRow(_ id: Int, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["card-row-\(id)"]
    }

    @MainActor
    private func arenaRow(_ id: Int, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["arena-row-\(id)"]
    }
}
