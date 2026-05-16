import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/constants.dart';
import '../../models/models.dart';
import '../../services/file_service.dart';
import '../../theme/theme.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/attachment_image.dart';

class PremiumDatePicker extends StatelessWidget {
  final DateTime tanggal;
  final ValueChanged<DateTime> onChanged;
  final bool isDark;
  final String jenis;

  const PremiumDatePicker({
    super.key,
    required this.tanggal,
    required this.onChanged,
    required this.isDark,
    required this.jenis,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = jenis == AppConstants.jenisPemasukan
        ? AppColors.emerald
        : AppColors.coral;

    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: tanggal,
          firstDate: DateTime(AppConstants.minYear),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: AppColors.emerald,
                        surface: AppColors.darkSurface,
                      )
                    : const ColorScheme.light(
                        primary: AppColors.primaryMid,
                        surface: Colors.white,
                      ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          if (!context.mounted) return;
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(tanggal),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: isDark
                      ? const ColorScheme.dark(
                          primary: AppColors.emerald,
                          surface: AppColors.darkSurface,
                        )
                      : const ColorScheme.light(
                          primary: AppColors.primaryMid,
                          surface: Colors.white,
                        ),
                ),
                child: child!,
              );
            },
          );
          onChanged(
            DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime?.hour ?? tanggal.hour,
              pickedTime?.minute ?? tanggal.minute,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withValues(alpha: 0.5)
              : AppColors.lightBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 20, color: accentColor),
            const SizedBox(width: 12),
            Text(
              DateFormat(
                AppConstants.dateFormatDisplay,
                AppConstants.localeId,
              ).format(tanggal),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit_rounded,
              size: 18,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class KategoriSelector extends StatelessWidget {
  final List<Kategori> kategoriList;
  final String? selectedKategori;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const KategoriSelector({
    super.key,
    required this.kategoriList,
    required this.selectedKategori,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kategoriList.map((k) {
        final isSelected = selectedKategori == k.nama;
        final catColor = isDark ? AppColors.emerald : AppColors.primaryMid;
        return GestureDetector(
          onTap: () => onChanged(k.nama),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? catColor.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkCard : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? catColor
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? catColor
                        : Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    getAppIcon(k.icon),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  k.nama,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? catColor
                        : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AttachmentList extends StatelessWidget {
  final List<File> attachments;
  final ValueChanged<int> onRemove;
  final bool isDark;

  const AttachmentList({
    super.key,
    required this.attachments,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          final file = attachments[index];
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AppColors.darkCard : Colors.grey.shade200,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: FileService.instance.isImage(file.path)
                    ? AttachmentImage(
                        path: file.path,
                        mode: AttachmentDisplayMode.full,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        borderRadius: 12,
                      )
                    : Icon(
                        Icons.insert_drive_file_rounded,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RecurringToggle extends StatelessWidget {
  final bool isRecurring;
  final String recurringFrequency;
  final ValueChanged<bool> onRecurringChanged;
  final ValueChanged<String> onFrequencyChanged;
  final bool isDark;

  const RecurringToggle({
    super.key,
    required this.isRecurring,
    required this.recurringFrequency,
    required this.onRecurringChanged,
    required this.onFrequencyChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.5)
                : AppColors.lightBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.repeat_rounded,
                size: 20,
                color: isRecurring
                    ? AppColors.teal
                    : (isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaksi Berulang',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    if (isRecurring)
                      Text(
                        AppConstants.frequencyLabel(recurringFrequency),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: AppColors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: isRecurring,
                onChanged: onRecurringChanged,
                activeTrackColor: AppColors.teal,
              ),
            ],
          ),
        ),
        if (isRecurring) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.recurringFrequencies.map((f) {
              final isSelected = recurringFrequency == f;
              return GestureDetector(
                onTap: () => onFrequencyChanged(f),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.teal.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.teal
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                  ),
                  child: Text(
                    AppConstants.frequencyLabel(f),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.teal
                          : (isDark ? Colors.white54 : Colors.grey),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
