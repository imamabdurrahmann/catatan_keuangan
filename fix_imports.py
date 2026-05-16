import os

# Fix import paths in moved page files
fixes = [
    # From actions/ to models/ (now 2 levels up)
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../models/constants.dart'", "'../../models/constants.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'shared_widgets.dart'", "'../../widgets/shared_widgets.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../widgets/common/glass_button.dart'", "'../../widgets/common/glass_button.dart'"),
    ("lib/pages/actions/edit_transaksi_sheet.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../models/constants.dart'", "'../../models/constants.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../services/file_service.dart'", "'../../services/file_service.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../services/ocr_service.dart'", "'../../services/ocr_service.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'shared_widgets.dart'", "'../../widgets/shared_widgets.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/actions/tambah_transaksi_sheet.dart", "'../widgets/common/glass_button.dart'", "'../../widgets/common/glass_button.dart'"),
    ("lib/pages/actions/trash_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/actions/trash_sheet.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/actions/trash_sheet.dart", "'shared_widgets.dart'", "'../../widgets/shared_widgets.dart'"),
    ("lib/pages/actions/transaksi_search_delegate.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/actions/transaksi_search_delegate.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/actions/transaksi_search_delegate.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/actions/recurring_transaksi_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/actions/recurring_transaksi_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/actions/recurring_transaksi_sheet.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    # wallets_categories
    ("lib/pages/wallets_categories/kelola_dompet_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/wallets_categories/kelola_dompet_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/wallets_categories/kelola_dompet_sheet.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/wallets_categories/kelola_dompet_sheet.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    ("lib/pages/wallets_categories/kelola_kategori_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/wallets_categories/kelola_kategori_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/wallets_categories/kelola_kategori_sheet.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/wallets_categories/kelola_kategori_sheet.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    # budget_savings
    ("lib/pages/budget_savings/budget_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/budget_savings/budget_sheet.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/budget_savings/budget_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/budget_savings/budget_sheet.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/budget_savings/budget_sheet.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'../models/constants.dart'", "'../../models/constants.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/budget_savings/tabungan_impian_page.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    # debts
    ("lib/pages/debts/utang_piutang_page.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/debts/utang_piutang_page.dart", "'../models/constants.dart'", "'../../models/constants.dart'"),
    ("lib/pages/debts/utang_piutang_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/debts/utang_piutang_page.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/debts/utang_piutang_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/debts/utang_piutang_page.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/debts/utang_piutang_page.dart", "'ui_utils.dart'", "'../../utils/ui_utils.dart'"),
    # reports_stats
    ("lib/pages/reports_stats/laporan_sheet.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/reports_stats/laporan_sheet.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/reports_stats/laporan_sheet.dart", "'../services/pdf_laporan_service.dart'", "'../../services/pdf_laporan_service.dart'"),
    ("lib/pages/reports_stats/statistik_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/reports_stats/statistik_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/reports_stats/statistik_page.dart", "'../widgets/common/glass_container.dart'", "'../../widgets/common/glass_container.dart'"),
    ("lib/pages/reports_stats/statistik_page.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    # settings_security
    ("lib/pages/settings_security/backup_page.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/settings_security/backup_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/settings_security/backup_page.dart", "'../services/crypto_service.dart'", "'../../services/crypto_service.dart'"),
    ("lib/pages/settings_security/backup_page.dart", "'../services/file_service.dart'", "'../../services/file_service.dart'"),
    ("lib/pages/settings_security/backup_restore_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/settings_security/backup_restore_page.dart", "'../services/backup_service.dart'", "'../../services/backup_service.dart'"),
    ("lib/pages/settings_security/backup_restore_page.dart", "'../services/export_service.dart'", "'../../services/export_service.dart'"),
    ("lib/pages/settings_security/backup_restore_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/settings_security/backup_restore_page.dart", "'../widgets/common/glass_container.dart'", "'../../widgets/common/glass_container.dart'"),
    ("lib/pages/settings_security/pin_lock_screen.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/settings_security/pin_lock_screen.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/settings_security/pin_lock_screen.dart", "'../services/biometric_service.dart'", "'../../services/biometric_service.dart'"),
    ("lib/pages/settings_security/settings_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/settings_security/settings_page.dart", "'../services/biometric_service.dart'", "'../../services/biometric_service.dart'"),
    ("lib/pages/settings_security/settings_page.dart", "'../services/notification_service.dart'", "'../../services/notification_service.dart'"),
    ("lib/pages/settings_security/settings_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/settings_security/settings_page.dart", "'../widgets/common/glass_container.dart'", "'../../widgets/common/glass_container.dart'"),
    # core
    ("lib/pages/core/app.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/core/app.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/core/app.dart", "'../router.dart'", "'../../router.dart'"),
    ("lib/pages/core/app.dart", "'../services/home_widget_service.dart'", "'../../services/home_widget_service.dart'"),
    ("lib/pages/core/app.dart", "'../services/notification_service.dart'", "'../../services/notification_service.dart'"),
    ("lib/pages/core/app.dart", "'../services/recurring_scheduler.dart'", "'../../services/recurring_scheduler.dart'"),
    ("lib/pages/core/app.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/core/app.dart", "'../widgets/common/glass_container.dart'", "'../../widgets/common/glass_container.dart'"),
    ("lib/pages/core/app.dart", "'../widgets/common/glass_button.dart'", "'../../widgets/common/glass_button.dart'"),
    ("lib/pages/core/app.dart", "'../widgets/common/animated_currency_text.dart'", "'../../widgets/common/animated_currency_text.dart'"),
    ("lib/pages/core/app.dart", "'../utils/formatters.dart'", "'../../utils/formatters.dart'"),
    ("lib/pages/core/app.dart", "'pin_lock_screen.dart'", "'../settings_security/pin_lock_screen.dart'"),
    ("lib/pages/core/home_page.dart", "'../models/models.dart'", "'../../models/models.dart'"),
    ("lib/pages/core/home_page.dart", "'../providers.dart'", "'../../providers.dart'"),
    ("lib/pages/core/home_page.dart", "'../services/recurring_scheduler.dart'", "'../../services/recurring_scheduler.dart'"),
    ("lib/pages/core/home_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    ("lib/pages/core/home_page.dart", "'../widgets/glass_menu_bottom_sheet.dart'", "'../../widgets/glass_menu_bottom_sheet.dart'"),
    ("lib/pages/core/home_page.dart", "'tambah_transaksi_sheet.dart'", "'../actions/tambah_transaksi_sheet.dart'"),
    ("lib/pages/core/home_page.dart", "'transaksi_search_delegate.dart'", "'../actions/transaksi_search_delegate.dart'"),
    ("lib/pages/core/home_page.dart", "'widgets/transaksi_item_card.dart'", "'../../widgets/transaksi_item_card.dart'"),
    ("lib/pages/core/home_page.dart", "'widgets/tab_hari_ini.dart'", "'../../widgets/tab_hari_ini.dart'"),
    ("lib/pages/core/home_page.dart", "'tabs/tab_bulanan.dart'", "'../tabs/tab_bulanan.dart'"),
    ("lib/pages/core/home_page.dart", "'tabs/tab_dashboard.dart'", "'../tabs/tab_dashboard.dart'"),
    ("lib/pages/core/home_page.dart", "'tabs/tab_lainnya.dart'", "'../tabs/tab_lainnya.dart'"),
    ("lib/pages/core/home_page.dart", "'tabs/tab_per_tanggal.dart'", "'../tabs/tab_per_tanggal.dart'"),
    # gamification
    ("lib/pages/gamification/achievement_page.dart", "'../data/database_helper.dart'", "'../../data/database_helper.dart'"),
    ("lib/pages/gamification/achievement_page.dart", "'../theme/theme.dart'", "'../../theme/theme.dart'"),
    # tabs
    ("lib/pages/tabs/tab_lainnya.dart", "'../kelola_dompet_sheet.dart'", "'../wallets_categories/kelola_dompet_sheet.dart'"),
    ("lib/pages/tabs/tab_lainnya.dart", "'../kelola_kategori_sheet.dart'", "'../wallets_categories/kelola_kategori_sheet.dart'"),
    ("lib/pages/tabs/tab_lainnya.dart", "'../budget_sheet.dart'", "'../budget_savings/budget_sheet.dart'"),
    ("lib/pages/tabs/tab_lainnya.dart", "'../recurring_transaksi_sheet.dart'", "'../actions/recurring_transaksi_sheet.dart'"),
    ("lib/pages/tabs/tab_lainnya.dart", "'../trash_sheet.dart'", "'../actions/trash_sheet.dart'"),
    ("lib/pages/tabs/tab_lainnya.dart", "'../backup_page.dart'", "'../settings_security/backup_page.dart'"),
    ("lib/pages/tabs/tab_lainnya.dart", "'../laporan_sheet.dart'", "'../reports_stats/laporan_sheet.dart'"),
    ("lib/pages/tabs/tab_per_tanggal.dart", "'../widgets/staggered_list_item.dart'", "'../../widgets/staggered_list_item.dart'"),
    ("lib/pages/tabs/tab_bulanan.dart", "'../widgets/transaksi_item_card.dart'", "'../../widgets/transaksi_item_card.dart'"),
    ("lib/pages/tabs/tab_per_tanggal.dart", "'../widgets/transaksi_item_card.dart'", "'../../widgets/transaksi_item_card.dart'"),
    # widgets
    ("lib/widgets/glass_menu_bottom_sheet.dart", "'../pages/kelola_dompet_sheet.dart'", "'../pages/wallets_categories/kelola_dompet_sheet.dart'"),
    ("lib/widgets/glass_menu_bottom_sheet.dart", "'../pages/kelola_kategori_sheet.dart'", "'../pages/wallets_categories/kelola_kategori_sheet.dart'"),
    ("lib/widgets/glass_menu_bottom_sheet.dart", "'../pages/budget_sheet.dart'", "'../pages/budget_savings/budget_sheet.dart'"),
    ("lib/widgets/glass_menu_bottom_sheet.dart", "'../pages/recurring_transaksi_sheet.dart'", "'../pages/actions/recurring_transaksi_sheet.dart'"),
    ("lib/widgets/glass_menu_bottom_sheet.dart", "'../pages/trash_sheet.dart'", "'../pages/actions/trash_sheet.dart'"),
    ("lib/widgets/glass_menu_bottom_sheet.dart", "'../pages/backup_page.dart'", "'../pages/settings_security/backup_page.dart'"),
    # main.dart and router.dart
    ("lib/main.dart", "'pages/app.dart'", "'pages/core/app.dart'"),
    ("lib/router.dart", "'pages/home_page.dart'", "'pages/core/home_page.dart'"),
    ("lib/router.dart", "'pages/settings_page.dart'", "'pages/settings_security/settings_page.dart'"),
    ("lib/router.dart", "'pages/statistik_page.dart'", "'pages/reports_stats/statistik_page.dart'"),
    ("lib/router.dart", "'pages/utang_piutang_page.dart'", "'pages/debts/utang_piutang_page.dart'"),
    ("lib/router.dart", "'pages/tabungan_impian_page.dart'", "'pages/budget_savings/tabungan_impian_page.dart'"),
    ("lib/router.dart", "'pages/achievement_page.dart'", "'pages/gamification/achievement_page.dart'"),
    ("lib/router.dart", "'pages/backup_restore_page.dart'", "'pages/settings_security/backup_restore_page.dart'"),
    # test file
    ("test/widget/transaksi_card_test.dart", "'package:catatan_keuangan/pages/widgets/transaksi_item_card.dart'", "'package:catatan_keuangan/widgets/transaksi_item_card.dart'"),
]

fixed = 0
notfound = 0
for filepath, old, new in fixes:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        if old in content:
            content = content.replace(old, new)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Fixed: {filepath}')
            fixed += 1
        else:
            print(f'NOT FOUND in {filepath}: {old}')
            notfound += 1
    else:
        print(f'MISSING FILE: {filepath}')
        notfound += 1

print(f'DONE - Fixed: {fixed}, Not found/missing: {notfound}')
