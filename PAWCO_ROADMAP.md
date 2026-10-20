# 🐾 PawCo — Documento Maestro de Arquitectura y Hoja de Ruta

> **Propósito:** Este documento es la fuente de verdad técnica y de producto para **PawCo** (anteriormente *PawCampus*). Cualquier agente o sesión de desarrollo debe seguir estrictamente estas directrices de diseño, arquitectura y fases de implementación.

---

## 1. Visión del Producto y Alcance Geográfico

* **Nombre Oficial:** **PawCo** (Paw Community / Colombia `.co`).
* **Alcance Inicial:** **Bucaramanga y su Área Metropolitana** (`Bucaramanga`, `Floridablanca`, `Girón`, `Piedecuesta`), diseñado con estructura escalable a cualquier departamento y municipio de **Colombia**.
* **Filosofía de Acceso (Modo Invitado):**
  * La aplicación inicia directamente en el contenedor principal (`MainShell` en `/`).
  * **Lectura 100% pública:** Cualquier ciudadano puede explorar mascotas en adopción, ver reportes de animales perdidos/encontrados en tiempo real, consultar el mapa, ver rutas de denuncia de maltrato animal, usar números de emergencia 24/7 y donar sin necesidad de iniciar sesión.
  * **Escritura protegida (Auth Guard):** Solo se solicita iniciar sesión (`/login`) cuando el usuario intenta publicar una mascota en adopción, reportar un animal perdido/encontrado, radicar un reporte interno de maltrato (salvo que sea anónimo), o gestionar su perfil / publicaciones.

---

## 2. Reglas de Diseño Visual y UI/UX (¡MUY IMPORTANTE!)

> [!CAUTION]
> **Prohibido repetir el estilo recargado de Codex (`6605058`):** No usar orbes flotantes (`_GlowOrb`), ni filtros pesados de desenfoque (`BackdropFilter` / glassmorphism excesivo), ni animaciones intrusivas que ralenticen la lectura.

* **Estilo buscado:** **Moderno, limpio tipo startup, pero cálido y animalista** (sin verse infantil ni caricaturesco).
* **Paleta de Colores (Material 3 Light):**
  * **Fondo Principal (`scaffoldBackgroundColor`):** Crema cálido muy suave (`#FFF7ED` o `#FFFDF9`).
  * **Superficies / Tarjetas (`Card`):** Blanco puro (`#FFFFFF`) con bordes redondeados (`16px`), sombra sutil (`Colors.black12`) y excelente espaciado interno.
  * **Color Primario:** `Teal` (`#0D9488` / `Colors.teal`), transmitiendo confianza, salud, vida y naturaleza.
  * **Color Secundario / Cálido:** Ámbar / Naranja suave (`#F59E0B`) para etiquetas amigables o estados pendientes.
  * **Color de Alerta / SOS:** Rojo Coral (`#E11D48` / `Colors.redAccent`) **exclusivamente** para el módulo de Denuncias de Maltrato Animal y alertas urgentes de mascotas perdidas.
  * **Tipografía y Contraste:** Texto principal en gris carbón oscuro (`#1E293B` / `Colors.black87`) y subtítulos en gris pizarra (`#64748B`). **Jamás usar texto blanco (`Colors.white70`) sobre fondos crema o blancos.**

---

## 3. Arquitectura de Navegación (Bottom NavigationBar de 5 Pestañas)

La aplicación reemplaza el antiguo `TabBar` superior por un `MainShell` con `NavigationBar` (Material 3) en la parte inferior con 5 destinos principales:

1. **🐾 Adopciones (`/adoptions`):**
   * Catálogo de mascotas aprobadas para adopción o hogar de paso.
   * Filtros rápidos por **Municipio** (`Todos`, `Bucaramanga`, `Floridablanca`, `Girón`, `Piedecuesta`) y **Especie** (`Todos`, `Perro`, `Gato`, `Otro`).
   * Búsqueda por nombre/descripción.
   * Botón flotante para publicar mascota (requiere sesión iniciada; queda en estado `pending` hasta aprobación de admin).
2. **📍 Perdidos y Mapa (`/lost-pets`):**
   * Conmutador superior (SegmentedButton o Tabs limpias): **Vista Lista** vs **Vista Mapa Interactivo** (`flutter_map` con OpenStreetMap centrado en Bucaramanga `7.1193, -73.1227`).
   * Filtros por estado: `Perdido` (rojo/naranja) vs `Avistado / Encontrado` (verde/teal) y por municipio/barrio.
   * **Publicación en vivo (sin espera de moderación):** Para no perder minutos críticos, los reportes de animales perdidos/encontrados se publican de inmediato, e incluyen un botón de *"Reportar publicación indebida"* en el detalle.
