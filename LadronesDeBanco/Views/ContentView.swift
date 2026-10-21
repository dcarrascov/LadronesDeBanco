import SwiftUI
import SwiftData

/// Pantalla principal: cuánto te deben en total y quién.
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Persona.nombre) private var personas: [Persona]

    /// Se observa para redibujar los montos al cambiar de moneda.
    @AppStorage(Ajustes.claveMoneda) private var moneda = ""

    @State private var mostrandoNuevaPersona = false
    @State private var mostrandoAjustes = false
    @State private var busqueda = ""

    private var personasFiltradas: [Persona] {
        let base = busqueda.isEmpty
            ? personas
            : personas.filter { $0.nombre.localizedCaseInsensitiveContains(busqueda) }
        return base.sorted { $0.saldo > $1.saldo }
    }

    private var deudores: [Persona] {
        personas.filter { $0.saldo > 0 }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ResumenView(
                        total: deudores.map(\.saldo).reduce(0, +),
                        cantidadDeudores: deudores.count
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                if !personas.isEmpty {
                    Section("Ladrones") {
                        ForEach(personasFiltradas) { persona in
                            NavigationLink(value: persona) {
                                FilaPersonaView(persona: persona)
                            }
                        }
                        .onDelete(perform: borrar)
                    }
                }
            }
            .id(moneda)
            .navigationTitle("Ladrones de Banco")
            .navigationDestination(for: Persona.self) { persona in
                DetallePersonaView(persona: persona)
            }
            .searchable(text: $busqueda, prompt: "Buscar persona")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        mostrandoAjustes = true
                    } label: {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoNuevaPersona = true
                    } label: {
                        Label("Agregar persona", systemImage: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $mostrandoNuevaPersona) {
                NuevaPersonaView()
            }
            .sheet(isPresented: $mostrandoAjustes) {
                AjustesView()
            }
            .overlay {
                if personas.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("Nadie te debe… aún")
                        } icon: {
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                        }
                    } description: {
                        Text("Toca \(Image(systemName: "person.badge.plus")) para agregar a tu primer ladrón.")
                    }
                    .padding(.top, 160)
                }
            }
        }
    }

    private func borrar(en indices: IndexSet) {
        for indice in indices {
            let persona = personasFiltradas[indice]
            Recordatorios.cancelar(para: persona)
            context.delete(persona)
        }
    }
}

private struct ResumenView: View {
    let total: Decimal
    let cantidadDeudores: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Te deben en total")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(total.moneda)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .contentTransition(.numericText())
                Text(cantidadDeudores == 1 ? "1 persona con deuda pendiente" : "\(cantidadDeudores) personas con deuda pendiente")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 84)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .padding(.bottom, -6)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

struct FilaPersonaView: View {
    let persona: Persona

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(iniciales: persona.iniciales, foto: persona.foto)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(persona.nombre).font(.body.weight(.semibold))
                    if persona.tieneRecordatorioActivo {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                Group {
                    if let fecha = persona.ultimoMovimiento {
                        Text("Último movimiento \(fecha, format: .relative(presentation: .named))")
                    } else {
                        Text("Sin movimientos")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            SaldoEtiqueta(saldo: persona.saldo)
        }
        .padding(.vertical, 4)
    }
}

struct SaldoEtiqueta: View {
    let saldo: Decimal

    var body: some View {
        if saldo > 0 {
            Text(saldo.moneda)
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(.red)
        } else if saldo == 0 {
            Text("Al día")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15), in: Capsule())
                .foregroundStyle(.green)
        } else {
            Text("A favor \((-saldo).moneda)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DatosDeEjemplo.contenedor)
}
