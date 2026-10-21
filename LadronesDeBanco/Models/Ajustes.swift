import SwiftUI

/// Preferencias guardadas en el iPhone (UserDefaults, vía @AppStorage).
enum Ajustes {
    static let claveTema = "tema"
    /// Código ISO de la moneda elegida; vacío significa "según Idioma y región".
    static let claveMoneda = "moneda"

    static var monedaDeLaRegion: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    static var codigoMoneda: String {
        let elegida = UserDefaults.standard.string(forKey: claveMoneda) ?? ""
        return elegida.isEmpty ? monedaDeLaRegion : elegida
    }

    static func nombreMoneda(_ codigo: String) -> String {
        Locale.current.localizedString(forCurrencyCode: codigo)?.capitalized(with: Locale.current) ?? codigo
    }

    static func simboloMoneda(_ codigo: String) -> String {
        let formato = NumberFormatter()
        formato.numberStyle = .currency
        formato.currencyCode = codigo
        return formato.currencySymbol ?? codigo
    }
}

enum Tema: String, CaseIterable, Identifiable {
    case sistema
    case claro
    case oscuro

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .sistema: "Automático"
        case .claro: "Claro"
        case .oscuro: "Oscuro"
        }
    }

    var esquema: ColorScheme? {
        switch self {
        case .sistema: nil
        case .claro: .light
        case .oscuro: .dark
        }
    }
}
