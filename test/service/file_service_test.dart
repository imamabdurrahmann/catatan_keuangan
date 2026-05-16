import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/services/file_service.dart';

void main() {
  group('FileService', () {
    test('instance returns same object', () {
      final a = FileService.instance;
      final b = FileService.instance;
      expect(a, same(b));
    });

    test('getFileName extracts filename from path', () {
      expect(FileService.instance.getFileName('/path/to/file.pdf'), 'file.pdf');
      expect(
        FileService.instance.getFileName('/path\\to\\file.pdf'),
        'file.pdf',
      );
    });

    test('getFileExtension returns correct extension', () {
      expect(
        FileService.instance.getFileExtension('/path/to/image.jpg'),
        'jpg',
      );
      expect(
        FileService.instance.getFileExtension('/path/to/document.pdf'),
        'pdf',
      );
      expect(FileService.instance.getFileExtension('/path/to/file.PNG'), 'png');
    });

    test('getFileExtension returns empty for file without extension', () {
      expect(FileService.instance.getFileExtension('/path/to/file'), '');
    });

    test('isImage returns true for image extensions', () {
      expect(FileService.instance.isImage('/path/to/photo.jpg'), true);
      expect(FileService.instance.isImage('/path/to/photo.jpeg'), true);
      expect(FileService.instance.isImage('/path/to/photo.png'), true);
      expect(FileService.instance.isImage('/path/to/photo.gif'), true);
      expect(FileService.instance.isImage('/path/to/photo.bmp'), true);
      expect(FileService.instance.isImage('/path/to/photo.webp'), true);
    });

    test('isImage returns false for non-image extensions', () {
      expect(FileService.instance.isImage('/path/to/document.pdf'), false);
      expect(FileService.instance.isImage('/path/to/file.txt'), false);
      expect(FileService.instance.isImage('/path/to/data.xlsx'), false);
    });

    test('isPdf returns true for pdf extension', () {
      expect(FileService.instance.isPdf('/path/to/document.pdf'), true);
      expect(FileService.instance.isPdf('/path/to/document.PDF'), true);
    });

    test('isPdf returns false for non-pdf files', () {
      expect(FileService.instance.isPdf('/path/to/document.docx'), false);
      expect(FileService.instance.isPdf('/path/to/image.jpg'), false);
    });
  });
}