3. **🚨 Denuncias SOS (`/sos`):**
   * **Sección 1: Acción Inmediata y Rutas Oficiales en Colombia (Links directos con `url_launcher`):**
     * 📞 **Línea 123** — Policía Nacional / Patrulla de Rescate y Policía Ambiental.
     * ⚖️ **Fiscalía General de la Nación (Grupo GELMA)** — Enlace directo al portal oficial de Denuncia Fácil (`https://sicecon.fiscalia.gov.co/denuncia/LlenarFormulario`) y línea `122` (Ley 1774 de 2016 contra el maltrato animal).
     * 🏛️ **Alcaldía de Bucaramanga / Inspección de Policía de Protección a la Vida** — Orientación para casos de tenencia irresponsable en el Área Metropolitana.
   * **Sección 2: Reporte Ciudadano en PawCo (Modelo Híbrido Seguro):**
     * Formulario con nivel de urgencia (`Crítica / Peligro de vida`, `Moderada`, `Tenencia irresponsable`), municipio, barrio/dirección, descripción, foto de evidencia y **switch de "Denuncia Anónima"**.
     * Se guarda en Supabase con estado privado (`pending_review`) visible solo para administradores/fundaciones, quienes pueden aprobarlo como "Alerta de Rescate" pública (ocultando siempre los datos del denunciante).
4. **💚 Ayuda y Comunidad (`/community`):**
   * **Subsección Donaciones:** Código QR interactivo y botón directo a Wompi (`https://checkout.wompi.co/l/IMjZp7`) con buen contraste visual, además de información de cómo se usan los recursos.
   * **Subsección Directorio 24/7 (Área Metropolitana):** Tarjetas de contacto rápido (WhatsApp / Llamada / Ubicación) de veterinarias 24 horas, fundaciones locales y hogares de paso aliados en Bucaramanga, Floridablanca, Girón y Piedecuesta.
5. **👤 Perfil (`/profile`):**
   * Si es **Invitado**: Pantalla amigable invitando a Iniciar Sesión o Crear Cuenta.
   * Si está **Autenticado**:
     * Datos del usuario y botón de Editar Perfil (foto en `avatars`, nombre, teléfono WhatsApp, ciudad).
     * Acceso o sección integrada de **"Mis Publicaciones"** (mis mascotas en adopción y mis reportes de perdidos con su estado).
     * Si `profile.isAdmin == true`: Botón destacado de **🛠️ Panel de Administración** (`/admin`) para aprobar/rechazar mascotas en adopción, moderar reportes de perdidos y gestionar denuncias SOS recibidas.

---

## 4. Plan de Ejecución Incremental (Las 4 Fases para `/goal`)

Cuando se ejecute el comando `/goal`, el agente deberá completar estas 4 fases en orden estricto, verificando que el código compile/analice sin errores y haciendo un **commit descriptivo en Git al finalizar cada fase**:

### ✅ Fase 1: Rebranding a PawCo, Navegación Principal y Limpieza Técnica
1. **Unificación de Modelos de Dominio:**
   * Mover el modelo `Pet` desde `lib/features/adoptions/data/pets_repository.dart` hacia `lib/features/adoptions/domain/pet.dart` (reexportándolo en el repositorio para no romper imports existentes) y agregar campos opcionales con fallback seguro (`city`, `neighborhood`, `gender`, `size`).
   * Unificar `UserProfile` en `lib/features/profile/domain/profile.dart` incluyendo `final bool isAdmin;` (leído desde `json['is_admin'] == true`) y eliminar la duplicación en `lib/features/auth/domain/profile.dart`.
2. **Corrección de Bugs Actuales:**
   * En `AdoptionsPage` y `AdminPage`: Corregir textos en `Colors.white70` que no se ven sobre el fondo claro `#FFF7ED`.
   * En `PetDetailPage`: Reemplazar la validación cableada `user?.email?.endsWith('@admin.com')` por la consulta real del campo `is_admin` del perfil en Supabase.
   * En `AdoptionsPage`: Al regresar de `AddPetPage` (`/pets/new`), invalidar `myPetsProvider` y `petsProvider` para refrescar la lista automáticamente.
