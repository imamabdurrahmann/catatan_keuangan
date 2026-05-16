import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/image_cache_service.dart';

/// A reusable widget for displaying attachment images with:
/// - Placeholder while loading
/// - Cached image loading from disk
/// - Graceful error fallback
/// - Thumbnail mode for smaller sizes in list views
///
/// Supports two display modes:
/// - [mode] = `AttachmentDisplayMode.full`: Full-sized display (e.g., detail view)
/// - [mode] = `AttachmentDisplayMode.thumbnail`: Smaller display with [cacheWidth]/[cacheHeight]
class AttachmentImage extends StatefulWidget {
  /// Path to the image file.
  final String path;

  /// How to display the image.
  final AttachmentDisplayMode mode;

  /// Optional fixed width (overrides [mode] default).
  final double? width;

  /// Optional fixed height (overrides [mode] default).
  final double? height;

  /// How to fit the image within the bounds.
  final BoxFit fit;

  /// Border radius applied to the image clip.
  final double borderRadius;

  /// Optional error builder for custom error display.
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AttachmentImage({
    super.key,
    required this.path,
    this.mode = AttachmentDisplayMode.full,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.errorBuilder,
  });

  /// Shortcut constructor for thumbnail-sized attachments (list views, cards).
  /// Uses [size] as both width and height.
  const AttachmentImage.thumbnail({
    super.key,
    required this.path,
    double size = 56,
    this.mode = AttachmentDisplayMode.thumbnail,
    this.fit = BoxFit.cover,
    this.borderRadius = 10,
    this.errorBuilder,
  }) : width = size,
       height = size;

  @override
  State<AttachmentImage> createState() => _AttachmentImageState();
}

class _AttachmentImageState extends State<AttachmentImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AttachmentImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _loading = true;
      _error = false;
      _bytes = null;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await ImageCacheService.instance.loadImage(widget.path);
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _loading = false;
        _error = bytes == null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  double? get _cacheWidth {
    if (widget.width != null) return widget.width! * 2; // Retina
    return widget.mode == AttachmentDisplayMode.thumbnail ? 112 : null;
  }

  double? get _cacheHeight {
    if (widget.height != null) return widget.height! * 2; // Retina
    return widget.mode == AttachmentDisplayMode.thumbnail ? 112 : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return _buildPlaceholder(isDark);
    }

    if (_error || _bytes == null) {
      return _buildError(isDark);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: _cacheWidth?.toInt(),
        cacheHeight: _cacheHeight?.toInt(),
        errorBuilder: widget.errorBuilder,
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Icon(
        Icons.broken_image_rounded,
        color: Colors.grey.shade400,
        size: widget.mode == AttachmentDisplayMode.thumbnail ? 20 : 32,
      ),
    );
  }
}

enum AttachmentDisplayMode {
  /// Full-sized display, typically used in detail views.
  full,

  /// Thumbnail-sized display with reduced resolution for list views.
  thumbnail,
}
