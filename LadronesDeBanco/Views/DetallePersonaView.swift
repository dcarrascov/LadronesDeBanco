import SwiftUI
import SwiftData

/// Saldo, recordatorio e historial de una persona.
struct DetallePersonaView: View {
    @Environment(\.modelContext) private var context
    @Bindable var persona: Persona

    @State private var nuevoMovimiento: TipoMovimiento?
    @State private var editandoRecordatorio = false

    private var movimientosOrdenados: [Movimiento] {
        persona.movimientos.sorted { $0.fecha > $1.fecha }
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    SelectorFotoView(foto: $persona.foto, iniciales: persona.iniciales, tamano: 80)
                    VStack(spacing: 2) {
                        Text(tituloSaldo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(abs(persona.saldo).moneda)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(persona.saldo > 0 ? Color.red : Color.primary)
                            .contentTransition(.numericText())
                    }
                    HStack(spacing: 12) {
                        Button {
                            nuevoMovimiento = .prestamo
                        } label: {
                            Label(TipoMovimiento.prestamo.titulo, systemImage: TipoMovimiento.prestamo.icono)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            nuevoMovimiento = .pago
                        } label: {
                            Label(TipoMovimiento.pago.titulo, systemImage: TipoMovimiento.pago.icono)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("Recordatorio") {
                Button {
                    editandoRecordatorio = true
                } label: {
                    HStack {
                        Label {
                            if let fecha = persona.recordatorio, persona.tieneRecordatorioActivo {
                                Text(fecha, format: .dateTime.weekday(.wide).day().month().hour().minute())
                            } else {
                                Text("Programar recordatorio de cobro")
                            }
                        } icon: {
                            Image(systemName: persona.tieneRecordatorioActivo ? "bell.fill" : "bell")
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .tint(.primary)
                .disabled(persona.saldo <= 0)
            }

            Section("Historial") {
                if movimientosOrdenados.isEmpty {
                    Text("Todavía no hay movimientos.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(movimientosOrdenados) { movimiento in
                        FilaMovimientoView(movimiento: movimiento)
                    }
                    .onDelete(perform: borrarMovimientos)
                }
            }
        }
        .navigationTitle(persona.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: persona.saldo)
        .sheet(item: $nuevoMovimiento) { tipo in
            NuevoMovimientoView(persona: persona, tipo: tipo)
        }
        .sheet(isPresented: $editandoRecordatorio) {
            RecordatorioView(persona: persona)
        }
    }

    private var tituloSaldo: String {
        if persona.saldo > 0 { return "Te debe" }
        if persona.saldo == 0 { return "Está al día 🎉" }
        return "Te pagó de más"
    }

    private func borrarMovimientos(en indices: IndexSet) {
        for indice in indices {
            context.delete(movimientosOrdenados[indice])
        }
        try? context.save()
        Task { await Recordatorios.actualizar(para: persona) }
    }
}

private struct FilaMovimientoView: View {
    let movimiento: Movimiento

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: movimiento.tipo.icono)
                .font(.title2)
                .foregroundStyle(movimiento.tipo == .prestamo ? Color.red : Color.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(movimiento.nota.isEmpty ? movimiento.tipo.titulo : movimiento.nota)
                    .font(.body)
                Text(movimiento.fecha, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text((movimiento.tipo == .prestamo ? "+" : "−") + movimiento.monto.moneda)
                .font(.body.monospacedDigit())
                .foregroundStyle(movimiento.tipo == .prestamo ? Color.red : Color.green)
        }
    }
}

#Preview {
    NavigationStack {
        DetallePersonaView(persona: DatosDeEjemplo.personaDeEjemplo)
    }
    .modelContainer(DatosDeEjemplo.contenedor)
}
