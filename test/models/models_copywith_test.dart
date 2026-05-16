import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/models/models.dart';

void main() {
  group('Transaksi Model Tests', () {
    group('copyWith', () {
      test('creates copy with single field updated', () {
        final original = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Original',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15),
        );

        final copy = original.copyWith(jumlah: 200000);

        expect(copy.id, equals(1));
        expect(copy.jenis, equals('pemasukan'));
        expect(copy.jumlah, equals(200000));
        expect(copy.deskripsi, equals('Original'));
      });

      test('creates copy with multiple fields updated', () {
        final original = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Original',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15),
        );

        final copy = original.copyWith(
          deskripsi: 'Updated',
          kategori: 'Bonus',
          jumlah: 150000,
        );

        expect(copy.id, equals(1));
        expect(copy.jumlah, equals(150000));
        expect(copy.deskripsi, equals('Updated'));
        expect(copy.kategori, equals('Bonus'));
      });

      test('clears deletedAt when clearDeletedAt is true', () {
        final original = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Test',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15),
          deletedAt: DateTime(2024, 6, 16),
        );

        final copy = original.copyWith(clearDeletedAt: true);

        expect(copy.deletedAt, isNull);
      });

      test('preserves lampiran list', () {
        final original = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Test',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15),
          lampiran: ['file1.jpg', 'file2.pdf'],
        );

        final copy = original.copyWith(jumlah: 200000);

        expect(copy.lampiran, equals(['file1.jpg', 'file2.pdf']));
      });

      test('updates lampiran list', () {
        final original = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Test',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15),
          lampiran: ['file1.jpg'],
        );

        final copy = original.copyWith(lampiran: ['new1.jpg', 'new2.pdf']);

        expect(copy.lampiran, equals(['new1.jpg', 'new2.pdf']));
      });

      test('updates recurring properties', () {
        final original = Transaksi(
          id: 1,
          jenis: 'pengeluaran',
          jumlah: 50000,
          deskripsi: 'Monthly rent',
          kategori: 'Sewa',
          tanggal: DateTime(2024, 6, 1),
          isRecurring: false,
        );

        final copy = original.copyWith(
          isRecurring: true,
          recurringFrequency: 'monthly',
        );

        expect(copy.isRecurring, isTrue);
        expect(copy.recurringFrequency, equals('monthly'));
      });
    });

    group('toMap', () {
      test('converts all fields correctly', () {
        final transaksi = Transaksi(
          id: 1,
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Test',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15, 10, 30),
          lampiran: ['file1.jpg'],
          isRecurring: true,
          recurringFrequency: 'monthly',
          idDompet: 2,
        );

        final map = transaksi.toMap();

        expect(map['id'], equals(1));
        expect(map['jenis'], equals('pemasukan'));
        expect(map['jumlah'], equals(100000));
        expect(map['deskripsi'], equals('Test'));
        expect(map['kategori'], equals('Gaji'));
        expect(map['is_recurring'], equals(1));
        expect(map['recurring_frequency'], equals('monthly'));
        expect(map['id_dompet'], equals(2));
      });

      test('excludes null id from map', () {
        final transaksi = Transaksi(
          jenis: 'pemasukan',
          jumlah: 100000,
          deskripsi: 'Test',
          kategori: 'Gaji',
          tanggal: DateTime(2024, 6, 15),
        );

        final map = transaksi.toMap();

        expect(map.containsKey('id'), isFalse);
      });
    });

    group('fromMap', () {
      test('creates instance from valid map', () {
        final map = {
          'id': 1,
          'jenis': 'pengeluaran',
          'jumlah': 50000.0,
          'deskripsi': 'Lunch',
          'kategori': 'Makan',
          'tanggal': '2024-06-15 12:00:00',
          'lampiran': '[]',
          'is_recurring': 0,
          'id_dompet': 1,
        };

        final transaksi = Transaksi.fromMap(map);

        expect(transaksi.id, equals(1));
        expect(transaksi.jenis, equals('pengeluaran'));
        expect(transaksi.jumlah, equals(50000.0));
        expect(transaksi.deskripsi, equals('Lunch'));
        expect(transaksi.lampiran, isEmpty);
      });

      test('parses lampiran JSON correctly', () {
        final map = {
          'id': 1,
          'jenis': 'pemasukan',
          'jumlah': 100000,
          'deskripsi': 'Test',
          'kategori': 'Gaji',
          'tanggal': '2024-06-15 10:00:00',
          'lampiran': '["file1.jpg","file2.pdf"]',
          'is_recurring': 0,
        };

        final transaksi = Transaksi.fromMap(map);

        expect(transaksi.lampiran, equals(['file1.jpg', 'file2.pdf']));
      });

      test('handles invalid lampiran JSON', () {
        final map = {
          'id': 1,
          'jenis': 'pemasukan',
          'jumlah': 100000,
          'deskripsi': 'Test',
          'kategori': 'Gaji',
          'tanggal': '2024-06-15 10:00:00',
          'lampiran': 'invalid json',
          'is_recurring': 0,
        };

        final transaksi = Transaksi.fromMap(map);

        expect(transaksi.lampiran, isEmpty);
      });

      test('handles null lampiran', () {
        final map = {
          'id': 1,
          'jenis': 'pemasukan',
          'jumlah': 100000,
          'deskripsi': 'Test',
          'kategori': 'Gaji',
          'tanggal': '2024-06-15 10:00:00',
          'is_recurring': 0,
        };

        final transaksi = Transaksi.fromMap(map);

        expect(transaksi.lampiran, isEmpty);
      });
    });
  });

  group('Dompet Model Tests', () {
    group('copyWith', () {
      test('creates copy with single field updated', () {
        final original = Dompet(
          id: 1,
          nama: 'Bank BCA',
          saldo: 1000000,
          warna: '#FF0000',
        );

        final copy = original.copyWith(saldo: 2000000);

        expect(copy.id, equals(1));
        expect(copy.nama, equals('Bank BCA'));
        expect(copy.saldo, equals(2000000));
      });

      test('updates multiple fields', () {
        final original = Dompet(
          id: 1,
          nama: 'Cash',
          saldo: 500000,
          warna: '#00FF00',
          currency: 'IDR',
        );

        final copy = original.copyWith(
          nama: 'E-Wallet',
          saldo: 750000,
        );

        expect(copy.nama, equals('E-Wallet'));
        expect(copy.saldo, equals(750000));
        expect(copy.warna, equals('#00FF00'));
      });
    });

    group('toMap', () {
      test('converts all fields correctly', () {
        final dompet = Dompet(
          id: 1,
          nama: 'Test Wallet',
          saldo: 500000,
          warna: '#FF0000',
          currency: 'USD',
          profilId: 2,
        );

        final map = dompet.toMap();

        expect(map['id'], equals(1));
        expect(map['nama'], equals('Test Wallet'));
        expect(map['saldo'], equals(500000));
        expect(map['warna'], equals('#FF0000'));
        expect(map['currency'], equals('USD'));
        expect(map['profil_id'], equals(2));
      });
    });

    group('fromMap', () {
      test('creates instance from valid map', () {
        final map = {
          'id': 1,
          'nama': 'Main Wallet',
          'saldo': 1000000,
          'warna': '#0000FF',
          'currency': 'IDR',
          'profil_id': 1,
        };

        final dompet = Dompet.fromMap(map);

        expect(dompet.id, equals(1));
        expect(dompet.nama, equals('Main Wallet'));
        expect(dompet.saldo, equals(1000000.0));
        expect(dompet.warna, equals('#0000FF'));
        expect(dompet.currency, equals('IDR'));
        expect(dompet.profilId, equals(1));
      });

      test('handles missing optional fields', () {
        final map = {
          'id': 1,
          'nama': 'Simple Wallet',
          'warna': '#FFFFFF',
        };

        final dompet = Dompet.fromMap(map);

        expect(dompet.saldo, equals(0));
        expect(dompet.currency, equals('IDR'));
        expect(dompet.profilId, equals(1));
      });
    });
  });

  group('Kategori Model Tests', () {
    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Kategori(
          id: 1,
          nama: 'Makanan',
          jenis: 'pengeluaran',
          icon: 'restaurant',
          isDefault: true,
        );

        final copy = original.copyWith(
          nama: 'Minuman',
          icon: 'coffee',
        );

        expect(copy.id, equals(1));
        expect(copy.nama, equals('Minuman'));
        expect(copy.icon, equals('coffee'));
        expect(copy.jenis, equals('pengeluaran'));
        expect(copy.isDefault, isTrue);
      });
    });

    group('toMap and fromMap', () {
      test('round trip conversion', () {
        final original = Kategori(
          id: 1,
          nama: 'Transportasi',
          jenis: 'pengeluaran',
          icon: 'car',
          isDefault: false,
        );

        final map = original.toMap();
        final restored = Kategori.fromMap({'id': 1, ...map});

        expect(restored.nama, equals(original.nama));
        expect(restored.jenis, equals(original.jenis));
        expect(restored.icon, equals(original.icon));
        expect(restored.isDefault, equals(original.isDefault));
      });
    });
  });

  group('Budget Model Tests', () {
    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Budget(
          id: 1,
          bulan: 6,
          tahun: 2024,
          nominal: 500000,
          kategori: 'Makanan',
        );

        final copy = original.copyWith(nominal: 600000);

        expect(copy.id, equals(1));
        expect(copy.bulan, equals(6));
        expect(copy.tahun, equals(2024));
        expect(copy.nominal, equals(600000));
        expect(copy.kategori, equals('Makanan'));
      });
    });

    group('totalBudget getter', () {
      test('includes rollover in total', () {
        final budget = Budget(
          id: 1,
          bulan: 6,
          tahun: 2024,
          nominal: 500000,
          kategori: 'Makanan',
          sisaRollover: 50000,
        );

        expect(budget.totalBudget, equals(550000));
      });

      test('returns nominal when no rollover', () {
        final budget = Budget(
          id: 1,
          bulan: 6,
          tahun: 2024,
          nominal: 500000,
          kategori: 'Makanan',
        );

        expect(budget.totalBudget, equals(500000));
      });
    });
  });

  group('Profil Model Tests', () {
    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Profil(
          id: 1,
          nama: 'Personal',
          icon: 'person',
        );

        final copy = original.copyWith(
          nama: 'Work',
          icon: 'work',
        );

        expect(copy.id, equals(1));
        expect(copy.nama, equals('Work'));
        expect(copy.icon, equals('work'));
      });

      test('preserves null createdAt', () {
        final original = Profil(nama: 'Test', icon: 'star');

        final copy = original.copyWith(nama: 'Updated');

        expect(copy.createdAt, isNull);
      });
    });
  });

  group('UtangPiutang Model Tests', () {
    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = UtangPiutang(
          id: 1,
          namaOrang: 'John Doe',
          jenis: 'utang',
          nominalTotal: 1000000,
          nominalDibayar: 250000,
          tanggal: DateTime(2024, 6, 1),
        );

        final copy = original.copyWith(nominalDibayar: 500000);

        expect(copy.id, equals(1));
        expect(copy.namaOrang, equals('John Doe'));
        expect(copy.nominalTotal, equals(1000000));
        expect(copy.nominalDibayar, equals(500000));
      });

      test('marks as lunas when fully paid', () {
        final original = UtangPiutang(
          id: 1,
          namaOrang: 'Jane Doe',
          jenis: 'piutang',
          nominalTotal: 500000,
          nominalDibayar: 0,
          tanggal: DateTime(2024, 6, 1),
          isLunas: false,
        );

        final copy = original.copyWith(
          nominalDibayar: 500000,
          isLunas: true,
        );

        expect(copy.isLunas, isTrue);
        expect(copy.nominalDibayar, equals(500000));
      });
    });
  });

  group('TabunganImpian Model Tests', () {
    group('copyWith', () {
      test('creates copy with updated progress', () {
        final original = TabunganImpian(
          id: 1,
          namaImpian: 'Liburan',
          targetNominal: 10000000,
          terkumpul: 2000000,
        );

        final copy = original.copyWith(terkumpul: 5000000);

        expect(copy.id, equals(1));
        expect(copy.namaImpian, equals('Liburan'));
        expect(copy.targetNominal, equals(10000000));
        expect(copy.terkumpul, equals(5000000));
      });
    });
  });
}