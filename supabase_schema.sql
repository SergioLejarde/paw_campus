-- ============================================================================
-- 🐾 PAWCO — SCRIPT SQL MAESTRO PARA SUPABASE (PostgreSQL + RLS + Storage)
-- ============================================================================
-- Este script es la fuente de verdad técnica para la base de datos de PawCo en
-- Bucaramanga y su Área Metropolitana (Floridablanca, Girón, Piedecuesta, Colombia).
--
-- Instrucciones de instalación:
-- 1. Abre tu proyecto en Supabase (https://app.supabase.com).
-- 2. Dirígete a la sección "SQL Editor" en el menú lateral izquierdo.
-- 3. Crea una "New Query", pega la totalidad de este script y presiona "RUN".
-- ============================================================================

-- Habilitar extensiones requeridas para generación de identificadores UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. TABLA: PROFILES (Perfiles de usuarios y administradores)
-- ============================================================================
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

-- Asegurar columnas si la tabla ya existía previamente
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS city TEXT DEFAULT 'Bucaramanga';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Trigger para crear automáticamente el perfil al registrarse un usuario en auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, phone, photo_url, city, is_admin)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'photo_url',
    COALESCE(NEW.raw_user_meta_data->>'city', 'Bucaramanga'),
    FALSE
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================================
-- 2. TABLA: PETS (Mascotas en adopción)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  species TEXT NOT NULL DEFAULT 'Perro',
  age INT DEFAULT 0,
  city TEXT NOT NULL DEFAULT 'Bucaramanga',
  neighborhood TEXT,
  size TEXT NOT NULL DEFAULT 'Mediano', -- 'Pequeño', 'Mediano', 'Grande'
  description TEXT,
  photo_url TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'adopted'
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Migración segura de columnas adicionales
ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS city TEXT DEFAULT 'Bucaramanga';
ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS neighborhood TEXT;
ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS size TEXT DEFAULT 'Mediano';


-- ============================================================================
-- 3. TABLA: LOST_PETS (Mascotas perdidas y encontradas en tiempo real)
-- ============================================================================
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


-- ============================================================================
-- 4. TABLA: ABUSE_REPORTS (Denuncias ciudadanas de maltrato animal / SOS)
-- ============================================================================
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


-- ============================================================================
-- 5. ÍNDICES DE RENDIMIENTO (Performance Indexes)
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_pets_status ON public.pets(status);
CREATE INDEX IF NOT EXISTS idx_pets_city ON public.pets(city);
CREATE INDEX IF NOT EXISTS idx_pets_species ON public.pets(species);
CREATE INDEX IF NOT EXISTS idx_pets_created_by ON public.pets(created_by);

CREATE INDEX IF NOT EXISTS idx_lost_pets_status ON public.lost_pets(status);
CREATE INDEX IF NOT EXISTS idx_lost_pets_municipality ON public.lost_pets(municipality);
CREATE INDEX IF NOT EXISTS idx_lost_pets_report_type ON public.lost_pets(report_type);

CREATE INDEX IF NOT EXISTS idx_abuse_reports_status ON public.abuse_reports(status);
CREATE INDEX IF NOT EXISTS idx_abuse_reports_municipality ON public.abuse_reports(municipality);
CREATE INDEX IF NOT EXISTS idx_abuse_reports_urgency ON public.abuse_reports(urgency_level);


-- ============================================================================
-- 6. POLÍTICAS DE SEGURIDAD (Row Level Security - RLS)
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lost_pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.abuse_reports ENABLE ROW LEVEL SECURITY;

