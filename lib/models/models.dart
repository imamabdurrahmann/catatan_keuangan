import 'dart:convert';

/// Frequency options for recurring transactions.
enum RecurringFrequency { daily, weekly, monthly, quarterly, yearly }

class Transaksi {
  final int? id;
  final String jenis;
  final double jumlah;
  final String deskripsi;
  final String kategori;
  final DateTime tanggal;
  final List<String> lampiran;
  final bool isRecurring;
  final String? recurringFrequency;
  final int? idDompet;
  final DateTime? deletedAt;

  Transaksi({
    this.id,
    required this.jenis,
    required this.jumlah,
    required this.deskripsi,
    required this.kategori,
    required this.tanggal,
    this.lampiran = const [],
    this.isRecurring = false,
    this.recurringFrequency,
    this.idDompet,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'jenis': jenis,
      'jumlah': jumlah,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'tanggal':
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')} ${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}:${tanggal.second.toString().padLeft(2, '0')}',
      'lampiran': jsonEncode(lampiran),
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_frequency': recurringFrequency,
      if (idDompet != null) 'id_dompet': idDompet,
      if (deletedAt != null)
        'deleted_at':
            '${deletedAt!.year}-${deletedAt!.month.toString().padLeft(2, '0')}-${deletedAt!.day.toString().padLeft(2, '0')} ${deletedAt!.hour.toString().padLeft(2, '0')}:${deletedAt!.minute.toString().padLeft(2, '0')}:${deletedAt!.second.toString().padLeft(2, '0')}',
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    List<String> parsedLampiran = [];
    if (map['lampiran'] != null && map['lampiran'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['lampiran'] as String);
        if (decoded is List) {
          parsedLampiran = decoded.cast<String>();
        }
      } catch (_) {
        parsedLampiran = [];
      }
    }

    DateTime? parsedDeletedAt;
    if (map['deleted_at'] != null && map['deleted_at'].toString().isNotEmpty) {
      try {
        parsedDeletedAt = DateTime.parse(map['deleted_at'] as String);
      } catch (_) {
        parsedDeletedAt = null;
      }
    }

    return Transaksi(
      id: map['id'] as int?,
      jenis: map['jenis'] as String,
      jumlah: (map['jumlah'] as num).toDouble(),
      deskripsi: map['deskripsi'] as String,
      kategori: map['kategori'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      lampiran: parsedLampiran,
      isRecurring: map['is_recurring'] == 1,
      recurringFrequency: map['recurring_frequency'] as String?,
      idDompet: map['id_dompet'] as int?,
      deletedAt: parsedDeletedAt,
    );
  }

  Transaksi copyWith({
    int? id,
    String? jenis,
    double? jumlah,
    String? deskripsi,
    String? kategori,
    DateTime? tanggal,
    List<String>? lampiran,
    bool? isRecurring,
    String? recurringFrequency,
    int? idDompet,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Transaksi(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      jumlah: jumlah ?? this.jumlah,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      tanggal: tanggal ?? this.tanggal,
      lampiran: lampiran ?? this.lampiran,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      idDompet: idDompet ?? this.idDompet,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

class Dompet {
  final int? id;
  final String nama;
  final double saldo;
  final String warna;
  final String currency;
  final int profilId;

  Dompet({
    this.id,
    required this.nama,
    this.saldo = 0,
    required this.warna,
    this.currency = 'IDR',
    this.profilId = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'saldo': saldo,
      'warna': warna,
      'currency': currency,
      'profil_id': profilId,
    };
  }

  factory Dompet.fromMap(Map<String, dynamic> map) {
    return Dompet(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      saldo: (map['saldo'] as num?)?.toDouble() ?? 0,
      warna: map['warna'] as String,
      currency: map['currency'] as String? ?? 'IDR',
      profilId: map['profil_id'] as int? ?? 1,
    );
  }

  Dompet copyWith({
    int? id,
    String? nama,
    double? saldo,
    String? warna,
    String? currency,
    int? profilId,
  }) {
    return Dompet(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      saldo: saldo ?? this.saldo,
      warna: warna ?? this.warna,
      currency: currency ?? this.currency,
      profilId: profilId ?? this.profilId,
    );
  }
}

class Kategori {
  final int? id;
  final String nama;
  final String jenis;
  final String icon;
  final bool isDefault;

  Kategori({
    this.id,
    required this.nama,
    required this.jenis,
    this.icon = 'category',
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis': jenis,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      jenis: map['jenis'] as String,
      icon: map['icon'] as String? ?? 'category',
      isDefault: map['is_default'] == 1,
    );
  }

  Kategori copyWith({
    int? id,
    String? nama,
    String? jenis,
    String? icon,
    bool? isDefault,
  }) {
    return Kategori(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class Budget {
  final int? id;
  final int bulan;
  final int tahun;
  final double nominal;
  final String kategori;
  final int profilId;
  final double sisaRollover;

  Budget({
    this.id,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.kategori,
    this.profilId = 1,
    this.sisaRollover = 0,
  });

  /// Total budget including rollover (effective budget)
  double get totalBudget => nominal + sisaRollover;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bulan': bulan,
      'tahun': tahun,
      'nominal': nominal,
      'kategori': kategori,
      'profil_id': profilId,
      'sisa_rollover': sisaRollover,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      bulan: map['bulan'] as int,
      tahun: map['tahun'] as int,
      nominal: (map['nominal'] as num).toDouble(),
      kategori: map['kategori'] as String,
      profilId: map['profil_id'] as int? ?? 1,
      sisaRollover: (map['sisa_rollover'] as num?)?.toDouble() ?? 0,
    );
  }

  Budget copyWith({
    int? id,
    int? bulan,
    int? tahun,
    double? nominal,
    String? kategori,
    int? profilId,
    double? sisaRollover,
  }) {
    return Budget(
      id: id ?? this.id,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
      profilId: profilId ?? this.profilId,
      sisaRollover: sisaRollover ?? this.sisaRollover,
    );
  }
}

class Pengaturan {
  final int? id;
  final bool isDarkMode;
  final String? pin;
  final bool useBiometric;

  Pengaturan({
    this.id,
    this.isDarkMode = false,
    this.pin,
    this.useBiometric = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'pin': pin,
      'use_biometric': useBiometric ? 1 : 0,
    };
  }

  factory Pengaturan.fromMap(Map<String, dynamic> map) {
    return Pengaturan(
      id: map['id'] as int?,
      isDarkMode: map['is_dark_mode'] == 1,
      pin: map['pin'] as String?,
      useBiometric: map['use_biometric'] == 1,
    );
  }

  Pengaturan copyWith({bool? isDarkMode, String? pin, bool? useBiometric}) {
    return Pengaturan(
      id: id,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      pin: pin ?? this.pin,
      useBiometric: useBiometric ?? this.useBiometric,
    );
  }
}

class UtangPiutang {
  final int? id;
  final String namaOrang;
  final String
  jenis; // 'utang' (kita berutang) atau 'piutang' (orang berutang ke kita)
  final double nominalTotal;
  final double nominalDibayar;
  final DateTime tanggal;
  final DateTime? tenggatWaktu;
  final String? deskripsi;
  final bool isLunas;

  UtangPiutang({
    this.id,
    required this.namaOrang,
    required this.jenis,
    required this.nominalTotal,
    this.nominalDibayar = 0,
    required this.tanggal,
    this.tenggatWaktu,
    this.deskripsi,
    this.isLunas = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_orang': namaOrang,
      'jenis': jenis,
      'nominal_total': nominalTotal,
      'nominal_dibayar': nominalDibayar,
      'tanggal': tanggal.toIso8601String(),
      'tenggat_waktu': tenggatWaktu?.toIso8601String(),
      'deskripsi': deskripsi,
      'is_lunas': isLunas ? 1 : 0,
    };
  }

  factory UtangPiutang.fromMap(Map<String, dynamic> map) {
    return UtangPiutang(
      id: map['id'] as int?,
      namaOrang: map['nama_orang'] as String,
      jenis: map['jenis'] as String,
      nominalTotal: (map['nominal_total'] as num).toDouble(),
      nominalDibayar: (map['nominal_dibayar'] as num).toDouble(),
      tanggal: DateTime.parse(map['tanggal'] as String),
      tenggatWaktu: map['tenggat_waktu'] != null
          ? DateTime.parse(map['tenggat_waktu'] as String)
          : null,
      deskripsi: map['deskripsi'] as String?,
      isLunas: map['is_lunas'] == 1,
    );
  }

  UtangPiutang copyWith({
    int? id,
    String? namaOrang,
    String? jenis,
    double? nominalTotal,
    double? nominalDibayar,
    DateTime? tanggal,
    DateTime? tenggatWaktu,
    String? deskripsi,
    bool? isLunas,
  }) {
    return UtangPiutang(
      id: id ?? this.id,
      namaOrang: namaOrang ?? this.namaOrang,
      jenis: jenis ?? this.jenis,
      nominalTotal: nominalTotal ?? this.nominalTotal,
      nominalDibayar: nominalDibayar ?? this.nominalDibayar,
      tanggal: tanggal ?? this.tanggal,
      tenggatWaktu: tenggatWaktu ?? this.tenggatWaktu,
      deskripsi: deskripsi ?? this.deskripsi,
      isLunas: isLunas ?? this.isLunas,
    );
  }
}

class HistoryCicilan {
  final int? id;
  final int idUtangPiutang;
  final double nominal;
  final DateTime tanggal;

  HistoryCicilan({
    this.id,
    required this.idUtangPiutang,
    required this.nominal,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_utang_piutang': idUtangPiutang,
      'nominal': nominal,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory HistoryCicilan.fromMap(Map<String, dynamic> map) {
    return HistoryCicilan(
      id: map['id'] as int?,
      idUtangPiutang: map['id_utang_piutang'] as int,
      nominal: (map['nominal'] as num).toDouble(),
      tanggal: DateTime.parse(map['tanggal'] as String),
    );
  }
}

class TabunganImpian {
  final int? id;
  final String namaImpian;
  final double targetNominal;
  final double terkumpul;
  final DateTime? targetTanggal;
  final String icon;

  TabunganImpian({
    this.id,
    required this.namaImpian,
    required this.targetNominal,
    this.terkumpul = 0,
    this.targetTanggal,
    this.icon = 'savings',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_impian': namaImpian,
      'target_nominal': targetNominal,
      'terkumpul': terkumpul,
      'target_tanggal': targetTanggal?.toIso8601String(),
      'icon': icon,
    };
  }

  factory TabunganImpian.fromMap(Map<String, dynamic> map) {
    return TabunganImpian(
      id: map['id'] as int?,
      namaImpian: map['nama_impian'] as String,
      targetNominal: (map['target_nominal'] as num).toDouble(),
      terkumpul: (map['terkumpul'] as num).toDouble(),
      targetTanggal: map['target_tanggal'] != null
          ? DateTime.parse(map['target_tanggal'] as String)
          : null,
      icon: map['icon'] as String? ?? 'savings',
    );
  }

  TabunganImpian copyWith({
    int? id,
    String? namaImpian,
    double? targetNominal,
    double? terkumpul,
    DateTime? targetTanggal,
    String? icon,
  }) {
    return TabunganImpian(
      id: id ?? this.id,
      namaImpian: namaImpian ?? this.namaImpian,
      targetNominal: targetNominal ?? this.targetNominal,
      terkumpul: terkumpul ?? this.terkumpul,
      targetTanggal: targetTanggal ?? this.targetTanggal,
      icon: icon ?? this.icon,
    );
  }
}

class Profil {
  final int? id;
  final String nama;
  final String icon;
  final DateTime? createdAt;

  Profil({this.id, required this.nama, this.icon = 'person', this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'icon': icon,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Profil.fromMap(Map<String, dynamic> map) {
    return Profil(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      icon: map['icon'] as String? ?? 'person',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Profil copyWith({int? id, String? nama, String? icon, DateTime? createdAt}) {
    return Profil(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
