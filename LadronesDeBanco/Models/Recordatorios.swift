import Foundation
import UserNotifications

/// Notificaciones locales para recordarte cobrar.
@MainActor
enum Recordatorios {
    private static var centro: UNUserNotificationCenter { .current() }

    static func pedirPermiso() async -> Bool {
        (try? await centro.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Programa (o reemplaza) el recordatorio de la persona. Devuelve false si no hay permiso.
    @discardableResult
    static func programar(para persona: Persona, en fecha: Date) async -> Bool {
        guard await pedirPermiso() else { return false }

        let contenido = UNMutableNotificationContent()
        contenido.title = "¡Hora de cobrar! 💰"
        contenido.body = "\(persona.nombre) te debe \(persona.saldo.moneda)."
        contenido.sound = .default

        let componentes = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
        let disparador = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
        let solicitud = UNNotificationRequest(identifier: identificador(persona), content: contenido, trigger: disparador)

        do {
            try await centro.add(solicitud)
            persona.recordatorio = fecha
            return true
        } catch {
            return false
        }
    }

    static func cancelar(para persona: Persona) {
        centro.removePendingNotificationRequests(withIdentifiers: [identificador(persona)])
        persona.recordatorio = nil
    }

    /// Mantiene el recordatorio coherente después de registrar un movimiento:
    /// si ya no debe nada se cancela; si sigue debiendo se actualiza el monto del mensaje.
    static func actualizar(para persona: Persona) async {
        guard let fecha = persona.recordatorio else { return }
        if persona.saldo <= 0 || fecha <= .now {
            cancelar(para: persona)
        } else {
            await programar(para: persona, en: fecha)
        }
    }

    private static func identificador(_ persona: Persona) -> String {
        "recordatorio-\(persona.uid.uuidString)"
    }
}
