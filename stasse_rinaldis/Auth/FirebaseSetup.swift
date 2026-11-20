import Foundation
import FirebaseCore

enum FirebaseSetup {
    /// Configure Firebase si GoogleService-Info.plist est présent dans l'app.
    /// Sans ce fichier, `FirebaseApp.configure()` ferait planter l'app : on renvoie `false`
    /// et l'écran de connexion affiche un message à la place.
    @discardableResult
    static func configureIfPossible() -> Bool {
        if FirebaseApp.app() != nil { return true }
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            print("⚠️ GoogleService-Info.plist introuvable : Firebase n'est pas configuré.")
            return false
        }
        FirebaseApp.configure()
        return true
    }
}
