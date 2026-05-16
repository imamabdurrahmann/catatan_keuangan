import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_data;
import 'package:catatan_keuangan/models/models.dart';
import 'package:catatan_keuangan/providers.dart';
import 'package:catatan_keuangan/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'id_ID';
    await date_data.initializeDateFormatting();
  });

  group('Profile Switch Tests', () {
    group('Profil Model Tests', () {
      test('Profil can be created with required fields', () {
        final profil = Profil(
          id: 1,
          nama: 'Personal',
          icon: 'person',
        );

        expect(profil.nama, equals('Personal'));
        expect(profil.icon, equals('person'));
        expect(profil.id, equals(1));
      });

      test('Profil copyWith creates new instance with updated fields', () {
        final profil = Profil(
          id: 1,
          nama: 'Personal',
          icon: 'person',
        );

        final updated = profil.copyWith(nama: 'Business');

        expect(updated.nama, equals('Business'));
        expect(updated.icon, equals('person'));
        expect(updated.id, equals(1));
      });

      test('Profil toMap produces correct structure', () {
        final profil = Profil(
          id: 1,
          nama: 'Personal',
          icon: 'wallet',
        );

        final map = profil.toMap();

        expect(map['id'], equals(1));
        expect(map['nama'], equals('Personal'));
        expect(map['icon'], equals('wallet'));
      });

      test('Profil fromMap creates instance from map', () {
        final map = {
          'id': 2,
          'nama': 'Work',
          'icon': 'work',
          'created_at': null,
        };

        final profil = Profil.fromMap(map);

        expect(profil.id, equals(2));
        expect(profil.nama, equals('Work'));
        expect(profil.icon, equals('work'));
      });
    });

    group('Profil List Provider Tests', () {
      test('profilListProvider returns AsyncValue structure', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final value = container.read(profilListProvider);
        expect(value, isA<AsyncValue<List<Profil>>>());
      });

      test('selectedProfilProvider returns AsyncValue structure', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final value = container.read(selectedProfilProvider);
        expect(value, isA<AsyncValue<Profil?>>());
      });

      test('currentProfilIdProvider returns int', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final value = container.read(currentProfilIdProvider);
        expect(value, isA<int>());
      });
    });

    group('Profile Selection UI Tests', () {
      testWidgets('profile selector shows profile name', (tester) async {
        final profiles = [
          Profil(id: 1, nama: 'Personal', icon: 'person'),
          Profil(id: 2, nama: 'Work', icon: 'work'),
        ];

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: DropdownButtonFormField<int>(
                  value: 1,
                  items: profiles.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(p.nama),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Personal'), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
      });

      testWidgets('profile chip selection works', (tester) async {
        int? selectedId;

        await tester.pumpWidget(
          MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: Wrap(
                children: [
                  ChoiceChip(
                    label: const Text('Personal'),
                    selected: selectedId == 1,
                    onSelected: (selected) {
                      if (selected) selectedId = 1;
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Work'),
                    selected: selectedId == 2,
                    onSelected: (selected) {
                      if (selected) selectedId = 2;
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        // Tap Work chip
        await tester.tap(find.text('Work'));
        await tester.pump();

        expect(selectedId, equals(2));
      });
    });

    group('Profile Switch Behavior', () {
      testWidgets('switching profile updates state', (tester) async {
        final container = ProviderContainer();

        // Get initial profile
        final initialId = container.read(currentProfilIdProvider);
        expect(initialId, isNotNull);

        // Override for testing
        await container.read(currentProfilIdProvider.notifier).update((state) => 2);

        final updatedId = container.read(currentProfilIdProvider);
        expect(updatedId, equals(2));

        container.dispose();
      });

      test('profile with null id is handled correctly', () {
        final profil = Profil(
          nama: 'New Profile',
          icon: 'add',
        );

        expect(profil.id, isNull);
        expect(profil.nama, equals('New Profile'));
      });
    });
  });
}