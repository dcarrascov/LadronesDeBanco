import SwiftUI
import PhotosUI

/// Foto de perfil, o las iniciales si no hay foto.
struct AvatarView: View {
    let iniciales: String
    var foto: Data?
    var tamano: CGFloat = 42

    var body: some View {
        if let foto, let imagen = UIImage(data: foto) {
            Image(uiImage: imagen)
                .resizable()
                .scaledToFill()
                .frame(width: tamano, height: tamano)
                .clipShape(Circle())
        } else {
            Text(iniciales.isEmpty ? "?" : iniciales)
                .font(.system(size: tamano * 0.38, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .frame(width: tamano, height: tamano)
                .background(Color.accentColor.opacity(0.15), in: Circle())
        }
    }
}

/// Avatar que al tocarlo abre la fototeca para elegir o cambiar la foto.
struct SelectorFotoView: View {
    @Binding var foto: Data?
    let iniciales: String
    var tamano: CGFloat = 88

    @State private var seleccion: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            PhotosPicker(selection: $seleccion, matching: .images) {
                AvatarView(iniciales: iniciales, foto: foto, tamano: tamano)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: tamano * 0.3))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.accentColor)
                            .background(Circle().fill(.background).padding(2))
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(foto == nil ? "Añadir foto" : "Cambiar foto")

            if foto != nil {
                Button("Quitar foto", role: .destructive) {
                    foto = nil
                }
                .font(.footnote)
                .buttonStyle(.borderless)
            }
        }
        .onChange(of: seleccion) { _, nuevo in
            guard let nuevo else { return }
            Task {
                if let datos = try? await nuevo.loadTransferable(type: Data.self),
                   let lista = Fotos.preparar(datos) {
                    foto = lista
                }
                seleccion = nil
            }
        }
    }
}

enum Fotos {
    /// Recorta la imagen en cuadrado y la reduce a 400×400 en JPEG para no llenar el iPhone.
    static func preparar(_ datos: Data, lado: CGFloat = 400) -> Data? {
        guard let imagen = UIImage(data: datos), imagen.size.width > 0, imagen.size.height > 0 else { return nil }
        let escala = lado / min(imagen.size.width, imagen.size.height)
        let tamano = CGSize(width: imagen.size.width * escala, height: imagen.size.height * escala)

        let formato = UIGraphicsImageRendererFormat()
        formato.scale = 1
        let recortada = UIGraphicsImageRenderer(size: CGSize(width: lado, height: lado), format: formato).image { _ in
            imagen.draw(in: CGRect(
                x: (lado - tamano.width) / 2,
                y: (lado - tamano.height) / 2,
                width: tamano.width,
                height: tamano.height
            ))
        }
        return recortada.jpegData(compressionQuality: 0.8)
    }
}
