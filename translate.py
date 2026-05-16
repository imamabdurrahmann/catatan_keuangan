import os, re

replacements = {
    'PIN input': 'Input PIN',
    'Direstore': 'dipulihkan',
    'direstore': 'dipulihkan',
    'Merestore data': 'Memulihkan data',
    'merestore': 'memulihkan',
    'Restore Backup': 'Pulihkan Cadangan',
    'Restore Data': 'Pulihkan Data',
    'Restore dari File': 'Pulihkan dari File',
    'Restore': 'Pulihkan',
    'Gagal restore': 'Gagal memulihkan',
    'Export Baru': 'Ekspor Baru',
    'Export Berhasil': 'Ekspor Berhasil',
    'Export Data': 'Ekspor Data',
    'Export': 'Ekspor',
    'Gagal export': 'Gagal mengekspor',
    'Generating PDF...': 'Sedang membuat PDF...',
    'Gagal generate PDF': 'Gagal membuat PDF',
    'Lengkapi semua field': 'Lengkapi semua kolom',
    'Kategori default': 'Kategori bawaan',
    'Trophy Room Anda': 'Ruang Trofi Anda',
    'Scan Struk (A.I)': 'Pindai Struk (A.I)',
    'Error picking file': 'Gagal memilih file',
    'Error picking image from camera': 'Gagal mengambil gambar dari kamera',
    'Error picking image from gallery': 'Gagal mengambil gambar dari galeri',
    'Error picking multiple files': 'Gagal memilih banyak file',
    'Error saving file': 'Gagal menyimpan file',
    'Error deleting file': 'Gagal menghapus file',
    'Decryption failed': 'Dekripsi gagal',
    'Belum ada backup': 'Belum ada cadangan data',
    'Hapus Backup': 'Hapus Cadangan',
    'Backup tersimpan di': 'Cadangan tersimpan di',
    'Lindungi backup dengan password': 'Lindungi cadangan dengan kata sandi',
    'Masukkan password untuk membuka file backup': 'Masukkan kata sandi untuk membuka file cadangan',
    'file backup': 'file cadangan',
    'Password salah atau file rusak': 'Kata sandi salah atau file rusak',
    'Password tidak cocok': 'Kata sandi tidak cocok',
    'Password tidak boleh kosong': 'Kata sandi tidak boleh kosong',
    'Ulangi password': 'Ulangi kata sandi',
    'Gunakan password': 'Gunakan kata sandi',
    'Masukkan password': 'Masukkan kata sandi',
    'Konfirmasi Password': 'Konfirmasi Kata Sandi',
    'Password': 'Kata Sandi',
    'Nominal Budget': 'Nominal Anggaran',
    'Set Budget': 'Atur Anggaran',
    'Edit budget ': 'Edit anggaran ',
    'budget terpakai': 'anggaran terpakai',
    'Melebihi budget ': 'Melebihi anggaran ',
    'Budget:': 'Anggaran:',
    'Budget ': 'Anggaran ',
    ', password: ': ', kata sandi: ',
}

for root, dirs, files in os.walk('lib'):
    # Don't touch models to prevent breaking DB column names or logical string representations if they are exact
    if 'models' in root:
        continue
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            new_content = content
            for k, v in replacements.items():
                # Be a bit careful. `Restore` might replace `Restore Backup` part, so `replacements` dict order matters in python 3.7+ (ordered by insertion). 
                # Let's ensure larger phrases are done first. They are!
                
                # We need to make sure we don't accidentally replace programmatic english like 'budget' in variables.
                # However, the string replacements have uppercase versions generally for UI strings (e.g. Budget).
                # The word "budget" in `budget terpakai` is caught. 
                # Also, I should use regex to replace within strings only ideally. But a simple replace on exact UI strings works.
                new_content = new_content.replace(k, v)
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(new_content)
                print(f"Updated {f}")

print("done")
