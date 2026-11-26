import XCTest

/// Tests de l'écran de connexion Firebase.
/// L'app est lancée avec `-ui-testing-auth` : l'écran de connexion s'affiche
/// sans Firebase, donc aucun compte n'est créé et aucun réseau n'est utilisé.
final class AuthUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAuthScreenIsShownBeforeTheApp() {
        let app = launchApp()

        XCTAssertTrue(emailField(in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.secureTextFields["auth-password"].exists)
        XCTAssertTrue(app.buttons["auth-submit"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["auth-google"].exists)
        XCTAssertFalse(app.tabBars.buttons["Cards"].exists)
    }

    @MainActor
    func testMissingConfigurationWarningIsShown() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["auth-config-warning"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSignUpModeShowsConfirmationField() {
        let app = launchApp()
        XCTAssertTrue(emailField(in: app).waitForExistence(timeout: 5))

        XCTAssertFalse(app.secureTextFields["auth-password-confirm"].exists)
        XCTAssertTrue(app.buttons["Mot de passe oublié ?"].exists)

        app.segmentedControls["auth-mode-picker"].buttons["Inscription"].tap()

        XCTAssertTrue(app.secureTextFields["auth-password-confirm"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Mot de passe oublié ?"].exists)
        XCTAssertEqual(app.buttons["auth-submit"].label, "Créer un compte")
    }

    @MainActor
    func testInvalidEmailIsRejected() {
        let app = launchApp()
        fill(app, email: "pasunemail", password: "123456")

        app.buttons["auth-submit"].tap()

        XCTAssertEqual(message(in: app), "Saisissez une adresse email valide.")
    }

    @MainActor
    func testShortPasswordIsRejected() {
        let app = launchApp()
        fill(app, email: "test@test.com", password: "123")

        app.buttons["auth-submit"].tap()

        XCTAssertEqual(message(in: app), "Le mot de passe doit contenir au moins 6 caractères.")
    }

    @MainActor
    func testSignUpRejectsDifferentPasswords() {
        let app = launchApp()
        XCTAssertTrue(emailField(in: app).waitForExistence(timeout: 5))
        app.segmentedControls["auth-mode-picker"].buttons["Inscription"].tap()
        fill(app, email: "test@test.com", password: "123456")
        type("654321\n", into: app.secureTextFields["auth-password-confirm"])

        app.buttons["auth-submit"].tap()

        XCTAssertEqual(message(in: app), "Les mots de passe ne correspondent pas.")
    }

    @MainActor
    func testValidFormReachesFirebaseLayer() {
        let app = launchApp()
        fill(app, email: "test@test.com", password: "123456")

        app.buttons["auth-submit"].tap()

        // Firebase est désactivé dans ce mode : le formulaire valide arrive
        // jusqu'à AuthManager, qui répond par le message de configuration.
        XCTAssertEqual(
            message(in: app),
            "Firebase n'est pas configuré : ajoutez GoogleService-Info.plist au projet."
        )
        XCTAssertFalse(app.tabBars.buttons["Cards"].exists)
    }

    @MainActor
    func testForgotPasswordNeedsAValidEmail() {
        let app = launchApp()
        XCTAssertTrue(emailField(in: app).waitForExistence(timeout: 5))

        app.buttons["Mot de passe oublié ?"].tap()

        XCTAssertEqual(message(in: app), "Saisissez une adresse email valide.")
    }

    @MainActor
    func testSwitchingModeClearsTheError() {
        let app = launchApp()
        fill(app, email: "pasunemail", password: "123456")
        app.buttons["auth-submit"].tap()
        XCTAssertTrue(app.staticTexts["auth-message"].waitForExistence(timeout: 2))

        app.segmentedControls["auth-mode-picker"].buttons["Inscription"].tap()

        XCTAssertFalse(app.staticTexts["auth-message"].waitForExistence(timeout: 1))
    }

    // MARK: - Helpers

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-auth"]
        app.launch()
        return app
    }

    @MainActor
    private func emailField(in app: XCUIApplication) -> XCUIElement {
        app.textFields["auth-email"]
    }

    @MainActor
    private func fill(_ app: XCUIApplication, email: String, password: String) {
        XCTAssertTrue(emailField(in: app).waitForExistence(timeout: 5))
        type(email, into: emailField(in: app))
        // "\n" valide le champ et ferme le clavier, pour qu'il ne cache pas le bouton.
        type(password + "\n", into: app.secureTextFields["auth-password"])
    }

    @MainActor
    private func type(_ text: String, into field: XCUIElement) {
        field.tap()
        field.typeText(text)
    }

    @MainActor
    private func message(in app: XCUIApplication) -> String? {
        let element = app.staticTexts["auth-message"]
        guard element.waitForExistence(timeout: 3) else { return nil }
        return element.label
    }
}
