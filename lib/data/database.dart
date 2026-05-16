import 'package:sqflite/sqflite.dart';

/// Database version constant
const int DB_VERSION = 13;

/// Table name constants
const String TABLE_TRANSAKSI = 'transaksi';
const String TABLE_DOMPET = 'dompet';
const String TABLE_BUDGET = 'budget';
const String TABLE_KATEGORI = 'kategori';
const String TABLE_PENGATURAN = 'pengaturan';
const String TABLE_UTANG_PIUTANG = 'utang_piutang';
const String TABLE_HISTORY_CICILAN = 'history_cicilan';
const String TABLE_TABUNGAN_IMPIAN = 'tabungan_impian';
const String TABLE_PROFIL = 'profil';

// ---------------------------------------------------------------------------
// Schema: CREATE TABLE statements (used by _createDB)
// ---------------------------------------------------------------------------

const String CREATE_TABLE_TRANSAKSI = '''
  CREATE TABLE transaksi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    jenis TEXT NOT NULL,
    jumlah REAL NOT NULL,
    deskripsi TEXT NOT NULL,
    kategori TEXT NOT NULL,
    tanggal TEXT NOT NULL,
    id_dompet INTEGER,
    is_recurring INTEGER DEFAULT 0,
    recurring_frequency TEXT,
    lampiran TEXT,
    deleted_at TEXT
  )
''';

const String CREATE_TABLE_DOMPET = '''
  CREATE TABLE IF NOT EXISTS dompet (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    saldo REAL DEFAULT 0,
    warna TEXT NOT NULL,
    currency TEXT DEFAULT 'IDR',
    profil_id INTEGER DEFAULT 1
  )
''';

const String CREATE_TABLE_BUDGET = '''
  CREATE TABLE budget (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bulan INTEGER NOT NULL,
    tahun INTEGER NOT NULL,
    nominal REAL NOT NULL,
    kategori TEXT NOT NULL,
    profil_id INTEGER DEFAULT 1,
    sisa_rollover REAL DEFAULT 0,
    UNIQUE(bulan, tahun, kategori)
  )
''';

const String CREATE_TABLE_KATEGORI = '''
  CREATE TABLE IF NOT EXISTS kategori (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    jenis TEXT NOT NULL,
    icon TEXT DEFAULT 'category',
    is_default INTEGER DEFAULT 0
  )
''';

const String CREATE_TABLE_PENGATURAN = '''
  CREATE TABLE pengaturan (
    id INTEGER PRIMARY KEY,
    is_dark_mode INTEGER DEFAULT 0,
    pin TEXT,
    use_biometric INTEGER DEFAULT 0
  )
''';

const String CREATE_TABLE_UTANG_PIUTANG = '''
  CREATE TABLE utang_piutang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_orang TEXT NOT NULL,
    jenis TEXT NOT NULL,
    nominal_total REAL NOT NULL,
    nominal_dibayar REAL DEFAULT 0,
    tanggal TEXT NOT NULL,
    tenggat_waktu TEXT,
    deskripsi TEXT,
    is_lunas INTEGER DEFAULT 0
  )
''';

const String CREATE_TABLE_HISTORY_CICILAN = '''
  CREATE TABLE history_cicilan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_utang_piutang INTEGER NOT NULL,
    nominal REAL NOT NULL,
    tanggal TEXT NOT NULL,
    FOREIGN KEY (id_utang_piutang) REFERENCES utang_piutang (id) ON DELETE CASCADE
  )
''';

const String CREATE_TABLE_TABUNGAN_IMPIAN = '''
  CREATE TABLE tabungan_impian (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_impian TEXT NOT NULL,
    target_nominal REAL NOT NULL,
    terkumpul REAL DEFAULT 0,
    target_tanggal TEXT,
    icon TEXT DEFAULT 'savings'
  )
''';

const String CREATE_TABLE_PROFIL = '''
  CREATE TABLE profil (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    icon TEXT DEFAULT 'person',
    created_at TEXT
  )
''';

// ---------------------------------------------------------------------------
// Index creation statements
// ---------------------------------------------------------------------------

