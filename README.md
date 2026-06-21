# Combinar Etiquetas ML — Android

> **[English version below](#english)**

Aplicación Android para combinar etiquetas PDF de Mercado Libre en hojas A4 apaisadas, con 3 etiquetas por página, listas para imprimir.

## ¿Para qué sirve?

Mercado Libre genera una etiqueta PDF por cada venta. Esta app te permite seleccionar varias etiquetas, combinarlas en un solo PDF con 3 por hoja A4 apaisada y compartirlo para imprimir — todo desde el teléfono.

## Características

- Seleccioná múltiples PDFs en el orden que querés
- 3 etiquetas por hoja A4 apaisada
- Recorte automático del espacio en blanco de cada etiqueta
- Si la última hoja tiene menos de 3, las etiquetas se alinean a la derecha
- Compartí el PDF generado por WhatsApp, Gmail, Google Drive o cualquier app
- Tema oscuro con los colores de Mercado Libre

## Requisitos

- Android 8.0 o superior (API 26+)

## Instalación

### Opción 1 — APK directo
Descargá el APK desde la sección [Releases](../../releases) e instalalo en tu dispositivo.

### Opción 2 — Compilar desde el código fuente
1. Instalá [Flutter](https://flutter.dev/docs/get-started/install) (versión estable)
2. Cloná el repositorio:
   ```
   git clone https://github.com/glaporte777-tbg/combinador-etiquetas-meli-android.git
   ```
3. Instalá las dependencias:
   ```
   flutter pub get
   ```
4. Corré la app:
   ```
   flutter run
   ```

## Cómo usar

1. Abrí la app
2. Tocá **+ Agregar** y seleccioná los PDFs de tus etiquetas
3. Ordenalas como querés que aparezcan en la hoja
4. Tocá **Generar hoja A4**
5. Compartí o guardá el PDF generado

## Tecnologías

- [Flutter](https://flutter.dev/) / Dart
- [pdfrx](https://pub.dev/packages/pdfrx) — renderizado de PDF
- [pdf](https://pub.dev/packages/pdf) — generación de PDF
- [file\_picker](https://pub.dev/packages/file_picker) — selección de archivos
- [share\_plus](https://pub.dev/packages/share_plus) — compartir el resultado

## Licencia

El código fuente está bajo licencia MIT — ver [LICENSE](LICENSE).

Los assets de marca (`assets/logo.png`, `assets/icon.png`) son propiedad de Thunderbolt.arg. Todos los derechos reservados. No están incluidos en la licencia MIT y no pueden ser usados, copiados ni distribuidos sin autorización.

---

<a name="english"></a>

# Combinar Etiquetas ML — Android

Android app to combine Mercado Libre shipping label PDFs into A4 landscape pages, 3 labels per page, ready to print.

## What does it do?

Mercado Libre generates one PDF label per sale. This app lets you select multiple labels, combine them into a single PDF with 3 labels per A4 landscape page, and share it for printing — all from your phone.

## Features

- Select multiple PDFs in any order
- 3 labels per A4 landscape page
- Automatic whitespace cropping on each label
- Last page right-aligns labels if fewer than 3
- Share the generated PDF via WhatsApp, Gmail, Google Drive or any app
- Dark theme with Mercado Libre colors

## Requirements

- Android 8.0 or higher (API 26+)

## Installation

### Option 1 — Direct APK
Download the APK from the [Releases](../../releases) section and install it on your device.

### Option 2 — Build from source
1. Install [Flutter](https://flutter.dev/docs/get-started/install) (stable channel)
2. Clone the repository:
   ```
   git clone https://github.com/glaporte777-tbg/combinador-etiquetas-meli-android.git
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## How to use

1. Open the app
2. Tap **+ Agregar** and select your label PDFs
3. Arrange them in the order you want
4. Tap **Generar hoja A4**
5. Share or save the generated PDF

## Tech stack

- [Flutter](https://flutter.dev/) / Dart
- [pdfrx](https://pub.dev/packages/pdfrx) — PDF rendering
- [pdf](https://pub.dev/packages/pdf) — PDF generation
- [file\_picker](https://pub.dev/packages/file_picker) — file selection
- [share\_plus](https://pub.dev/packages/share_plus) — share output

## License

The source code is licensed under MIT — see [LICENSE](LICENSE).

Brand assets (`assets/logo.png`, `assets/icon.png`) are property of Thunderbolt.arg. All rights reserved. They are not covered by the MIT license and may not be used, copied or distributed without authorization.
