import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/platform_utils.dart';
import 'image_cache_service.dart';

class FileService {
  static final FileService instance = FileService._init();
  static const String _folderName = 'DompetKu';

  FileService._init();

  Future<Directory> get _appDocDir async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  Future<Directory> getAttachmentFolder() async {
    final appDir = await _appDocDir;
    final attachDir = Directory('${appDir.path}/$_folderName');
    if (!await attachDir.exists()) {
      await attachDir.create(recursive: true);
    }
    return attachDir;
  }

  /// Requests storage permission for writing to public Download folder.
  /// Returns true if permission is granted.
  Future<bool> _requestStoragePermission() async {
    // Desktop platforms don't need Android permissions
    if (!PlatformUtils.isAndroid) return true;

    // Android 11+ (API 30+): needs MANAGE_EXTERNAL_STORAGE
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    // Try requesting manage external storage first (Android 11+)
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    // Fallback: try regular storage permission (Android < 11)
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// Returns the backup folder.
  /// - Android: `/storage/emulated/0/Download/DompetKu` (public, visible in file manager)
  /// - Desktop: `Documents/DompetKu` (user's Documents folder)
  Future<Directory?> getBackupFolder() async {
    if (PlatformUtils.isDesktop) {
      // Desktop: use Documents folder
      final docsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(
        '${docsDir.path}${Platform.pathSeparator}$_folderName',
      );
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      return backupDir;
    }

    // Android: use public Download folder
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      debugPrint('Storage permission denied — cannot access Download folder');
      return null;
    }

    const downloadPath = '/storage/emulated/0/Download';
    final backupDir = Directory('$downloadPath/$_folderName');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<File?> pickImageFromCamera() async {
    // Camera is not available on desktop platforms
    if (PlatformUtils.isDesktop) {
      debugPrint('Camera not available on desktop');
      return null;
    }
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return await _saveToAttachmentFolder(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Gagal mengambil gambar dari kamera: $e');
    }
    return null;
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return await _saveToAttachmentFolder(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Gagal mengambil gambar dari galeri: $e');
    }
    return null;
  }

  Future<File?> pickAnyFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return await _saveToAttachmentFolder(File(path));
        }
      }
    } catch (e) {
      debugPrint('Gagal memilih file: $e');
    }
    return null;
  }

  Future<List<File>> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        List<File> savedFiles = [];
        for (var file in result.files) {
          if (file.path != null) {
            final saved = await _saveToAttachmentFolder(File(file.path!));
            if (saved != null) {
              savedFiles.add(saved);
            }
          }
        }
        return savedFiles;
      }
    } catch (e) {
      debugPrint('Gagal memilih banyak file: $e');
    }
    return [];
  }

  Future<File?> _saveToAttachmentFolder(File sourceFile) async {
    try {
      final attachDir = await getAttachmentFolder();
      final fileName = sourceFile.path.split('/').last.split('\\').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      final newFileName = '${baseName}_$timestamp$ext';
      final newPath = '${attachDir.path}/$newFileName';
      return await sourceFile.copy(newPath);
    } catch (e) {
      debugPrint('Gagal menyimpan file: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        // Remove from image cache to avoid holding stale entries
        ImageCacheService.instance.removeFromCache(path);
        return true;
      }
    } catch (e) {
      debugPrint('Gagal menghapus file: $e');
    }
    return false;
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  String getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  String getFileExtension(String path) {
    final fileName = getFileName(path);
    if (fileName.contains('.')) {
      return fileName.split('.').last.toLowerCase();
    }
    return '';
  }

  bool isImage(String path) {
    final ext = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  bool isPdf(String path) {
    return getFileExtension(path) == 'pdf';
  }
}