const String CREATE_INDEX_TRANSAKSI_TANGGAL =
    'CREATE INDEX IF NOT EXISTS idx_transaksi_tanggal ON transaksi(tanggal)';
const String CREATE_INDEX_TRANSAKSI_KATEGORI =
    'CREATE INDEX IF NOT EXISTS idx_transaksi_kategori ON transaksi(kategori)';
const String CREATE_INDEX_TRANSAKSI_JENIS =
    'CREATE INDEX IF NOT EXISTS idx_transaksi_jenis ON transaksi(jenis)';
const String CREATE_INDEX_TRANSAKSI_DOMPET =
    'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet ON transaksi(id_dompet)';
const String CREATE_INDEX_TRANSAKSI_DELETED =
    'CREATE INDEX IF NOT EXISTS idx_transaksi_deleted ON transaksi(deleted_at)';
const String CREATE_INDEX_TRANSAKSI_COMPOSITE =
    'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet_deleted_tanggal ON transaksi(id_dompet, deleted_at, tanggal)';
const String CREATE_INDEX_BUDGET_PERIOD =
    'CREATE INDEX IF NOT EXISTS idx_budget_period ON budget(bulan, tahun, kategori)';

// ---------------------------------------------------------------------------
// Migration: Upgrade from version 1 -> 2 (schema revision during v3)
// These ALTER TABLEs run inside onUpgrade when oldVersion < 3
// ---------------------------------------------------------------------------

const List<String> MIGRATION_V3_ALTER_TRANSAKSI = [
  'ALTER TABLE transaksi ADD COLUMN id_dompet INTEGER',
  'ALTER TABLE transaksi ADD COLUMN is_recurring INTEGER DEFAULT 0',
  'ALTER TABLE transaksi ADD COLUMN recurring_frequency TEXT',
];

// Default kategori seed data for v3 migration
const List<Map<String, dynamic>> SEED_KATEGORI_PENGELUARAN = [
  {
    'nama': 'Makanan',
    'jenis': 'pengeluaran',
    'icon': 'restaurant',
    'is_default': 1,
  },
  {
    'nama': 'Transportasi',
    'jenis': 'pengeluaran',
    'icon': 'directions_car',
    'is_default': 1,
  },
  {
    'nama': 'Belanja',
    'jenis': 'pengeluaran',
    'icon': 'shopping_bag',
    'is_default': 1,
  },
  {'nama': 'Hiburan', 'jenis': 'pengeluaran', 'icon': 'movie', 'is_default': 1},
  {
    'nama': 'Tagihan',
    'jenis': 'pengeluaran',
    'icon': 'receipt',
    'is_default': 1,
  },
  {
    'nama': 'Kesehatan',
    'jenis': 'pengeluaran',
    'icon': 'local_hospital',
    'is_default': 1,
  },
  {
    'nama': 'Rumah Tangga',
    'jenis': 'pengeluaran',
    'icon': 'home',
    'is_default': 1,
  },
  {
    'nama': 'Pendidikan',
    'jenis': 'pengeluaran',
    'icon': 'school',
    'is_default': 1,
  },
  {
    'nama': 'Fashion',
    'jenis': 'pengeluaran',
    'icon': 'checkroom',
    'is_default': 1,
  },
  {
    'nama': 'Pulsa & Data',
    'jenis': 'pengeluaran',
    'icon': 'phone_android',
    'is_default': 1,
  },
  {
    'nama': 'Usaha/Bisnis',
    'jenis': 'pengeluaran',
    'icon': 'business',
    'is_default': 1,
  },
  {
    'nama': 'Lainnya',
    'jenis': 'pengeluaran',
    'icon': 'more_horiz',
    'is_default': 1,
  },
];

const List<Map<String, dynamic>> SEED_KATEGORI_PEMASUKAN = [
  {'nama': 'Gaji', 'jenis': 'pemasukan', 'icon': 'payments', 'is_default': 1},
  {
    'nama': 'Bonus',
    'jenis': 'pemasukan',
    'icon': 'card_giftcard',
    'is_default': 1,
  },
  {'nama': 'Usaha', 'jenis': 'pemasukan', 'icon': 'store', 'is_default': 1},
  {
    'nama': 'Investasi',
    'jenis': 'pemasukan',
    'icon': 'trending_up',
    'is_default': 1,
  },
  {'nama': 'Hadiah', 'jenis': 'pemasukan', 'icon': 'redeem', 'is_default': 1},
  {
    'nama': 'Lainnya',
    'jenis': 'pemasukan',
    'icon': 'more_horiz',
    'is_default': 1,
  },
];

