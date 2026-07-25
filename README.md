# Grand Line Wanted 🏴‍☠️ - One Piece Bounty Book

¡Bienvenido al **Grand Line Wanted**! Esta es una aplicación móvil desarrollada con **Flutter** que funciona como el libro oficial de recompensas de la Marina del Gobierno Mundial de One Piece. 

La aplicación implementa un ciclo de vida **CRUD completo** (Crear, Leer, Actualizar y Eliminar personajes) consumiendo un endpoint RESTful externo en **MockAPI.io**.

---

## 🚀 Características Clave

*   **Consumo de API REST Real:** Operaciones HTTP reales (`GET`, `POST`, `PUT`, `DELETE`) en el servidor remoto de MockAPI para persistir los personajes creados y editados.
*   **Estética Premium "Pirata":** Diseño visual inspirado en pergaminos antiguos, texturas cálidas, y cabeceras elegantes utilizando las pautas de **Material 3**.
*   **Carteles de Se Busca (WANTED):** Tarjetas personalizadas que presentan la información esencial de cada pirata.
*   **Formateador de Recompensas:** Las cantidades de recompensa se muestran formateadas dinámicamente con separadores de miles y el símbolo oficial de Berries: `฿ 3,000,000,000`.
*   **Previsualización del Avatar en Tiempo Real:** Al registrar o editar un pirata, la interfaz muestra de forma dinámica la imagen cargada desde la URL ingresada a medida que escribes.
*   **Filtros Interactivos y Búsqueda:** Búsqueda rápida por nombre o rol, y chips de selección de tripulaciones ("Straw Hat Pirates", "Heart Pirates", "Red Hair Pirates", etc.).
*   **Skeleton Loading:** Transiciones de carga suaves gracias a tarjetas con animaciones de carga (*Skeleton Bounty Cards*).

---

## 🛠️ Arquitectura del Proyecto

El código sigue las mejores prácticas de estructuración de Flutter, manteniendo una clara separación de conceptos:

```text
lib/
├── models/
│   └── character_model.dart     # Modelo de datos y mapeo JSON
├── services/
│   └── character_service.dart   # Cliente de red y consumo de endpoints
└── pages/
    ├── character_list.dart      # Vista principal (carteles, filtros, búsqueda)
    └── character_form.dart      # Formulario de registro y edición (previsualización)
```

---

## 📡 API Endpoint

El servicio RESTful consumido es:
`https://6a63af61b30b52361e1a90a0.mockapi.io/op/v1/characters`

### Campos del Personaje:
*   `id` (String): Generado automáticamente por MockAPI.
*   `name` (String): Nombre del pirata.
*   `avatar` (String): URL de la imagen del personaje.
*   `crew` (String): Tripulación o facción a la que pertenece.
*   `role` (String): Puesto o rol en la tripulación (ej. Capitán, Espadachín).
*   `bounty` (num): Recompensa en Berries.
*   `devilFruit` (String): Fruta del Diablo consumida (opcional).

---

## ⚙️ Configuración y Ejecución Local

Sigue estos pasos para correr el proyecto en tu entorno de desarrollo local:

### Requisitos Previos:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado y configurado.
*   Dispositivo móvil físico conectado o un Emulador (ej: Android Pixel 8) iniciado.

### Instrucciones:

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/CristianStivenPusdaHernandez/one_piece_crud_flutter.git
    cd one_piece_crud_flutter
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Ejecutar la aplicación:**
    *   Para listar los dispositivos y emuladores conectados:
        ```bash
        flutter devices
        ```
    *   Ejecutar en tu dispositivo o emulador específico (ej: `emulator-5554`):
        ```bash
        flutter run -d emulator-5554
        ```

---

## 📝 Comandos Útiles en Ejecución

Mientras la app corre en tu terminal, puedes presionar:
*   `r`: Para realizar un **Hot Reload** rápido y aplicar cambios visuales en segundos.
*   `R`: Para hacer un **Hot Restart** y reiniciar el estado completo de la app.
*   `s`: Toma una captura de pantalla limpia de la aplicación y la guarda en la raíz del proyecto.
*   `q`: Detiene la ejecución y sale del emulador.
