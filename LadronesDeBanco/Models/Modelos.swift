import Foundation
import SwiftData

/// Alguien que te debe (o te debió) dinero.
@Model
final class Persona {
    var uid: UUID
    var nombre: String
    var telefono: String
    var creadaEn: Date
    /// Foto de perfil ya recortada y comprimida (ver `Fotos.preparar`).
    @Attribute(.externalStorage) var foto: Data?
    /// Fecha del recordatorio de cobro pendiente, si hay uno.
    var recordatorio: Date?

    @Relationship(deleteRule: .cascade, inverse: \Movimiento.persona)
    var movimientos: [Movimiento] = []

    init(nombre: String, telefono: String = "") {
        self.uid = UUID()
        self.nombre = nombre
        self.telefono = telefono
        self.creadaEn = .now
    }

    /// Positivo: te debe. Cero: al día. Negativo: pagó de más.
    var saldo: Decimal {
        movimientos.reduce(0) { total, m in
            m.tipo == .prestamo ? total + m.monto : total - m.monto
        }
    }

    var ultimoMovimiento: Date? {
        movimientos.map(\.fecha).max()
    }

    var iniciales: String {
        let partes = nombre.split(separator: " ").prefix(2)
        return partes.compactMap(\.first).map(String.init).joined().uppercased()
    }

    var tieneRecordatorioActivo: Bool {
        guard let recordatorio else { return false }
        return recordatorio > .now
    }
}

enum TipoMovimiento: String, Codable, CaseIterable, Identifiable {
    case prestamo
    case pago

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .prestamo: "Le presté"
        case .pago: "Me pagó"
        }
    }

    var icono: String {
        switch self {
        case .prestamo: "arrow.up.right.circle.fill"
        case .pago: "arrow.down.left.circle.fill"
        }
    }
}

/// Un préstamo que hiciste o un pago (total o parcial) que recibiste.
@Model
final class Movimiento {
    var monto: Decimal
    var tipoRaw: String
    var fecha: Date
    var nota: String
    var persona: Persona?

    init(monto: Decimal, tipo: TipoMovimiento, fecha: Date = .now, nota: String = "") {
        self.monto = monto
        self.tipoRaw = tipo.rawValue
        self.fecha = fecha
        self.nota = nota
    }

    var tipo: TipoMovimiento {
        get { TipoMovimiento(rawValue: tipoRaw) ?? .prestamo }
        set { tipoRaw = newValue.rawValue }
    }
}

extension Decimal {
    var moneda: String {
        formatted(.currency(code: Ajustes.codigoMoneda))
    }

    /// Acepta "12,50" o "12.50".
    init?(texto: String) {
        let limpio = texto
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard !limpio.isEmpty, let valor = Decimal(string: limpio) else { return nil }
        self = valor
    }
}