// ---------------------------------------------------------------------------
// Migration: Upgrade from version 1 -> latest
// Called by DatabaseHelper._upgradeDB()
// ---------------------------------------------------------------------------

Future<void> runMigrations(Database db, int oldVersion, int newVersion) async {
  // NOTE: All catch blocks below are intentionally silent — ALTER TABLE / CREATE TABLE
  // IF NOT EXISTS / INSERT statements may fail if the column/table already exists
  // (e.g., when migrating from an older schema version). These are non-fatal.

  if (oldVersion < 3) {
    for (final sql in MIGRATION_V3_ALTER_TRANSAKSI) {
      try {
        await db.execute(sql);
      } catch (_) {
        // Intentionally silent — column may already exist
      }
    }

    try {
      await db.execute(CREATE_TABLE_DOMPET);
    } catch (_) {
      // Intentionally silent — table may already exist
    }
    try {
      await db.execute(CREATE_TABLE_BUDGET);
    } catch (_) {
      // Intentionally silent — table may already exist
    }
    try {
      await db.execute(CREATE_TABLE_PENGATURAN);
    } catch (_) {
      // Intentionally silent — table may already exist
    }

    try {
      await db.insert(TABLE_DOMPET, {
        'nama': 'Dompet Utama',
        'saldo': 0.0,
        'warna': 'green',
      });
    } catch (_) {
      // Intentionally silent — row may already exist
    }
    try {
      await db.insert(TABLE_PENGATURAN, {'id': 1, 'is_dark_mode': 0});
    } catch (_) {
      // Intentionally silent — row may already exist
    }
  }

  if (oldVersion < 4) {
    try {
      await db.execute('ALTER TABLE transaksi ADD COLUMN lampiran TEXT');
    } catch (_) {
      // Intentionally silent — column may already exist
    }
  }

  if (oldVersion < 5) {
    try {
      await db.execute(CREATE_TABLE_KATEGORI);

      for (var k in [
        ...SEED_KATEGORI_PENGELUARAN,
        ...SEED_KATEGORI_PEMASUKAN,
      ]) {
        await db.insert(TABLE_KATEGORI, k);
      }
    } catch (_) {
      // Intentionally silent — table may already exist
    }
  }

  if (oldVersion < 6) {
    try {
      await db.execute(CREATE_INDEX_TRANSAKSI_TANGGAL);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
    try {
      await db.execute(CREATE_INDEX_TRANSAKSI_KATEGORI);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
    try {
      await db.execute(CREATE_INDEX_TRANSAKSI_JENIS);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
    try {
      await db.execute(CREATE_INDEX_TRANSAKSI_DOMPET);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
    try {
      await db.execute(CREATE_INDEX_BUDGET_PERIOD);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
    try {
      await db.execute(
        'CREATE UNIQUE INDEX idx_budget_unique ON budget(bulan, tahun, kategori)',
      );
    } catch (_) {
      // Intentionally silent — index may already exist
    }
  }

  if (oldVersion < 7) {
    try {
      await db.execute('ALTER TABLE transaksi ADD COLUMN deleted_at TEXT');
    } catch (_) {
      // Intentionally silent — column may already exist
    }
  }

  if (oldVersion < 8) {
    try {
      await db.execute(
        'ALTER TABLE pengaturan ADD COLUMN use_biometric INTEGER DEFAULT 0',
      );
    } catch (_) {
      // Intentionally silent — column may already exist
    }
  }

  if (oldVersion < 9) {
    try {
      await db.execute(CREATE_TABLE_UTANG_PIUTANG);
      await db.execute(CREATE_TABLE_HISTORY_CICILAN);
      await db.execute(CREATE_TABLE_TABUNGAN_IMPIAN);
    } catch (_) {
      // Intentionally silent — tables may already exist
    }
  }

  if (oldVersion < 10) {
    try {
      await db.execute(
        "ALTER TABLE dompet ADD COLUMN currency TEXT DEFAULT 'IDR'",
      );
    } catch (_) {
      // Intentionally silent — column may already exist
    }
  }

  if (oldVersion < 11) {
    try {
      await db.execute(CREATE_TABLE_PROFIL);
    } catch (_) {
      // Intentionally silent
    }
    try {
      await db.execute(
        "ALTER TABLE dompet ADD COLUMN profil_id INTEGER DEFAULT 1",
      );
    } catch (_) {
      // Intentionally silent — column may already exist
    }
    try {
      await db.execute(
        "ALTER TABLE budget ADD COLUMN profil_id INTEGER DEFAULT 1",
      );
    } catch (_) {
      // Intentionally silent
    }
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_dompet_profil ON dompet(profil_id)',
      );
    } catch (_) {
      // Intentionally silent
    }
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_budget_profil ON budget(profil_id)',
      );
    } catch (_) {
      // Intentionally silent
    }
    // Seed default profil "Pribadi"
    try {
      final nowStr = DateTime.now().toIso8601String();
      await db.insert(TABLE_PROFIL, {
        'id': 1,
        'nama': 'Pribadi',
        'icon': 'person',
        'created_at': nowStr,
      });
    } catch (_) {
      // Intentionally silent — already exists
    }
  }

  if (oldVersion < 12) {
    try {
      await db.execute(
        "ALTER TABLE budget ADD COLUMN sisa_rollover REAL DEFAULT 0",
      );
    } catch (_) {
      // Intentionally silent — column may already exist
    }
  }

  if (oldVersion < 13) {
    // Performance optimization: Add index on deleted_at for soft-delete queries
    try {
      await db.execute(CREATE_INDEX_TRANSAKSI_DELETED);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
    // Performance optimization: Add composite index for filtered transaction queries
    // This covers queries that filter by id_dompet, deleted_at, and tanggal together
    try {
      await db.execute(CREATE_INDEX_TRANSAKSI_COMPOSITE);
    } catch (_) {
      // Intentionally silent — index may already exist
    }
  }
}

// ---------------------------------------------------------------------------
// Schema: Initial DB creation (_createDB)
// Called by DatabaseHelper._initDB() on first open
// ---------------------------------------------------------------------------

Future<void> createSchema(Database db, int version) async {
  await db.execute(CREATE_TABLE_TRANSAKSI);

  await db.execute(CREATE_INDEX_TRANSAKSI_TANGGAL);
  await db.execute(CREATE_INDEX_TRANSAKSI_KATEGORI);
  await db.execute(CREATE_INDEX_TRANSAKSI_JENIS);
  await db.execute(CREATE_INDEX_TRANSAKSI_DOMPET);
  await db.execute(CREATE_INDEX_TRANSAKSI_DELETED);
  await db.execute(CREATE_INDEX_TRANSAKSI_COMPOSITE);

  await db.execute(CREATE_TABLE_DOMPET);

  await db.execute(CREATE_TABLE_BUDGET);
  await db.execute(CREATE_INDEX_BUDGET_PERIOD);

  await db.execute(CREATE_TABLE_KATEGORI);

  for (var k in [...SEED_KATEGORI_PENGELUARAN, ...SEED_KATEGORI_PEMASUKAN]) {
    await db.insert(TABLE_KATEGORI, k);
  }

  await db.execute(CREATE_TABLE_PENGATURAN);

  await db.execute(CREATE_TABLE_UTANG_PIUTANG);
  await db.execute(CREATE_TABLE_HISTORY_CICILAN);
  await db.execute(CREATE_TABLE_TABUNGAN_IMPIAN);

  await db.execute(CREATE_TABLE_PROFIL);
  await db.insert(TABLE_PROFIL, {
    'id': 1,
    'nama': 'Pribadi',
    'icon': 'person',
    'created_at': DateTime.now().toIso8601String(),
  });

  await db.insert(TABLE_PENGATURAN, {'id': 1, 'is_dark_mode': 0});
  await db.insert(TABLE_DOMPET, {
    'nama': 'Dompet Utama',
    'saldo': 0.0,
    'warna': 'green',
    'profil_id': 1,
  });
}
