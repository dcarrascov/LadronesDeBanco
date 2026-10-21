import Foundation
import SwiftData

/// Datos en memoria para las vistas previas de Xcode.
@MainActor
enum DatosDeEjemplo {
    static let contenedor: ModelContainer = {
        let contenedor = try! ModelContainer(
            for: Persona.self, Movimiento.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = contenedor.mainContext

        let ejemplos: [(String, [(Decimal, TipoMovimiento, Int, String)])] = [
            ("Carlos Pérez", [(150, .prestamo, -20, "Cena del viernes"), (50, .pago, -5, "")]),
            ("Lucía Gómez", [(80, .prestamo, -3, "Entradas del concierto")]),
            ("Martín Ruiz", [(200, .prestamo, -40, "Alquiler"), (200, .pago, -10, "")]),
        ]
        for (nombre, movimientos) in ejemplos {
            let persona = Persona(nombre: nombre)
            context.insert(persona)
            for (monto, tipo, dias, nota) in movimientos {
                let fecha = Calendar.current.date(byAdding: .day, value: dias, to: .now) ?? .now
                let movimiento = Movimiento(monto: monto, tipo: tipo, fecha: fecha, nota: nota)
                context.insert(movimiento)
                movimiento.persona = persona
            }
        }
        return contenedor
    }()

    static var personaDeEjemplo: Persona {
        let descriptor = FetchDescriptor<Persona>(sortBy: [SortDescriptor(\.nombre)])
        return try! contenedor.mainContext.fetch(descriptor).first!
    }
}
