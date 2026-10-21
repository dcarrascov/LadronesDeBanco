import SwiftUI
import SwiftData
import UserNotifications

@main
struct LadronesDeBancoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(Ajustes.claveTema) private var tema: Tema = .sistema

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(tema.esquema)
        }
        .modelContainer(for: [Persona.self, Movimiento.self])
    }
}

/// Permite ver los recordatorios aunque la app esté abierta.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
