import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PortfolioPdfService {
  static final PortfolioPdfService _instance = PortfolioPdfService._();
  static PortfolioPdfService get instance => _instance;
  PortfolioPdfService._();

  // Brand colors — PdfColor does not support opacity, so we flatten alpha into hex.
  // Alpha 0xCC ≈ 80%, 0x99 ≈ 60%, 0x80 ≈ 50%, 0x66 ≈ 40%, 0x4D ≈ 30%, 0x26 ≈ 15%, 0xB3 ≈ 70%
  static final _primaryDark = PdfColor.fromInt(0xFF0D2818);
  static final _primaryMid = PdfColor.fromInt(0xFF1B5E20);
  static final _emerald = PdfColor.fromInt(0xFF10B981);
  static final _emeraldLight = PdfColor.fromInt(0xFF34D399);
  static final _darkBg = PdfColor.fromInt(0xFF0A0E14);
  static final _darkBorder = PdfColor.fromInt(0xFF2A3040);
  static final _textPrimary = PdfColor.fromInt(0xFF1A1A2E);
  static final _textSecondary = PdfColor.fromInt(0xFF6B7280);
  static final _textMuted = PdfColor.fromInt(0xFF9CA3AF);

  // Opacity variants — white
  static final _white15 = PdfColor.fromInt(0x26FFFFFF); // 15% opacity white
  static final _white70 = PdfColor.fromInt(0xB3FFFFFF); // 70% opacity white
  static final _white80 = PdfColor.fromInt(0xCCFFFFFF); // 80% opacity white
  static final _white60 = PdfColor.fromInt(0x99FFFFFF); // 60% opacity white
  static final _white50 = PdfColor.fromInt(0x80FFFFFF); // 50% opacity white
  static final _white40 = PdfColor.fromInt(0x66FFFFFF); // 40% opacity white

  Future<File> generatePortfolioReport() async {
    final pdf = pw.Document();

    // ============ COVER PAGE ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildCoverPage(),
      ),
    );

    // ============ TABLE OF CONTENTS ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildTableOfContents(),
      ),
    );

    // ============ OVERVIEW ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildOverviewPage(),
      ),
    );

    // ============ FEATURES ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildFeaturesPage1(),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildFeaturesPage2(),
      ),
    );

    // ============ TECH STACK ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildTechStackPage(),
      ),
    );

    // ============ ARCHITECTURE ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildArchitecturePage(),
      ),
    );

    // ============ SECURITY ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildSecurityPage(),
      ),
    );

    // ============ TESTING & CI/CD ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildTestingPage(),
      ),
    );

    // ============ CLOSING ============
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildClosingPage(),
      ),
    );

    // Save to file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/DompetKu_Portfolio_Report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ============ COVER PAGE ============
  pw.Widget _buildCoverPage() {
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_primaryDark, _primaryMid],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 80),
            // Logo placeholder
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: _white15,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Icon(
                pw.IconData(0xe3b6), // account_balance_wallet
                size: 48,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 32),
            pw.Text(
              'DompetKu',
              style: pw.TextStyle(
                fontSize: 56,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: -2,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Aplikasi Pencatatan Keuangan Personal',
              style: pw.TextStyle(fontSize: 20, color: _white80),
            ),
            pw.SizedBox(height: 48),
            // Divider
            pw.Container(
              width: 80,
              height: 4,
              decoration: pw.BoxDecoration(
                color: _emerald,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Technical Portfolio Document',
              style: pw.TextStyle(fontSize: 14, color: _white60),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'v1.0.0  •  April 2026',
              style: pw.TextStyle(fontSize: 12, color: _white50),
            ),
            pw.Spacer(),
            // Stats row
            pw.Row(
              children: [
                _coverStat('10+', 'Features'),
                pw.SizedBox(width: 40),
                _coverStat('171', 'Tests Pass'),
                pw.SizedBox(width: 40),
                _coverStat('3', 'Languages'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _coverStat(String value, String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.Text(label, style: pw.TextStyle(fontSize: 12, color: _white60)),
      ],
    );
  }

  // ============ TABLE OF CONTENTS ============
  pw.Widget _buildTableOfContents() {
    final sections = [
      ('01', 'Overview', 'Tentang DompetKu dan visi misi'),
      ('02', 'Fitur Utama', '10+ fitur yang membedakan'),
      ('03', 'Tech Stack', 'Stack teknologi yang digunakan'),
      ('04', 'Arsitektur', 'Clean architecture & design pattern'),
      ('05', 'Keamanan', 'Encryption & biometric auth'),
      ('06', 'Testing & CI/CD', 'Quality assurance pipeline'),
      ('07', 'Closing', 'Ringkasan & next steps'),
    ];

    return pw.Container(
      color: PdfColor.fromInt(0xFFF8FAFC),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('TABLE OF CONTENTS', _primaryMid),
            pw.SizedBox(height: 40),
            pw.Text(
              'Daftar Isi',
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            pw.Divider(color: _darkBorder, thickness: 1),
            pw.SizedBox(height: 24),
            ...sections.map((s) => _tocEntry(s.$1, s.$2, s.$3)),
          ],
        ),
      ),
    );
  }

  pw.Widget _tocEntry(String num, String title, String subtitle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: _primaryMid,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              num,
              style: pw.TextStyle(
                fontSize: 14,
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
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          pw.Text('→', style: pw.TextStyle(fontSize: 20, color: _emerald)),
        ],
      ),
    );
  }

  // ============ OVERVIEW ============
  pw.Widget _buildOverviewPage() {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('01  OVERVIEW', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Tentang DompetKu',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'DompetKu adalah aplikasi pencatatan keuangan personal yang '
              'dibangun untuk memudahkan pengelolaan keuangan sehari-hari. '
              'Aplikasi ini dirancang untuk menjadi solusi nyata yang dipakai '
              'oleh developer sendiri setiap hari — bukan aplikasi tutorial, '
              'bukan template, tapi hasil pemecahan masalah nyata.',
              style: pw.TextStyle(
                fontSize: 13,
                color: _textSecondary,
                lineSpacing: 8,
              ),
            ),
            pw.SizedBox(height: 32),
            _visionBox(),
            pw.SizedBox(height: 32),
            _statsGrid(),
            pw.SizedBox(height: 40),
            _highlightBox(
              'Mengapa DompetKu berbeda?',
              'Kebanyakan aplikasi keuangan hanya jadi tracker. DompetKu '
                  'menjadi partner keuangan: otomatis mengingatkan budget, '
                  'scheduling transaksi berulang, scan kwitansi, dan masih banyak lagi.',
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _visionBox() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: _primaryMid,
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
              color: _emeraldLight,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Membantu setiap orang mengelola keuangan personal '
            'dengan mudah, terstruktur, dan tanpa hambatan.',
            style: pw.TextStyle(
              fontSize: 15,
              color: PdfColors.white,
              lineSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _statsGrid() {
    final items = [
      ('171', 'Unit & Widget Tests', '✅', _emerald),
      ('10+', 'Fitur Utama', '🚀', _primaryMid),
      ('3', 'Platform Support', '📱', PdfColor.fromInt(0xFF8B5CF6)),
      ('100%', 'Passing Rate', '🎯', PdfColor.fromInt(0xFFFBBF24)),
      ('9', 'Database Tables', '🗄️', PdfColor.fromInt(0xFFF87171)),
      ('CI/CD', 'Automated Pipeline', '⚙️', _textSecondary),
    ];

    return pw.Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map((item) {
        return pw.Container(
          width: 160,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF8FAFC),
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(
              color: _darkBorder.flatten(
                background: PdfColor.fromInt(0xFFFFFFFF),
              ),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                item.$1,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: item.$4,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                item.$2,
                style: pw.TextStyle(fontSize: 11, color: _textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _highlightBox(String title, String body) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0FDF4),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: _emerald.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _primaryMid,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            body,
            style: pw.TextStyle(
              fontSize: 11,
              color: _textSecondary,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ============ FEATURES PAGE 1 ============
  pw.Widget _buildFeaturesPage1() {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('02  FITUR UTAMA', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Fitur Unggulan',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            _featureCard(
              '💰',
              'Pencatatan Transaksi',
              'Catat pemasukan dan pengeluaran dengan kategorisasi lengkap. '
                  'Multi-wallet dengan dukungan multi-currency (IDR, USD, EUR, SGD). '
                  'Filter berdasarkan tanggal, kategori, dan dompet.',
              ['Soft delete', 'Lampiran gambar', 'Pencarian cepat'],
            ),
            pw.SizedBox(height: 20),
            _featureCard(
              '📊',
              'Budget Bulanan',
              'Atur anggaran per kategori untuk setiap bulan. Progress bar real-time '
                  'yang otomatis update setiap transaksi baru. Warning notifikasi '
                  'saat budget hampir tercapai.',
              ['Visual progress', 'Warning 80%+', 'Per kategori'],
            ),
            pw.SizedBox(height: 20),
            _featureCard(
              '🎯',
              'Tabungan Impian',
              'Buat target tabungan dengan nominal dan tanggal target. '
                  'Tracking progress otomatis. Milestone notification '
                  'saat progress mencapai 50%, 75%, dan 100%.',
              ['Target-based', 'Progress tracking', 'Milestone notif'],
            ),
          ],
        ),
      ),
    );
  }

  // ============ FEATURES PAGE 2 ============
  pw.Widget _buildFeaturesPage2() {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('02  FITUR UTAMA', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Fitur Unggulan (Lanjutan)',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            _featureCard(
              '🔄',
              'Recurring Transaction',
              'Transaksi berulang yang otomatis dibuat berdasarkan jadwal: '
                  'daily, weekly, monthly, quarterly, atau yearly. '
                  'Sistem hanya memproses sekali per hari untuk efisiensi.',
              ['5 frequency types', 'Auto-create', 'Daily check'],
            ),
            pw.SizedBox(height: 20),
            _featureCard(
              '📄',
              'OCR Receipt Scanner',
              'Scan kwitansi dengan Google ML Kit Text Recognition. '
                  'Otomatis ekstrak jumlah dan detail dari kwitansi. '
                  'Hanya perlu foto, data langsung terisi.',
              ['Auto-extract', 'ML Kit OCR', 'Text recognition'],
            ),
            pw.SizedBox(height: 20),
            _featureCard(
              '📤',
              'Export & Backup',
              'Backup data dalam format JSON yang bisa direstore kapan saja. '
                  'Export transaksi ke CSV untuk analisis di Excel. '
                  'Generate PDF report dengan branding DompetKu.',
              ['JSON backup', 'CSV export', 'PDF report'],
            ),
            pw.SizedBox(height: 20),
            _featureCard(
              '🔐',
              'Keamanan',
              'Biometric authentication (fingerprint/face) untuk keamanan. '
                  'PIN fallback untuk perangkat tanpa sensor biometric. '
                  'AES-256 encryption untuk data sensitif.',
              ['Biometric', 'PIN lock', 'AES-256'],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _featureCard(
    String emoji,
    String title,
    String desc,
    List<String> tags,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(
          color: _darkBorder.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 48,
                height: 48,
                decoration: pw.BoxDecoration(
                  color: _primaryMid,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(emoji, style: const pw.TextStyle(fontSize: 20)),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
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
              color: _textSecondary,
              lineSpacing: 5,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _emerald.flatten(
                    background: PdfColor.fromInt(0xFFFFFFFF),
                  ),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  tag,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _primaryMid,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============ TECH STACK ============
  pw.Widget _buildTechStackPage() {
    return pw.Container(
      color: PdfColor.fromInt(0xFFF8FAFC),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('03  TECH STACK', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Tech Stack',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            _techCategory('📱  MOBILE', [
              'Flutter 3.11',
              'Dart 3.11',
              'Material Design 3',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('⚡  STATE MANAGEMENT', [
              'Riverpod 3.x',
              'Notifier pattern',
              'AsyncNotifier',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🧭  NAVIGATION', [
              'GoRouter 14.x',
              'Deep linking',
              'Declarative routing',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🗄️  DATABASE', [
              'SQLite via sqflite',
              'DAO Pattern',
              '9 tabel + migration',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🔒  SECURITY', [
              'AES-256 encryption',
              'Biometric (local_auth)',
              'PIN fallback',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🔔  NOTIFICATIONS', [
              'flutter_local_notifications',
              '4 channel (Budget/Debt/Savings/Achievement)',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('📄  DOCUMENT', [
              'PDF generation',
              'CSV export',
              'JSON backup',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🔬  ML/AI', [
              'Google ML Kit Text Recognition',
              'Receipt OCR',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🧪  TESTING', [
              'flutter_test',
              'mocktail',
              'sqflite_common_ffi',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('⚙️  CI/CD', [
              'GitHub Actions',
              '3 workflows',
              'Auto build & test',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('🎨  UI/UX', [
              'fl_chart (charts)',
              'lottie (animations)',
              'PlusJakartaSans font',
            ]),
            pw.SizedBox(height: 16),
            _techCategory('📦  OTHERS', [
              'home_widget',
              'table_calendar',
              'share_plus',
              'permission_handler',
            ]),
          ],
        ),
      ),
    );
  }

  pw.Widget _techCategory(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: _darkBorder.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _primaryMid,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _primaryMid,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    item,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============ ARCHITECTURE ============
  pw.Widget _buildArchitecturePage() {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('04  ARSITEKTUR', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Clean Architecture',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            _archLayer('Presentation', 'UI Layer', [
              'Pages',
              'Tabs',
              'Widgets',
              'Theme',
            ]),
            pw.SizedBox(height: 8),
            _archArrow(),
            pw.SizedBox(height: 8),
            _archLayer('Logic', 'Business Logic', [
              'Providers',
              'State Management',
              'Update Signals',
            ]),
            pw.SizedBox(height: 8),
            _archArrow(),
            pw.SizedBox(height: 8),
            _archLayer('Data', 'Data Access', [
              'DAOs (8 files)',
              'Database',
              'Migrations',
            ]),
            pw.SizedBox(height: 8),
            _archArrow(),
            pw.SizedBox(height: 8),
            _archLayer('Services', 'Business Services', [
              'BackupService',
              'ExportService',
              'NotificationService',
              'RecurringScheduler',
            ]),
            pw.SizedBox(height: 32),
            pw.Text(
              'Package Structure',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 16),
            _codeBlock('''
lib/
├── config/         → AppConfig
├── data/           → DAOs, database, migrations
│   └── daos/       → 7 DAO files (transaksi, dompet, ...)
├── l10n/           → i18n (ID + EN)
├── models/         → Domain models
├── pages/          → All screens
│   ├── tabs/
│   │   ├── dashboard/     → 8 dashboard widgets
│   │   └── tab_*.dart     → Tab files
│   └── widgets/    → Reusable components
├── providers/      → Riverpod state providers
├── services/      → Business logic services
├── theme/          → Colors, typography, decorations
├── utils/          → Formatters, helpers
└── widgets/        → Common widgets
'''),
            pw.SizedBox(height: 24),
            _patternBox(
              'Provider Pattern',
              'Riverpod dengan Notifier/AsyncNotifier untuk state management. Update signals untuk cross-provider communication.',
            ),
            pw.SizedBox(height: 16),
            _patternBox(
              'DAO Pattern',
              '8 DAO classes yang masing-masing bertanggung jawab atas 1 tabel. Single Responsibility.',
            ),
            pw.SizedBox(height: 16),
            _patternBox(
              'Soft Delete Pattern',
              'deleted_at column di transaksi untuk soft delete. Data tidak pernah benar-benar dihapus.',
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _archLayer(String name, String subtitle, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_primaryDark, _primaryMid]),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 120,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  name,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 9, color: _white70),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white.flatten(
                      background: PdfColor.fromInt(0xFFFFFFFF),
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.white),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _archArrow() {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(left: 48),
        child: pw.Text(
          '↓',
          style: const pw.TextStyle(
            fontSize: 16,
            color: PdfColor.fromInt(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  pw.Widget _codeBlock(String code) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _darkBg,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        code,
        style: pw.TextStyle(
          fontSize: 8,
          color: _emeraldLight,
          font: pw.Font.courier(),
        ),
      ),
    );
  }

  pw.Widget _patternBox(String title, String body) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0FDF4),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: _emerald.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _primaryMid,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            body,
            style: pw.TextStyle(fontSize: 10, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // ============ SECURITY ============
  pw.Widget _buildSecurityPage() {
    return pw.Container(
      color: PdfColor.fromInt(0xFFF8FAFC),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('05  KEAMANAN', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Keamanan Data',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            _securityCard(
              '🔐',
              'Biometric Authentication',
              'Sensor biometric device (fingerprint / face recognition) sebagai primary authentication. Fallback ke PIN jika biometric tidak tersedia.',
              [
                'local_auth package',
                'Android & iOS native',
                'Graceful fallback',
              ],
            ),
            pw.SizedBox(height: 16),
            _securityCard(
              '🔒',
              'AES-256 Encryption',
              'Data sensitif dienkripsi menggunakan AES-256 dengan key yang disimpan secure. Encryption layer di atas SQLite.',
              ['encrypt package', 'PointyCastle backend', 'Secure key storage'],
            ),
            pw.SizedBox(height: 16),
            _securityCard(
              '📱',
              'PIN Lock',
              'PIN 6 digit sebagai fallback mechanism untuk perangkat tanpa biometric sensor. Rate limiting untuk brute-force protection.',
              ['6-digit PIN', 'Rate limiting', 'No biometric fallback'],
            ),
            pw.SizedBox(height: 32),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: _primaryDark,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                children: [
                  pw.Text('🛡️', style: const pw.TextStyle(fontSize: 28)),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Offline-First Architecture',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Semua data disimpan lokal. Tidak ada data yang dikirim ke server manapun. Privasi完全 terjamin.',
                          style: pw.TextStyle(fontSize: 11, color: _white80),
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
    );
  }

  pw.Widget _securityCard(
    String emoji,
    String title,
    String desc,
    List<String> tags,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: _darkBorder.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(emoji, style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            desc,
            style: pw.TextStyle(fontSize: 11, color: _textSecondary),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFFF7ED),
                  borderRadius: pw.BorderRadius.circular(20),
                  border: pw.Border.all(
                    color: PdfColor.fromInt(
                      0xFFFBBF24,
                    ).flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
                  ),
                ),
                child: pw.Text(
                  tag,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromInt(0xFFD97706),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============ TESTING & CI/CD ============
  pw.Widget _buildTestingPage() {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionHeader('06  TESTING & CI/CD', _primaryMid),
            pw.SizedBox(height: 24),
            pw.Text(
              'Quality Assurance Pipeline',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 32),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      _ciPhase(
                        '1',
                        'ANALYZE',
                        'flutter analyze',
                        'Static analysis untuk memastikan 0 errors sebelum build.',
                        _emerald,
                      ),
                      pw.SizedBox(height: 12),
                      _ciPhase(
                        '2',
                        'TEST',
                        'flutter test',
                        '171 unit & widget tests. Semua harus pass sebelum merge.',
                        PdfColor.fromInt(0xFF8B5CF6),
                      ),
                      pw.SizedBox(height: 12),
                      _ciPhase(
                        '3',
                        'BUILD',
                        'flutter build',
                        'APK release dengan minifikasi R8. Signed dengan keystore release.',
                        _primaryMid,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 32),
                pw.Expanded(child: _testCoverageCard()),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Text(
              'GitHub Actions Workflows',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 16),
            _workflowBox('analyze.yaml', 'flutter analyze on every push/PR'),
            pw.SizedBox(height: 8),
            _workflowBox('test.yaml', 'flutter test on every push/PR'),
            pw.SizedBox(height: 8),
            _workflowBox('build.yaml', 'APK build on tag push'),
          ],
        ),
      ),
    );
  }

  pw.Widget _ciPhase(
    String num,
    String title,
    String command,
    String desc,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: color),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 36,
            height: 36,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              num,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
                pw.Text(
                  command,
                  style: pw.TextStyle(fontSize: 10, color: _textMuted),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  desc,
                  style: pw.TextStyle(fontSize: 9, color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _testCoverageCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(
          color: _darkBorder.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '📊  Test Coverage',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 16),
          _testRow('Model Tests', '35 tests', _primaryMid),
          pw.SizedBox(height: 8),
          _testRow('DAO Tests', '42 tests', _emerald),
          pw.SizedBox(height: 8),
          _testRow('Service Tests', '12 tests', PdfColor.fromInt(0xFF8B5CF6)),
          pw.SizedBox(height: 8),
          _testRow('Widget Tests', '82 tests', PdfColor.fromInt(0xFFFBBF24)),
          pw.SizedBox(height: 16),
          pw.Divider(color: _darkBorder),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _emerald,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  '171 PASS ✓',
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
  }

  pw.Widget _testRow(String name, String count, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(name, style: pw.TextStyle(fontSize: 11, color: _textSecondary)),
        pw.Text(
          count,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _workflowBox(String filename, String desc) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: _darkBorder.flatten(background: PdfColor.fromInt(0xFFFFFFFF)),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Text('📄', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(width: 8),
          pw.Text(
            filename,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.normal,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text('→', style: pw.TextStyle(color: _emerald)),
          pw.SizedBox(width: 8),
          pw.Text(
            desc,
            style: pw.TextStyle(fontSize: 10, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // ============ CLOSING ============
  pw.Widget _buildClosingPage() {
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_primaryDark, _primaryMid],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(48),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 60),
            pw.Text(
              '07  CLOSING',
              style: pw.TextStyle(
                fontSize: 12,
                color: _emeraldLight,
                letterSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'DompetKu',
              style: pw.TextStyle(
                fontSize: 40,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: -1,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Aplikasi yang menyelesaikan masalah nyata.',
              style: pw.TextStyle(fontSize: 16, color: _white80),
            ),
            pw.SizedBox(height: 40),
            pw.Container(
              width: 80,
              height: 4,
              decoration: pw.BoxDecoration(
                color: _emerald,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(height: 32),
            pw.Text(
              '"Every line of code reflects a decision. Every feature solves a real problem."',
              style: pw.TextStyle(
                fontSize: 14,
                color: _white60,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.Spacer(),
            pw.Row(
              children: [
                _closingStat('v1.0.0', 'Version'),
                pw.SizedBox(width: 40),
                _closingStat('April 2026', 'Released'),
                pw.SizedBox(width: 40),
                _closingStat('Flutter 3.11', 'Framework'),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Text(
              '© 2026 DompetKu. Built with ❤️',
              style: pw.TextStyle(fontSize: 11, color: _white40),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _closingStat(String value, String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.white.flatten(
              background: PdfColor.fromInt(0xFFFFFFFF),
            ),
          ),
        ),
      ],
    );
  }

  // ============ HELPERS ============
  pw.Widget _sectionHeader(String text, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 4,
          height: 20,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
