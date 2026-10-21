import SwiftUI
import SwiftData

/// Alta de una persona, opcionalmente con su primera deuda.
struct NuevaPersonaView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var telefono = ""
    @State private var montoTexto = ""
    @State private var nota = ""

    private var nombreLimpio: String { nombre.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationStack {
            Form {
                Section("¿Quién es?") {
                    TextField("Nombre", text: $nombre)
                        .textContentType(.name)
                    TextField("Teléfono (opcional)", text: $telefono)
                        .keyboardType(.phonePad)
                }
                Section {
                    TextField("Monto", text: $montoTexto)
                        .keyboardType(.decimalPad)
                    TextField("¿Para qué? (opcional)", text: $nota)
                } header: {
                    Text("¿Ya te debe algo?")
                } footer: {
                    Text("Puedes dejarlo vacío y registrar préstamos después.")
                }
            }
            .navigationTitle("Nuevo ladrón")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar)
                        .disabled(nombreLimpio.isEmpty)
                }
            }
        }
    }

    private func guardar() {
        let persona = Persona(nombre: nombreLimpio, telefono: telefono)
        context.insert(persona)
        if let monto = Decimal(texto: montoTexto), monto > 0 {
            let movimiento = Movimiento(monto: monto, tipo: .prestamo, nota: nota)
            context.insert(movimiento)
            movimiento.persona = persona
        }
        dismiss()
    }
}

/// Registrar un préstamo o un pago (total o parcial).
struct NuevoMovimientoView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let persona: Persona
    let tipo: TipoMovimiento

    @State private var montoTexto = ""
    @State private var fecha = Date.now
    @State private var nota = ""

    private var monto: Decimal? {
        guard let valor = Decimal(texto: montoTexto), valor > 0 else { return nil }
        return valor
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Monto", text: $montoTexto)
                        .keyboardType(.decimalPad)
                        .font(.title2.weight(.semibold))
                    if tipo == .pago && persona.saldo > 0 {
                        Button("Pagó todo (\(persona.saldo.moneda))") {
                            montoTexto = "\(persona.saldo)"
                        }
                    }
                } footer: {
                    if tipo == .pago, let monto, monto > persona.saldo, persona.saldo > 0 {
                        Text("Es más de lo que debe. Quedará \((monto - persona.saldo).moneda) a su favor.")
                    }
                }
                Section {
                    DatePicker("Fecha", selection: $fecha, in: ...Date.now, displayedComponents: .date)
                    TextField("Nota (opcional)", text: $nota)
                }
            }
            .navigationTitle(tipo == .prestamo ? "Le presté a \(persona.nombre)" : "\(persona.nombre) me pagó")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar)
                        .disabled(monto == nil)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func guardar() {
        guard let monto else { return }
        let movimiento = Movimiento(monto: monto, tipo: tipo, fecha: fecha, nota: nota)
        context.insert(movimiento)
        movimiento.persona = persona
        Task { await Recordatorios.actualizar(para: persona) }
        dismiss()
    }
}

/// Elegir cuándo recordarte que cobres.
struct RecordatorioView: View {
    @Environment(\.dismiss) private var dismiss

    let persona: Persona

    @State private var fecha: Date
    @State private var sinPermiso = false

    init(persona: Persona) {
        self.persona = persona
        let manana = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        let predeterminada = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: manana) ?? manana
        _fecha = State(initialValue: persona.tieneRecordatorioActivo ? persona.recordatorio! : predeterminada)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        atajo("Mañana", dias: 1)
                        atajo("En 3 días", dias: 3)
                        atajo("En 1 semana", dias: 7)
                    }
                    .buttonStyle(.bordered)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                Section {
                    DatePicker("Recordarme", selection: $fecha, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                } footer: {
                    Text("Recibirás: “\(persona.nombre) te debe \(persona.saldo.moneda).”")
                }
                if persona.tieneRecordatorioActivo {
                    Section {
                        Button("Quitar recordatorio", role: .destructive) {
                            Recordatorios.cancelar(para: persona)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            if await Recordatorios.programar(para: persona, en: fecha) {
                                dismiss()
                            } else {
                                sinPermiso = true
                            }
                        }
                    }
                }
            }
            .alert("Activa las notificaciones", isPresented: $sinPermiso) {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Ahora no", role: .cancel) {}
            } message: {
                Text("Para recordarte cobrar, Ladrones de Banco necesita permiso para enviarte notificaciones.")
            }
        }
    }

    private func atajo(_ titulo: String, dias: Int) -> some View {
        Button(titulo) {
            let dia = Calendar.current.date(byAdding: .day, value: dias, to: .now) ?? .now
            fecha = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: dia) ?? dia
        }
        .frame(maxWidth: .infinity)
    }
}
