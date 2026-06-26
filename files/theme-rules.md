# Guía de Sistema de Diseño y UI - Proyecto Centralis

Este documento contiene las reglas estrictas de diseño, paleta de colores, tipografía y mapeo de componentes para la interfaz de usuario de la aplicación Centralis.

## 1. Tokens de Diseño (Design Tokens)

### 1.1 Paleta de Colores
Utilizar estrictamente estos valores hexadecimales para construir la interfaz. Evitar degradados complejos a menos que se especifique en los recursos de imagen.

*   **Primary:** `#556973` (Gris Pizarra / Azul Oscuro). Uso: Acciones principales, botones primarios (FAB), enlaces interactivos y estados activos.
*   **Secondary:** `#B4BFC4` (Gris Azul Claro). Uso: Fondos de tarjetas secundarias, contenedores de iconos, fondos de botones secundarios.
*   **Tertiary:** `#92A1A9` (Gris Azul Medio). Uso: Bordes de elementos (Outlined), textos secundarios, subtítulos, estados inactivos.
*   **Neutral:** `#273035` (Carbón Oscuro). Uso: Texto principal (Headlines y Body), iconos de navegación, títulos de tarjetas.
*   **Destructive/Error:** `#D32F2F` (Rojo Estándar - inferido del icono de papelera). Uso: Botones de eliminar o alertas.
*   **Background / Surface:** `#F4F7F8` / `#FFFFFF` (Blanco o Gris muy claro). Uso: Fondo principal de la aplicación y fondo de tarjetas principales.

### 1.2 Tipografía
La única familia tipográfica permitida en la aplicación es **Manrope**.

*   **Headline:** Manrope Bold/SemiBold (Pesos 600-800). Uso: Título principal de la app ("Centralis"), títulos de tarjetas grandes.
*   **Body:** Manrope Regular/Medium (Pesos 400-500). Uso: Descripciones, párrafos, nombres de usuarios.
*   **Label / Overline:** Manrope Medium/SemiBold (Pesos 500-600), usualmente en tamaños más pequeños (12px-14px). Uso: Etiquetas de sección en mayúsculas ("RECENT CHATS", "EVENTS"), botones, horas y ubicaciones.

---

## 2. Mapeo de Componentes de la Interfaz (App Mockup)

A continuación, se detalla cómo aplicar los tokens de diseño en los componentes específicos basados en la vista principal de la aplicación móvil:

### 2.1 Estructura General y Navegación
*   **Fondo de la App (Background):** Utilizar color claro (Surface).
*   **Top App Bar (Cabecera):**
    *   **Título ("Centralis"):** Tipografía Manrope Headline, tamaño grande, color `Neutral` (`#273035`).
    *   **Iconos (Campana, Engranaje):** Estilo "Outlined" (línea), color `Neutral` (`#273035`).
*   **Bottom Navigation Bar (Menú Inferior):**
    *   **Fondo:** Transparente o Surface (blanco).
    *   **Iconos (Home, Document, Chat, User):** Estilo "Outlined", trazo limpio, color `Neutral` (`#273035`).

### 2.2 Títulos de Sección (Section Headers)
*   **Ejemplos:** "RECENT CHATS", "LATEST COMPANY ANNOUNCEMENTS", "EVENTS".
*   **Estilo:** Tipografía Manrope Label, todo en MAYÚSCULAS (uppercase), con espaciado de letras (letter-spacing) amplio.
*   **Color:** `Neutral` (`#273035`) o `Tertiary` (`#92A1A9`) para jerarquía visual menor.

### 2.3 Carrusel de Chats Recientes (Recent Chats)
*   **Avatares:** Contenedores circulares con la imagen del usuario.
*   **Nombres:** Tipografía Manrope Body/Label, tamaño pequeño, centrado, color `Neutral` (`#273035`).

### 2.4 Tarjetas de Anuncios (Company Announcements)
*   **Contenedor:** Bordes redondeados. Fondo color `Secondary` (`#B4BFC4`) o imagen con una capa de opacidad superpuesta.
*   **Título:** Manrope Body Bold, color `Neutral` (`#273035`). Subrayado.
*   **Cuerpo de Texto:** Manrope Body, tamaño mediano/pequeño, color `Neutral` (`#273035`).
*   **Enlace de Acción ("Read more ->"):** Manrope Label/Body SemiBold, color `Primary` (`#556973`).

### 2.5 Lista de Eventos (Events List)
*   **Contenedor (Card):** Estilo "Outlined". Fondo blanco/Surface, con un borde de 1px a 2px en color `Tertiary` (`#92A1A9`) o `Secondary` (`#B4BFC4`). Bordes redondeados.
*   **Contenedor del Icono Izquierdo:** Cuadrado con bordes suavemente redondeados, fondo color `Secondary` (`#B4BFC4`), icono en color `Neutral` o `Primary`.
*   **Título del Evento ("Strategic Planning"):** Manrope Body Bold, color `Neutral` (`#273035`).
*   **Detalles (Hora y Lugar):** Manrope Label, tamaño pequeño, color `Tertiary` (`#92A1A9`) o `Neutral` claro.
*   **Icono de Flecha Derecha (Chevron):** Color `Neutral` (`#273035`).

### 2.6 Botón de Acción Flotante (FAB)
*   **Contenedor:** Forma circular (ubicado en la esquina inferior derecha por encima del menú de navegación).
*   **Fondo:** Color `Primary` (`#556973`).
*   **Icono ("+"):** Color Blanco (`#FFFFFF`).

---

## 3. Notas para el Agente de IA Generador de Código
1. Priorizar el uso de variables/constantes CSS o propiedades del tema (ThemeData en Flutter / Theme en React Navigation) mapeando los colores exactos proveídos.
2. Evitar sombras (box-shadows / elevation) agresivas. El diseño emplea un estilo "Flat" o minimalista. La diferenciación de jerarquía se logra a través del uso de la variante `Outlined` o los fondos en color `Secondary`.
3. Asegurar que los contrastes de texto cumplan con la accesibilidad usando `Neutral` sobre fondos claros.
4. **OBLIGATORIO:** Utilizar exclusivamente componentes de Material Design 3 (MD3) nativos de Flutter (ej. `NavigationBar` en lugar de `BottomNavigationBar`, `FilledButton` / `OutlinedButton`, tarjetas con estilos específicos como `Card.outlined()`, etc.) asegurando que se adapten a la configuración global de `useMaterial3: true` definida en el `AppTheme`. Evitar el uso de componentes de Material 2 deprecados.