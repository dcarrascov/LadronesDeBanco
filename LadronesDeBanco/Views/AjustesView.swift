import SwiftUI

struct AjustesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Ajustes.claveTema) private var tema: Tema = .sistema
    @AppStorage(Ajustes.claveMoneda) private var moneda = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Apariencia") {
                    Picker("Tema", selection: $tema) {
                        ForEach(Tema.allCases) { tema in
                            Text(tema.titulo).tag(tema)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    NavigationLink {
                        SelectorMonedaView(moneda: $moneda)
                    } label: {
                        LabeledContent("Moneda") {
                            Text(moneda.isEmpty ? "Automática (\(Ajustes.monedaDeLaRegion))" : moneda)
                        }
                    }
                } header: {
                    Text("Moneda")
                } footer: {
                    Text("Ejemplo: \(Decimal(1234.5).formatted(.currency(code: Ajustes.codigoMoneda)))")
                }

                Section {
                    HStack(spacing: 14) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ladrones de Banco").font(.headline)
                            Text("Versión \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

private struct SelectorMonedaView: View {
    @Binding var moneda: String
    @State private var busqueda = ""

    private static let frecuentes = ["USD", "EUR", "MXN", "PEN", "COP", "ARS", "CLP"]

    private static let todas: [String] = Locale.commonISOCurrencyCodes
        .sorted { Ajustes.nombreMoneda($0).localizedCompare(Ajustes.nombreMoneda($1)) == .orderedAscending }

    private var resultados: [String] {
        guard !busqueda.isEmpty else { return Self.todas }
        return Self.todas.filter {
            $0.localizedCaseInsensitiveContains(busqueda)
                || Ajustes.nombreMoneda($0).localizedCaseInsensitiveContains(busqueda)
        }
    }

    var body: some View {
        List {
            if busqueda.isEmpty {
                Section {
                    fila(codigo: "", titulo: "Automática", detalle: "Según Idioma y región: \(Ajustes.nombreMoneda(Ajustes.monedaDeLaRegion))")
                }
                Section("Frecuentes") {
                    ForEach(Self.frecuentes, id: \.self) { codigo in
                        fila(codigo: codigo)
                    }
                }
            }
            Section(busqueda.isEmpty ? "Todas" : "Resultados") {
                ForEach(resultados, id: \.self) { codigo in
                    fila(codigo: codigo)
                }
            }
        }
        .navigationTitle("Moneda")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $busqueda, prompt: "Buscar moneda")
    }

    private func fila(codigo: String, titulo: String? = nil, detalle: String? = nil) -> some View {
        Button {
            moneda = codigo
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(titulo ?? Ajustes.nombreMoneda(codigo))
                        .foregroundStyle(.primary)
                    Text(detalle ?? "\(codigo) · \(Ajustes.simboloMoneda(codigo))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if moneda == codigo {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

#Preview {
    AjustesView()
}