-- Limpieza de políticas previas para evitar duplicados en re-ejecución
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Pets are viewable by everyone" ON public.pets;
DROP POLICY IF EXISTS "Authenticated users can insert pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update their own pets" ON public.pets;
DROP POLICY IF EXISTS "Admins can update any pet" ON public.pets;
DROP POLICY IF EXISTS "Lost pets are viewable by everyone" ON public.lost_pets;
DROP POLICY IF EXISTS "Authenticated users can insert lost_pets" ON public.lost_pets;
DROP POLICY IF EXISTS "Users can update their own lost pets" ON public.lost_pets;
DROP POLICY IF EXISTS "Anyone can submit abuse_reports" ON public.abuse_reports;
DROP POLICY IF EXISTS "SOS alerts viewable by public or admins or reporter" ON public.abuse_reports;
DROP POLICY IF EXISTS "Admins can update abuse_reports" ON public.abuse_reports;

-- POLÍTICAS: PROFILES
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- POLÍTICAS: PETS (Adopciones)
-- Modo Invitado: cualquiera puede ver mascotas aprobadas o el autor puede ver las suyas
CREATE POLICY "Pets are viewable by everyone"
  ON public.pets FOR SELECT
  USING (status = 'approved' OR auth.uid() = created_by OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  ));

-- Solo usuarios autenticados pueden subir mascotas en adopción
CREATE POLICY "Authenticated users can insert pets"
  ON public.pets FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update their own pets"
  ON public.pets FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "Admins can update any pet"
  ON public.pets FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  ));

-- POLÍTICAS: LOST_PETS (Perdidos y Encontrados)
-- Modo Invitado: lectura pública de todos los reportes activos
CREATE POLICY "Lost pets are viewable by everyone"
  ON public.lost_pets FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert lost_pets"
  ON public.lost_pets FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update their own lost pets"
  ON public.lost_pets FOR UPDATE
  USING (auth.uid() = created_by OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  ));

-- POLÍTICAS: ABUSE_REPORTS (Denuncias SOS)
-- Cualquiera (incluso anónimo) puede enviar una denuncia
CREATE POLICY "Anyone can submit abuse_reports"
  ON public.abuse_reports FOR INSERT
  WITH CHECK (true);

-- Solo alertas públicas de rescate, el denunciante original o administradores pueden leer
CREATE POLICY "SOS alerts viewable by public or admins or reporter"
  ON public.abuse_reports FOR SELECT
  USING (
    status = 'public_alert'
    OR auth.uid() = reporter_id
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Admins can update abuse_reports"
  ON public.abuse_reports FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  ));


-- ============================================================================
-- 7. STORAGE BUCKETS (Buckets públicos recomendados en Supabase Storage)
-- ============================================================================
-- Para permitir subida de fotos desde la app, crea los siguientes buckets en Supabase Storage:
-- 1. `pet_photos`   (Público) -> Fotos de mascotas en adopción.
-- 2. `lost_pets`    (Público) -> Fotos de reportes de animales perdidos/avistados.
-- 3. `sos_evidence` (Público) -> Fotos y pruebas de denuncias ciudadanas.
-- 4. `avatars`      (Público) -> Fotos de perfil de los usuarios.

INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('pet_photos', 'pet_photos', true),
  ('lost_pets', 'lost_pets', true),
  ('sos_evidence', 'sos_evidence', true),
  ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de lectura pública para Storage
CREATE POLICY "Public storage read pet_photos" ON storage.objects FOR SELECT USING (bucket_id = 'pet_photos');
CREATE POLICY "Public storage read lost_pets" ON storage.objects FOR SELECT USING (bucket_id = 'lost_pets');
CREATE POLICY "Public storage read sos_evidence" ON storage.objects FOR SELECT USING (bucket_id = 'sos_evidence');
CREATE POLICY "Public storage read avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

-- Inserción de objetos en Storage para usuarios autenticados
CREATE POLICY "Authenticated users upload pet_photos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'pet_photos' AND auth.role() = 'authenticated');
CREATE POLICY "Authenticated users upload lost_pets" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'lost_pets' AND auth.role() = 'authenticated');
CREATE POLICY "Anyone upload sos_evidence" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'sos_evidence');
CREATE POLICY "Authenticated users upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
