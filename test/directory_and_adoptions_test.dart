import 'package:flutter_test/flutter_test.dart';
import 'package:paw_campus/features/adoptions/data/pets_repository.dart';
import 'package:paw_campus/features/donations/domain/directory_entry.dart';

void main() {
  group('DirectoryEntry Model and Curated Directory Tests', () {
    test('DirectoryEntry serializes and deserializes correctly', () {
      final entry = DirectoryEntry(
        id: 'test-vet-1',
        name: 'Clínica Veterinaria Prueba',
        category: DirectoryCategory.veterinary24h,
        municipality: DirectoryMunicipality.bucaramanga,
        address: 'Carrera 27 # 36-10',
        phone: '(607) 633-1234',
        whatsapp: '318 123 4567',
        is24Hours: true,
        description: 'Atención 24 horas',
        neighborhood: 'Antonia Santos',
        openHours: '24 Horas',
      );

      final json = entry.toJson();
      expect(json['id'], 'test-vet-1');
      expect(json['is_24_hours'], true);
      expect(json['category'], DirectoryCategory.veterinary24h);
      expect(json['municipality'], DirectoryMunicipality.bucaramanga);

      final reconstructed = DirectoryEntry.fromJson(json);
      expect(reconstructed.id, entry.id);
      expect(reconstructed.name, entry.name);
      expect(reconstructed.category, entry.category);
      expect(reconstructed.municipality, entry.municipality);
      expect(reconstructed.is24Hours, true);
      expect(reconstructed.neighborhood, 'Antonia Santos');
    });

    test('DirectoryEntry cleanPhone and WhatsApp URLs are generated properly', () {
      const entry = DirectoryEntry(
        id: 'test-2',
        name: 'Refugio Prueba',
        category: DirectoryCategory.foundation,
        municipality: DirectoryMunicipality.floridablanca,
        address: 'Calle 10 # 5-20',
        phone: '315-987-6543',
        whatsapp: '+57 (315) 987-6543',
        description: 'Refugio',
      );

      expect(entry.cleanPhone, '3159876543');
      expect(entry.telUrl, 'tel:3159876543');
      expect(entry.whatsappUrl, contains('https://wa.me/573159876543'));
      expect(entry.whatsappUrl, contains('PawCo'));
    });

    test('DirectoryEntry copyWith updates attributes without mutating original', () {
      const original = DirectoryEntry(
        id: 'test-3',
        name: 'Original',
        category: DirectoryCategory.welfare,
        municipality: DirectoryMunicipality.giron,
        address: 'Calle 30',
        phone: '123',
        description: 'Desc',
      );

      final updated = original.copyWith(
        name: 'Actualizado',
        is24Hours: true,
        neighborhood: 'El Poblado',
      );

      expect(updated.name, 'Actualizado');
      expect(updated.is24Hours, true);
      expect(updated.neighborhood, 'El Poblado');
      expect(original.name, 'Original');
      expect(original.is24Hours, false);
    });

    test('Curated entries cover all 4 AMB municipalities and all categories', () {
      final entries = DirectoryEntry.curatedEntries;
      expect(entries.length, greaterThanOrEqualTo(10));

      final municipalities = entries.map((e) => e.municipality).toSet();
      expect(municipalities, contains(DirectoryMunicipality.bucaramanga));
      expect(municipalities, contains(DirectoryMunicipality.floridablanca));
      expect(municipalities, contains(DirectoryMunicipality.giron));
      expect(municipalities, contains(DirectoryMunicipality.piedecuesta));
      expect(municipalities, contains(DirectoryMunicipality.metropolitana));

      final categories = entries.map((e) => e.category).toSet();
      expect(categories, contains(DirectoryCategory.veterinary24h));
      expect(categories, contains(DirectoryCategory.foundation));
      expect(categories, contains(DirectoryCategory.emergencyLine));
      expect(categories, contains(DirectoryCategory.welfare));

      // Verificar que existan clínicas 24 horas reales
      final h24Entries = entries.where((e) => e.is24Hours).toList();
      expect(h24Entries.length, greaterThanOrEqualTo(4));
    });
  });

  group('Adoptions Filtering Logic Tests', () {
    final samplePets = [
      Pet(
        id: '1',
        name: 'Luna',
        species: 'Perro',
        age: 2,
        description: 'Perrita cariñosa rescatada en Cabecera',
        photoUrl: 'https://example.com/luna.jpg',
        city: 'Bucaramanga',
        neighborhood: 'Cabecera del Llano',
        size: 'Mediano',
        createdBy: 'u1',
      ),
      Pet(
        id: '2',
        name: 'Simón',
        species: 'Gato',
        age: 1,
        description: 'Gatito juguetón y tierno',
        photoUrl: 'https://example.com/simon.jpg',
        city: 'Floridablanca',
        neighborhood: 'Cañaveral',
        size: 'Pequeño',
        createdBy: 'u2',
      ),
      Pet(
        id: '3',
        name: 'Nala',
        species: 'Perro',
        age: 3,
        description: 'Perrita fiel y tranquila',
        photoUrl: 'https://example.com/nala.jpg',
        city: 'Girón',
        neighborhood: 'El Poblado',
        size: 'Mediano',
        createdBy: 'u3',
      ),
      Pet(
        id: '4',
        name: 'Milo',
        species: 'Gato',
        age: 2,
        description: 'Gato dormilón atigrado',
        photoUrl: 'https://example.com/milo.jpg',
        city: 'Piedecuesta',
        neighborhood: 'Hoyo Grande',
        size: 'Pequeño',
        createdBy: 'u4',
      ),
      Pet(
        id: '5',
        name: 'Copito',
        species: 'Conejo',
        age: 1,
        description: 'Conejito blanco muy dócil',
        photoUrl: 'https://example.com/copito.jpg',
        city: 'Bucaramanga',
        neighborhood: 'Provenza',
        size: 'Pequeño',
        createdBy: 'u5',
      ),
    ];

    test('Filter by municipality works accurately', () {
      List<Pet> filterByCity(List<Pet> pets, String city) {
        if (city == '📍 Todo AMB') return pets;
        return pets.where((p) => p.city.toLowerCase() == city.toLowerCase()).toList();
      }

      expect(filterByCity(samplePets, '📍 Todo AMB').length, 5);
      expect(filterByCity(samplePets, 'Bucaramanga').length, 2);
      expect(filterByCity(samplePets, 'Floridablanca').length, 1);
      expect(filterByCity(samplePets, 'Girón').length, 1);
      expect(filterByCity(samplePets, 'Piedecuesta').length, 1);
    });

    test('Filter by species works accurately including "Otro"', () {
      List<Pet> filterBySpecies(List<Pet> pets, String species) {
        if (species == '🐾 Todas') return pets;
        if (species == 'Otro') {
          return pets.where((p) {
            final s = p.species.toLowerCase();
            return s != 'perro' && s != 'gato';
          }).toList();
        }
        return pets.where((p) => p.species.toLowerCase() == species.toLowerCase()).toList();
      }

      expect(filterBySpecies(samplePets, '🐾 Todas').length, 5);
      expect(filterBySpecies(samplePets, 'Perro').length, 2);
      expect(filterBySpecies(samplePets, 'Gato').length, 2);
      expect(filterBySpecies(samplePets, 'Otro').length, 1);
      expect(filterBySpecies(samplePets, 'Otro').first.name, 'Copito');
    });

    test('Search by text matches name, description, neighborhood or city', () {
      List<Pet> searchPets(List<Pet> pets, String query) {
        final q = query.trim().toLowerCase();
        if (q.isEmpty) return pets;
        return pets.where((p) {
          final matchName = p.name.toLowerCase().contains(q);
          final matchDesc = p.description.toLowerCase().contains(q);
          final matchCity = p.city.toLowerCase().contains(q);
          final matchNeigh = (p.neighborhood ?? '').toLowerCase().contains(q);
          return matchName || matchDesc || matchCity || matchNeigh;
        }).toList();
      }

      // Por nombre
      expect(searchPets(samplePets, 'luna').length, 1);
      // Por barrio
      expect(searchPets(samplePets, 'cañaveral').length, 1);
      expect(searchPets(samplePets, 'cañaveral').first.name, 'Simón');
      // Por descripción
      expect(searchPets(samplePets, 'cariñosa').length, 1);
      // Sin coincidencia
      expect(searchPets(samplePets, 'inexistente').length, 0);
    });

    test('Combined filter: Municipality + Species + Search query', () {
      List<Pet> combinedFilter(
        List<Pet> pets, {
        required String municipality,
        required String species,
        required String query,
      }) {
        return pets.where((p) {
          if (municipality != '📍 Todo AMB' &&
              p.city.toLowerCase() != municipality.toLowerCase()) {
            return false;
          }
          if (species != '🐾 Todas') {
            if (species == 'Otro') {
              final s = p.species.toLowerCase();
              if (s == 'perro' || s == 'gato') return false;
            } else if (p.species.toLowerCase() != species.toLowerCase()) {
              return false;
            }
          }
          if (query.isNotEmpty) {
            final q = query.toLowerCase();
            final matchName = p.name.toLowerCase().contains(q);
            final matchDesc = p.description.toLowerCase().contains(q);
            final matchCity = p.city.toLowerCase().contains(q);
            final matchNeigh = (p.neighborhood ?? '').toLowerCase().contains(q);
            if (!matchName && !matchDesc && !matchCity && !matchNeigh) return false;
          }
          return true;
        }).toList();
      }

      // Bucaramanga + Perro
      final bgaPerros = combinedFilter(
        samplePets,
        municipality: 'Bucaramanga',
        species: 'Perro',
        query: '',
      );
      expect(bgaPerros.length, 1);
      expect(bgaPerros.first.name, 'Luna');

      // Bucaramanga + Conejo (Otro)
      final bgaOtro = combinedFilter(
        samplePets,
        municipality: 'Bucaramanga',
        species: 'Otro',
        query: 'blanco',
      );
      expect(bgaOtro.length, 1);
      expect(bgaOtro.first.name, 'Copito');
    });

    test('PetsRepository seedApprovedPets contains valid realistic pets', () {
      final seeds = PetsRepository.seedApprovedPets;
      expect(seeds.length, greaterThanOrEqualTo(5));

      for (final pet in seeds) {
        expect(pet.id.isNotEmpty, true);
        expect(pet.name.isNotEmpty, true);
        expect(pet.photoUrl.startsWith('http'), true);
        expect(pet.description.isNotEmpty, true);
        expect(pet.city.isNotEmpty, true);
        expect(pet.status, 'approved');
      }
    });
  });
}
