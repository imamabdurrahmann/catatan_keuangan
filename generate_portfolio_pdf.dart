import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

void main() async {
  print('Generating DompetKu Portfolio PDF...');
  final pdf = pw.Document();

  // Predefine all colors
  final cDarkBg = PdfColor.fromInt(0xFF0A0E14);
  final cPrimaryDark = PdfColor.fromInt(0xFF0D2818);
  final cPrimaryMid = PdfColor.fromInt(0xFF1B5E20);
  final cEmerald = PdfColor.fromInt(0xFF10B981);
  final cEmeraldLight = PdfColor.fromInt(0xFF34D399);
  final cDarkBorder = PdfColor.fromInt(0xFF2A3040);
  final cTextPrimary = PdfColor.fromInt(0xFF1A1A2E);
  final cTextSecondary = PdfColor.fromInt(0xFF6B7280);
  final cTextMuted = PdfColor.fromInt(0xFF9CA3AF);
  final cCoral = PdfColor.fromInt(0xFFF87171);
  final cGold = PdfColor.fromInt(0xFFFBBF24);
  final cPurple = PdfColor.fromInt(0xFF8B5CF6);
  final cBgF8 = PdfColor.fromInt(0xFFF8FAFC);
  final cGreen10 = PdfColor.fromInt(0xFFF0FDF4);

  // Predefined opacity colors
  final cWhite15 = PdfColor.fromInt(0x26FFFFFF);
  final cWhite60 = PdfColor.fromInt(0x99FFFFFF);
  final cWhite80 = PdfColor.fromInt(0xCCFFFFFF);
  final cWhite40 = PdfColor.fromInt(0x66FFFFFF);
  final cWhite20 = PdfColor.fromInt(0x33FFFFFF);
  final cBorder80 = PdfColor.fromInt(0xCC2A3040);
  final cGreen30 = PdfColor.fromInt(0x4D10B981);
  final cGoldBorder = PdfColor.fromInt(0x80FBBF24);
  final cGoldText = PdfColor.fromInt(0xFFD97706);
  final cGoldBg = PdfColor.fromInt(0xFFFFF7ED);
  final cEmerald10 = PdfColor.fromInt(0x1A10B981);
  final cPrimaryText = PdfColor.fromInt(0xFF1B5E20);

  // Helper widgets
  pw.Widget hdr(String text) => pw.Row(
    children: [
      pw.Container(
        width: 4,
        height: 22,
        decoration: pw.BoxDecoration(
          color: cPrimaryMid,
          borderRadius: pw.BorderRadius.circular(2),
        ),
      ),
      pw.SizedBox(width: 14),
      pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: cPrimaryMid,
          letterSpacing: 1,
        ),
      ),
    ],
  );

  pw.Widget statB(String v, String l) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        v,
        style: pw.TextStyle(
          fontSize: 32,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
      pw.Text(l, style: pw.TextStyle(fontSize: 11, color: cWhite60)),
    ],
  );

  pw.Widget statB2(String v, String l) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        v,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
      pw.Text(l, style: pw.TextStyle(fontSize: 10, color: cWhite40)),
    ],
  );

  pw.Widget statCard(String v, String l, PdfColor c) => pw.Container(
    width: 150,
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: cBgF8,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: cBorder80),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          v,
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: c,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(l, style: pw.TextStyle(fontSize: 11, color: cTextSecondary)),
      ],
    ),
  );

  pw.Widget featCard(
    String emoji,
    String title,
    String desc,
    List<String> tags,
  ) => pw.Container(
    padding: const pw.EdgeInsets.all(24),
    decoration: pw.BoxDecoration(
      color: cBgF8,
      borderRadius: pw.BorderRadius.circular(16),
      border: pw.Border.all(color: PdfColor.fromInt(0x662A3040)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 52,
              height: 52,
              decoration: pw.BoxDecoration(
                color: cPrimaryMid,
                borderRadius: pw.BorderRadius.circular(14),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(emoji, style: const pw.TextStyle(fontSize: 22)),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          desc,
          style: pw.TextStyle(
            fontSize: 11,
            color: cTextSecondary,
            lineSpacing: 5,
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map<pw.Widget>(
                (tag) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: cEmerald10,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    tag,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: cPrimaryText,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  pw.Widget archL(String name, String sub, List<String> items) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(colors: [cPrimaryDark, cPrimaryMid]),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 130,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(sub, style: pw.TextStyle(fontSize: 9, color: cWhite60)),
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map(
                  (item) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: pw.BoxDecoration(
                      color: cWhite20,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      item,
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.white),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );

  pw.Widget pattBox(String title, String body) => pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: cGreen10,
      borderRadius: pw.BorderRadius.circular(10),
      border: pw.Border.all(color: cGreen30),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: cPrimaryMid,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(body, style: pw.TextStyle(fontSize: 10, color: cTextSecondary)),
      ],
    ),
  );

  pw.Widget treeLine(String text) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 8,
      color: cEmeraldLight,
      font: pw.Font.courier(),
    ),
  );

  pw.Widget secCard(
    String emoji,
    String title,
    String desc,
    List<String> tags,
  ) => pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: PdfColor.fromInt(0x662A3040)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(emoji, style: const pw.TextStyle(fontSize: 26)),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(desc, style: pw.TextStyle(fontSize: 11, color: cTextSecondary)),
        pw.SizedBox(height: 12),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map<pw.Widget>(
                (tag) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: cGoldBg,
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(color: cGoldBorder),
                  ),
                  child: pw.Text(
                    tag,
                    style: pw.TextStyle(fontSize: 10, color: cGoldText),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  pw.Widget ciPhase(
    String num,
    String title,
    String cmd,
    String desc,
    PdfColor c,
  ) => pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: c),
    ),
    child: pw.Row(
      children: [
        pw.Container(
          width: 40,
          height: 40,
          decoration: pw.BoxDecoration(
            color: c,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(
            num,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: c,
                ),
              ),
              pw.Text(
                cmd,
                style: pw.TextStyle(fontSize: 10, color: cTextMuted),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                desc,
                style: pw.TextStyle(fontSize: 9, color: cTextSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  pw.Widget testCard() => pw.Container(
    padding: const pw.EdgeInsets.all(24),
    decoration: pw.BoxDecoration(
      color: cBgF8,
      borderRadius: pw.BorderRadius.circular(16),
      border: pw.Border.all(color: cBorder80),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Test Coverage',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: cTextPrimary,
          ),
        ),
        pw.SizedBox(height: 16),
        ...[
          ('Model Tests', '35 tests', cPrimaryMid),
          ('DAO Tests', '42 tests', cEmerald),
          ('Service Tests', '12 tests', cPurple),
          ('Widget Tests', '82 tests', cGold),
        ].map(
          (r) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  r.$1,
                  style: pw.TextStyle(fontSize: 11, color: cTextSecondary),
                ),
                pw.Text(
                  r.$2,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: r.$3,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: cDarkBorder),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Total',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: cEmerald,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                '171 PASS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  pw.Widget wfBox(String file, String desc) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: pw.BoxDecoration(
      color: cBgF8,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColor.fromInt(0x4D2A3040)),
    ),
    child: pw.Row(
      children: [
        pw.Text(
          file,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: cTextPrimary,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text('→', style: pw.TextStyle(color: cEmerald)),
        pw.SizedBox(width: 8),
        pw.Text(desc, style: pw.TextStyle(fontSize: 10, color: cTextSecondary)),
      ],
    ),
  );

  // ==================== PAGE 1: COVER ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        width: double.infinity,
        height: double.infinity,
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(colors: [cPrimaryDark, cPrimaryMid]),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 80),
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: cWhite15,
                  borderRadius: pw.BorderRadius.circular(24),
                ),
                child: pw.Text('💰', style: const pw.TextStyle(fontSize: 48)),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'DompetKu',
                style: pw.TextStyle(
                  fontSize: 64,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: -3,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Aplikasi Pencatatan Keuangan Personal',
                style: pw.TextStyle(fontSize: 20, color: cWhite80),
              ),
              pw.SizedBox(height: 56),
              pw.Container(
                width: 80,
                height: 4,
                decoration: pw.BoxDecoration(
                  color: cEmerald,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                'Technical Portfolio Document',
                style: pw.TextStyle(fontSize: 14, color: cWhite60),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'v1.0.0  •  April 2026',
                style: pw.TextStyle(fontSize: 12, color: cWhite40),
              ),
              pw.Spacer(),
              pw.Row(
                children: [
                  statB('10+', 'Features'),
                  pw.SizedBox(width: 48),
                  statB('171', 'Tests Pass'),
                  pw.SizedBox(width: 48),
                  statB('3', 'Languages'),
                  pw.SizedBox(width: 48),
                  statB('9', 'DB Tables'),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 2: TOC ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: cBgF8,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('TABLE OF CONTENTS'),
              pw.SizedBox(height: 32),
              pw.Text(
                'Daftar Isi',
                style: pw.TextStyle(
                  fontSize: 40,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: cDarkBorder, thickness: 1),
              pw.SizedBox(height: 16),
              ...[
                ('01', 'Overview', 'Tentang DompetKu dan visi misi'),
                ('02', 'Fitur Utama', '10+ fitur yang membedakan'),
                ('03', 'Tech Stack', 'Stack teknologi yang digunakan'),
                ('04', 'Arsitektur', 'Clean architecture & design pattern'),
                ('05', 'Keamanan', 'Encryption & biometric auth'),
                ('06', 'Testing & CI/CD', 'Quality assurance pipeline'),
                ('07', 'Closing', 'Ringkasan & next steps'),
              ].map(
                (s) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 14),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 52,
                        height: 52,
                        decoration: pw.BoxDecoration(
                          color: cPrimaryMid,
                          borderRadius: pw.BorderRadius.circular(14),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          s.$1,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              s.$2,
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: cTextPrimary,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              s.$3,
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: cTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        '→',
                        style: pw.TextStyle(fontSize: 22, color: cEmerald),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 3: OVERVIEW ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: PdfColors.white,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('01  OVERVIEW'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Tentang DompetKu',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'DompetKu adalah aplikasi pencatatan keuangan personal yang dibangun untuk memudahkan '
                'pengelolaan keuangan sehari-hari. Dirancang untuk menjadi solusi nyata yang dipakai developer '
                'sendiri setiap hari — bukan aplikasi tutorial, bukan template.',
                style: pw.TextStyle(
                  fontSize: 13,
                  color: cTextSecondary,
                  lineSpacing: 6,
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Container(
                padding: const pw.EdgeInsets.all(28),
                decoration: pw.BoxDecoration(
                  color: cPrimaryMid,
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VISI',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: cEmeraldLight,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Membantu setiap orang mengelola keuangan personal dengan mudah, terstruktur, dan tanpa hambatan.',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                        lineSpacing: 5,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  statCard('171', 'Unit & Widget Tests', cEmerald),
                  statCard('10+', 'Fitur Utama', cPrimaryMid),
                  statCard('3', 'Platform Support', cPurple),
                  statCard('100%', 'Passing Rate', cGold),
                  statCard('9', 'Database Tables', cCoral),
                  statCard('CI/CD', 'Automated Pipeline', cTextSecondary),
                ],
              ),
              pw.SizedBox(height: 36),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: cGreen10,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: cGreen30),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Mengapa DompetKu berbeda?',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: cPrimaryMid,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Kebanyakan aplikasi keuangan hanya jadi tracker. DompetKu menjadi partner keuangan: '
                      'otomatis mengingatkan budget, scheduling transaksi berulang, scan kwitansi.',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: cTextSecondary,
                        lineSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 4: FEATURES 1 ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: PdfColors.white,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('02  FITUR UTAMA'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Fitur Unggulan',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 32),
              featCard(
                '💰',
                'Pencatatan Transaksi',
                'Catat pemasukan dan pengeluaran dengan kategorisasi lengkap. Multi-wallet dengan dukungan multi-currency (IDR, USD, EUR, SGD). Filter berdasarkan tanggal, kategori, dan dompet.',
                ['Soft delete', 'Lampiran gambar', 'Pencarian cepat'],
              ),
              pw.SizedBox(height: 20),
              featCard(
                '📊',
                'Budget Bulanan',
                'Atur anggaran per kategori untuk setiap bulan. Progress bar real-time yang otomatis update setiap transaksi baru. Warning notifikasi saat budget hampir tercapai.',
                ['Visual progress', 'Warning 80%+', 'Per kategori'],
              ),
              pw.SizedBox(height: 20),
              featCard(
                '🎯',
                'Tabungan Impian',
                'Buat target tabungan dengan nominal dan tanggal target. Tracking progress otomatis. Milestone notification saat progress mencapai 50%, 75%, dan 100%.',
                ['Target-based', 'Progress tracking', 'Milestone notif'],
              ),
              pw.SizedBox(height: 20),
              featCard(
                '💳',
                'Utang & Piutang',
                'Kelola utang dan piutang dengan cicilan otomatis. Tracking history pembayaran. Notifikasi jatuh tempo.',
                ['Cicilan tracking', 'History payments', 'Due date notif'],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 5: FEATURES 2 ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: PdfColors.white,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('02  FITUR UTAMA'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Fitur Unggulan (Lanjutan)',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 32),
              featCard(
                '🔄',
                'Recurring Transaction',
                'Transaksi berulang yang otomatis dibuat berdasarkan jadwal: daily, weekly, monthly, quarterly, atau yearly. Sistem hanya memproses sekali per hari untuk efisiensi.',
                ['5 frequency types', 'Auto-create', 'Daily check'],
              ),
              pw.SizedBox(height: 20),
              featCard(
                '📄',
                'OCR Receipt Scanner',
                'Scan kwitansi dengan Google ML Kit Text Recognition. Otomatis ekstrak jumlah dan detail dari kwitansi. Hanya perlu foto, data langsung terisi.',
                ['Auto-extract', 'ML Kit OCR', 'Text recognition'],
              ),
              pw.SizedBox(height: 20),
              featCard(
                '📤',
                'Export & Backup',
                'Backup data dalam format JSON yang bisa direstore kapan saja. Export transaksi ke CSV untuk analisis di Excel. Generate PDF report dengan branding DompetKu.',
                ['JSON backup', 'CSV export', 'PDF report'],
              ),
              pw.SizedBox(height: 20),
              featCard(
                '🔐',
                'Keamanan',
                'Biometric authentication (fingerprint/face) untuk keamanan. PIN fallback untuk perangkat tanpa sensor biometric. AES-256 encryption untuk data sensitif.',
                ['Biometric', 'PIN lock', 'AES-256'],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 6: TECH STACK ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: cBgF8,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('03  TECH STACK'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Tech Stack',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 32),
              ...[
                (
                  '📱  MOBILE',
                  ['Flutter 3.11', 'Dart 3.11', 'Material Design 3'],
                ),
                (
                  '⚡  STATE MANAGEMENT',
                  ['Riverpod 3.x', 'Notifier pattern', 'AsyncNotifier'],
                ),
                (
                  '🧭  NAVIGATION',
                  ['GoRouter 14.x', 'Deep linking', 'Declarative routing'],
                ),
                (
                  '🗄️  DATABASE',
                  ['SQLite via sqflite', 'DAO Pattern', '9 tabel + migration'],
                ),
                (
                  '🔒  SECURITY',
                  [
                    'AES-256 encryption',
                    'Biometric (local_auth)',
                    'PIN fallback',
                  ],
                ),
                (
                  '🔔  NOTIFICATIONS',
                  [
                    'flutter_local_notifications',
                    '4 channel (Budget/Debt/Savings/Achievement)',
                  ],
                ),
                (
                  '📄  DOCUMENT',
                  ['PDF generation', 'CSV export', 'JSON backup'],
                ),
                ('🔬  ML/AI', ['Google ML Kit OCR', 'Receipt scanning']),
                (
                  '🧪  TESTING',
                  ['flutter_test', 'mocktail', 'sqflite_common_ffi'],
                ),
                (
                  '⚙️  CI/CD',
                  ['GitHub Actions', '3 workflows', 'Auto build & test'],
                ),
                (
                  '🎨  UI/UX',
                  [
                    'fl_chart (charts)',
                    'lottie (animations)',
                    'PlusJakartaSans font',
                  ],
                ),
                (
                  '📦  OTHERS',
                  [
                    'home_widget',
                    'table_calendar',
                    'share_plus',
                    'permission_handler',
                  ],
                ),
              ].map(
                (row) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 14),
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColor.fromInt(0x4D2A3040)),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 190,
                        child: pw.Text(
                          row.$1,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: cPrimaryMid,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: row.$2
                              .map<pw.Widget>(
                                (item) => pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: pw.BoxDecoration(
                                    color: cPrimaryMid,
                                    borderRadius: pw.BorderRadius.circular(20),
                                  ),
                                  child: pw.Text(
                                    item,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.white,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 7: ARCHITECTURE ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: PdfColors.white,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('04  ARSITEKTUR'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Clean Architecture',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 32),
              archL('Presentation', 'UI Layer', [
                'Pages',
                'Tabs',
                'Widgets',
                'Theme',
              ]),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 60),
                child: pw.Text(
                  '↓',
                  style: pw.TextStyle(fontSize: 16, color: cTextSecondary),
                ),
              ),
              archL('Logic', 'State & Business', [
                'Providers',
                'State Management',
                'Update Signals',
              ]),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 60),
                child: pw.Text(
                  '↓',
                  style: pw.TextStyle(fontSize: 16, color: cTextSecondary),
                ),
              ),
              archL('Data', 'Data Access', [
                'DAOs (8 files)',
                'Database',
                'Migrations',
              ]),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 60),
                child: pw.Text(
                  '↓',
                  style: pw.TextStyle(fontSize: 16, color: cTextSecondary),
                ),
              ),
              archL('Services', 'Business Logic', [
                'BackupService',
                'ExportService',
                'NotificationService',
                'RecurringScheduler',
              ]),
              pw.SizedBox(height: 28),
              pw.Text(
                'Package Structure',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: cDarkBg,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'lib/',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: cEmeraldLight,
                        font: pw.Font.courier(),
                      ),
                    ),
                    treeLine('|-- config/          -> AppConfig'),
                    treeLine(
                      '|-- data/            -> DAOs, database, migrations',
                    ),
                    treeLine(
                      '|   -- daos/       -> 7 DAO files (transaksi, dompet, kategori, ...)',
                    ),
                    treeLine('|-- l10n/            -> i18n (ID + EN)'),
                    treeLine('|-- models/           -> Domain models'),
                    treeLine('|-- pages/            -> All screens'),
                    treeLine('|   |-- tabs/'),
                    treeLine(
                      '|   |   |-- dashboard/     -> 8 dashboard widgets',
                    ),
                    treeLine('|   |   -- tab_*.dart'),
                    treeLine('|   -- widgets/'),
                    treeLine('|-- providers/       -> Riverpod providers'),
                    treeLine('|-- services/        -> Business logic services'),
                    treeLine(
                      '|-- theme/           -> Colors, typography, decorations',
                    ),
                    treeLine('|-- utils/           -> Formatters, helpers'),
                    treeLine('|-- widgets/          -> Common widgets'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pattBox(
                'Provider Pattern',
                'Riverpod dengan Notifier/AsyncNotifier untuk state management.',
              ),
              pw.SizedBox(height: 12),
              pattBox(
                'DAO Pattern',
                '8 DAO classes masing-masing bertanggung jawab atas 1 tabel. Single Responsibility.',
              ),
              pw.SizedBox(height: 12),
              pattBox(
                'Soft Delete Pattern',
                'deleted_at column di transaksi. Data tidak pernah dihapus permanen.',
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 8: SECURITY ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: cBgF8,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('05  KEAMANAN'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Keamanan Data',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 32),
              secCard(
                '🔐',
                'Biometric Authentication',
                'Sensor biometric device (fingerprint/face) sebagai primary authentication. Fallback ke PIN jika biometric tidak tersedia.',
                [
                  'local_auth package',
                  'Android & iOS native',
                  'Graceful fallback',
                ],
              ),
              pw.SizedBox(height: 16),
              secCard(
                '🔒',
                'AES-256 Encryption',
                'Data sensitif dienkripsi menggunakan AES-256 dengan key yang disimpan secure. Encryption layer di atas SQLite.',
                [
                  'encrypt package',
                  'PointyCastle backend',
                  'Secure key storage',
                ],
              ),
              pw.SizedBox(height: 16),
              secCard(
                '📱',
                'PIN Lock',
                'PIN 6 digit sebagai fallback untuk perangkat tanpa biometric sensor. Rate limiting untuk brute-force protection.',
                ['6-digit PIN', 'Rate limiting', 'No biometric fallback'],
              ),
              pw.SizedBox(height: 32),
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: cPrimaryDark,
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Row(
                  children: [
                    pw.Text('🛡️', style: const pw.TextStyle(fontSize: 32)),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Offline-First Architecture',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Semua data disimpan lokal. Tidak ada data yang dikirim ke server. Privasi完全 terjamin.',
                            style: pw.TextStyle(fontSize: 12, color: cWhite80),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 9: TESTING & CI/CD ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: PdfColors.white,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              hdr('06  TESTING & CI/CD'),
              pw.SizedBox(height: 28),
              pw.Text(
                'Quality Assurance Pipeline',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        ciPhase(
                          '1',
                          'ANALYZE',
                          'flutter analyze',
                          'Static analysis — 0 errors',
                          cEmerald,
                        ),
                        pw.SizedBox(height: 12),
                        ciPhase(
                          '2',
                          'TEST',
                          'flutter test',
                          '171 unit & widget tests',
                          cPurple,
                        ),
                        pw.SizedBox(height: 12),
                        ciPhase(
                          '3',
                          'BUILD',
                          'flutter build',
                          'Signed APK release',
                          cPrimaryMid,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(child: testCard()),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                'GitHub Actions Workflows',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: cTextPrimary,
                ),
              ),
              pw.SizedBox(height: 16),
              wfBox(
                '.github/workflows/analyze.yaml',
                'flutter analyze on every push/PR',
              ),
              pw.SizedBox(height: 8),
              wfBox(
                '.github/workflows/test.yaml',
                'flutter test on every push/PR',
              ),
              pw.SizedBox(height: 8),
              wfBox('.github/workflows/build.yaml', 'APK build on tag push'),
            ],
          ),
        ),
      ),
    ),
  );

  // ==================== PAGE 10: CLOSING ====================
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        width: double.infinity,
        height: double.infinity,
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(colors: [cPrimaryDark, cPrimaryMid]),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 80),
              pw.Text(
                '07  CLOSING',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: cEmeraldLight,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 28),
              pw.Text(
                'DompetKu',
                style: pw.TextStyle(
                  fontSize: 48,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: -2,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Aplikasi yang menyelesaikan masalah nyata.',
                style: pw.TextStyle(fontSize: 18, color: cWhite80),
              ),
              pw.SizedBox(height: 48),
              pw.Container(
                width: 80,
                height: 4,
                decoration: pw.BoxDecoration(
                  color: cEmerald,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(height: 36),
              pw.Text(
                '"Every line of code reflects a decision. Every feature solves a real problem."',
                style: pw.TextStyle(
                  fontSize: 15,
                  color: cWhite60,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Spacer(),
              pw.Row(
                children: [
                  statB2('v1.0.0', 'Version'),
                  pw.SizedBox(width: 48),
                  statB2('April 2026', 'Released'),
                  pw.SizedBox(width: 48),
                  statB2('Flutter 3.11', 'Framework'),
                  pw.SizedBox(width: 48),
                  statB2('Dart 3.11', 'Language'),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                '© 2026 DompetKu. Built with Flutter.',
                style: pw.TextStyle(fontSize: 12, color: cWhite20),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  final file = File('DompetKu_Portfolio_Report.pdf');
  await file.writeAsBytes(await pdf.save());
  print('PDF generated: ${file.path}');
  print('Size: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB');
}