3. **Rebranding y `MainShell` (5 Pestañas + Modo Invitado):**
   * Actualizar título de la app a **PawCo** en `lib/app/app.dart` y `lib/app/theme.dart`.
   * Crear `lib/app/main_shell.dart` con `NavigationBar` de 5 pestañas (`Adopciones`, `Perdidos`, `SOS`, `Ayuda`, `Perfil`).
   * Configurar `lib/app/router.dart` para que la ruta inicial sea `/` mostrando el `MainShell` en Modo Invitado sin forzar `/login`, y que al iniciar sesión redirija a `/` (o `/admin` si prefiere ir directo, manteniendo acceso desde Perfil).
4. **Commit Fase 1:** `feat(phase-1): rebrand to PawCo, add 5-tab MainShell, guest mode and domain cleanup`

---

### ✅ Fase 2: Módulo 🚨 Denuncias de Maltrato Animal y SOS (Colombia / Bucaramanga)
1. **Dominio y Repositorio de Denuncias (`lib/features/sos/`):**
   * Crear modelo `AbuseReport` (`id`, `urgencyLevel`, `municipality`, `neighborhood`, `addressNotes`, `description`, `photoUrl`, `isAnonymous`, `reporterId`, `status`, `createdAt`).
   * Crear `SosRepository` conectado a la tabla `abuse_reports` de Supabase (con manejo elegante de errores y fallback local en memoria/mock si la tabla aún no ha sido creada por el usuario en Supabase, para que la UI nunca se rompa).
2. **Interfaz `SosPage` y `CreateSosReportPage`:**
   * Tarjetas de **Emergencia y Denuncia Legal en Colombia**:
     * Botón directo para llamar al `123` (Policía Nacional / Ambiental).
     * Botón directo a **Fiscalía GELMA - Denuncia Fácil** (`https://sicecon.fiscalia.gov.co/denuncia/LlenarFormulario`) + explicación de la **Ley 1774 de 2016** y **Ley Ángel**.
     * Guía rápida de qué pruebas recolectar (fotos, videos, dirección exacta en Bucaramanga/AMB).
   * Formulario de **Reporte Seguro en PawCo** con selector de municipio (`Bucaramanga`, `Floridablanca`, `Girón`, `Piedecuesta`), nivel de urgencia, subida de foto de evidencia y switch de **Denuncia Anónima**.
   * Pestaña en `AdminPage` para que los administradores revisen las denuncias recibidas.
3. **Commit Fase 2:** `feat(phase-2): implement SOS animal abuse reporting module and Colombia legal routes`

---

### ✅ Fase 3: Módulo 📍 Animales Perdidos/Encontrados + Mapa Interactivo (OpenStreetMap)
1. **Dependencias de Mapa:**
   * Agregar `flutter_map` y `latlong2` en `pubspec.yaml` (compatibles con Web y Móvil, 100% gratuitos sin API Key).
2. **Dominio y Repositorio (`lib/features/lost_pets/`):**
   * Crear modelo `LostPetReport` (`id`, `type`: `'lost'` | `'found'`, `petName`, `species`, `municipality`, `neighborhood`, `description`, `photoUrl`, `contactPhone`, `latitude`, `longitude`, `status`: `'active'` | `'resolved'`, `createdBy`, `createdAt`).
   * Crear `LostPetsRepository` conectado a la tabla `lost_pets` en Supabase (con datos semilla de demostración en Bucaramanga si la tabla aún no existe en Supabase).
3. **Interfaz `LostPetsPage` y `AddLostPetPage`:**
   * Conmutador superior entre **Lista de Alertas** y **Mapa del Área Metropolitana** (centrado en Bucaramanga `LatLng(7.1193, -73.1227)` con marcadores diferenciados por color para Perdidos vs Encontrados).
   * Selector interactivo en el mapa al crear un reporte para marcar la esquina o parque exacto donde se perdió o avistó el animalito.
   * Botón directo de contacto por WhatsApp en cada tarjeta/pin del mapa.
4. **Commit Fase 3:** `feat(phase-3): add Lost & Found pets module with interactive OpenStreetMap for Bucaramanga`

---

### ✅ Fase 4: Módulo 💚 Comunidad/Directorio 24/7 + Filtros de Adopción por Municipio
1. **Módulo de Comunidad y Directorio (`lib/features/community/` o integrado en `donations/`):**
   * Renombrar/expandir la pestaña de Ayuda en dos vistas claras: **Donaciones (Wompi + QR)** y **Directorio 24/7 AMB**.
   * Incluir directorio curado de atención en el Área Metropolitana de Bucaramanga (Veterinarias 24h, Fundaciones de rescate, líneas de emergencia municipal) con filtro por municipio y botones de llamada/WhatsApp.
