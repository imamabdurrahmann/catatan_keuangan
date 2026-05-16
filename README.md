# 💰 DompetKu - Personal Finance Tracker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Aplikasi pencatatan keuangan personal dengan Flutter**

[Features](#-features) • [Screenshots](#-screenshots) • [Getting Started](#-getting-started) • [Tech Stack](#-tech-stack) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 📊 Dashboard
- Ringkasan saldo real-time
- Grafik pengeluaran mingguan
- Balance overview dengan animasi

### 💸 Transaksi
- Tambah/edit transaksi income & expense
- Dukungan multi-dompet
- Lampiran gambar
- Filter dan pencarian

### 📈 Laporan
- Statistik keuangan
- Export ke Excel
- Breakdown per kategori

### 🛡️ Data & Keamanan
- Backup & restore lokal
- Export/import data
- Soft delete dengan recovery

### 🎨 UI/UX
- Dark/Light mode
- Shimmer loading effects
- Empty states yang informatif
- Smooth animations

---

## 📱 Screenshots

<div align="center">
<table>
  <tr>
    <td><img src="screenshots/dashboard.png" width="250" alt="Dashboard"/></td>
    <td><img src="screenshots/transaksi.png" width="250" alt="Transactions"/></td>
    <td><img src="screenshots/laporan.png" width="250" alt="Reports"/></td>
  </tr>
</table>
</div>

---

## 🚀 Getting Started

### Prerequisites

```bash
flutter --version  # Flutter 3.x or higher
dart --version    # Dart 3.x or higher
```

### Installation

```bash
# Clone repository
git clone https://github.com/imamabdurrahmann/catatan_keuangan.git
cd catatan_keuangan

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **State Management** | Provider |
| **Local Database** | SQLite (sqflite) |
| **Architecture** | Clean Architecture |
| **Testing** | Flutter Test, Golden Tests |

### Dependencies

- `provider` - State management
- `sqflite` - Local database
- `path_provider` - File system access
- `share_plus` - Share functionality
- `excel` - Excel export
- `intl` - Internationalization & formatting
- `shimmer` - Loading effects
- `flutter_local_notifications` - Notifications

---

## 📁 Project Structure

```
lib/
├── main.dart
├── data/
│   ├── daos/           # Data Access Objects
│   ├── database/       # Database configuration
│   └── models/         # Data models
├── pages/              # UI screens
│   ├── actions/
│   ├── core/
│   ├── reports_stats/
│   ├── settings_security/
│   └── tabs/
├── providers/          # State providers
├── services/           # Business logic
├── theme/              # App theming
└── widgets/            # Reusable widgets
    └── common/
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

Feel free to check [issues page](../../issues).

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Muhammad Imam Abdurrahman**

- GitHub: [@imamabdurrahmann](https://github.com/imamabdurrahmann)
- Email: muhammadimamabdurrahman93@gmail.com

---

<div align="center">
⭐ Star this repo if you find it helpful!
</div>