2. **Mejoras en Adopciones (`AdoptionsPage` y `AddPetPage`):**
   * Agregar selector de **Municipio** (`Bucaramanga`, `Floridablanca`, `Girón`, `Piedecuesta`) y **Especie** (`Perro`, `Gato`, `Otro`) tanto al registrar una mascota como en los chips de filtrado de `AdoptionsPage`.
   * Mejorar el diseño de las tarjetas de mascotas (`PetCard`) con imagen grande, chips de edad/especie/municipio y diseño cálido animalista.
3. **Verificación Final:**
   * Revisar que todas las pantallas funcionen en Web y Móvil, ejecutar análisis estático y hacer push si está permitido.
4. **Commit Fase 4:** `feat(phase-4): add 24/7 directory for Bucaramanga and municipality/species filters in adoptions`

---

## 5. Script SQL Maestro para Supabase (`supabase_schema.sql`)

Cuando quieras actualizar tu proyecto actual de Supabase o crear uno nuevo con tu nuevo correo, solo debes copiar y pegar este script en el **SQL Editor** de Supabase:

```sql
-- ============================================================================
-- PAWCO — SCRIPT SQL MAESTRO PARA SUPABASE (PostgreSQL + RLS + Storage)
-- ============================================================================

-- 1. ACTUALIZACIÓN DE TABLA PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  name TEXT,
  phone TEXT,
  photo_url TEXT,
  city TEXT DEFAULT 'Bucaramanga',
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS city TEXT DEFAULT 'Bucaramanga';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 2. ACTUALIZACIÓN DE TABLA PETS (ADOPCIONES)
CREATE TABLE IF NOT EXISTS public.pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  age INT DEFAULT 0,
  city TEXT DEFAULT 'Bucaramanga',
  neighborhood TEXT,
  size TEXT DEFAULT 'Mediano',
  description TEXT,
  photo_url TEXT,
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'adopted'
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS city TEXT DEFAULT 'Bucaramanga';
ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS neighborhood TEXT;
ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS size TEXT DEFAULT 'Mediano';

-- 3. NUEVA TABLA: LOST_PETS (PERDIDOS Y ENCONTRADOS EN VIVO)
CREATE TABLE IF NOT EXISTS public.lost_pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_type TEXT NOT NULL DEFAULT 'lost', -- 'lost' (Perdido) | 'found' (Avistado/Encontrado)
  pet_name TEXT,
  species TEXT NOT NULL DEFAULT 'Perro',
  municipality TEXT NOT NULL DEFAULT 'Bucaramanga',
  neighborhood TEXT NOT NULL,
  description TEXT NOT NULL,
  photo_url TEXT,
  contact_phone TEXT NOT NULL,
  latitude DOUBLE PRECISION DEFAULT 7.1193,
  longitude DOUBLE PRECISION DEFAULT -73.1227,
  status TEXT NOT NULL DEFAULT 'active', -- 'active' | 'resolved' | 'flagged'
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. NUEVA TABLA: ABUSE_REPORTS (DENUNCIAS DE MALTRATO ANIMAL / SOS)
CREATE TABLE IF NOT EXISTS public.abuse_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  urgency_level TEXT NOT NULL DEFAULT 'Alta', -- 'Critica', 'Alta', 'Moderada'
  municipality TEXT NOT NULL DEFAULT 'Bucaramanga',
  neighborhood TEXT NOT NULL,
  address_notes TEXT,
  description TEXT NOT NULL,
  photo_url TEXT,
  is_anonymous BOOLEAN DEFAULT TRUE,
  reporter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending_review', -- 'pending_review', 'in_progress', 'public_alert', 'closed'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. HABILITAR ROW LEVEL SECURITY (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lost_pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.abuse_reports ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura pública para Modo Invitado
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Pets are viewable by everyone" ON public.pets FOR SELECT USING (true);
CREATE POLICY "Lost pets are viewable by everyone" ON public.lost_pets FOR SELECT USING (true);
CREATE POLICY "Public SOS alerts are viewable" ON public.abuse_reports FOR SELECT USING (status = 'public_alert' OR auth.uid() = reporter_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true));

-- Políticas de inserción
CREATE POLICY "Authenticated users can insert pets" ON public.pets FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Authenticated users can insert lost_pets" ON public.lost_pets FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Anyone can submit abuse_reports" ON public.abuse_reports FOR INSERT WITH CHECK (true);
```
