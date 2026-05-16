// ignore_for_file: unnecessary_import  (Uint8List requires dart:typed_data)
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Simple LRU (Least Recently Used) cache for in-memory image caching.
///
/// Keeps up to [maxSize] entries, evicting the least recently used
/// entry when the limit is exceeded.
class LRUMap<K, V> {
  final int maxSize;
  final Map<K, V> _map = {};
  final List<K> _order = [];

  LRUMap({required this.maxSize});

  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    // Move to end (most recently used)
    _order.remove(key);
    _order.add(key);
    return _map[key];
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _order.remove(key);
    } else if (_order.length >= maxSize) {
      // Evict least recently used
      final lruKey = _order.removeAt(0);
      _map.remove(lruKey);
    }
    _map[key] = value;
    _order.add(key);
  }

  bool containsKey(K key) => _map.containsKey(key);

  void remove(K key) {
    _map.remove(key);
    _order.remove(key);
  }

  void clear() {
    _map.clear();
    _order.clear();
  }

  int get length => _map.length;
}

/// Singleton service for caching processed image bytes in memory.
///
/// This service is responsible for:
/// - Caching loaded image bytes with an LRU eviction policy (max 50 entries)
/// - Serving cached images on subsequent requests for the same file path
/// - Clearing the cache when needed (e.g., app state reset)
/// - Removing entries when their source file is deleted
///
/// Note: This is distinct from Flutter's [ImageCache] which caches decoded
/// images on the GPU side. This service caches raw bytes to avoid re-reading
/// and re-decoding files from disk repeatedly.
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._();
  static ImageCacheService get instance => _instance;

  ImageCacheService._();

  /// Maximum number of image entries to keep in memory.
  /// Set to 50 to balance memory usage with caching effectiveness.
  static const int maxCacheSize = 50;

  final LRUMap<String, Uint8List> _cache = LRUMap(maxSize: maxCacheSize);

  /// Returns the number of currently cached images.
  int get cacheSize => _cache.length;

  /// Returns whether [path] is currently in the cache.
  bool isCached(String path) => _cache.containsKey(path);

  /// Retrieves a cached image for [path] if available.
  ///
  /// Returns `null` if the path is not in the cache or the file no longer
  /// exists on disk (auto-removes stale entries).
  Future<Uint8List?> getCachedImage(String path) async {
    final bytes = _cache.get(path);
    if (bytes == null) return null;

    // Verify file still exists; if not, remove from cache
    final file = File(path);
    if (!await file.exists()) {
      _cache.remove(path);
      return null;
    }

    return bytes;
  }

  /// Caches [bytes] for [path].
  ///
  /// Call this after loading image bytes from disk.
  Future<void> cacheImage(String path, Uint8List bytes) async {
    _cache.put(path, bytes);
  }

  /// Loads image bytes for [path], serving from cache if available.
  ///
  /// If [maxDimension] is provided, will only return cached bytes if they
  /// match the requested dimension (useful for thumbnails vs full images).
  Future<Uint8List?> loadImage(String path, {int? maxDimension}) async {
    // Check cache first
    final cached = await getCachedImage(path);
    if (cached != null) {
      return cached;
    }

    // Load from disk
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final bytes = await file.readAsBytes();
      await cacheImage(path, bytes);
      return bytes;
    } catch (e) {
      debugPrint('ImageCacheService: Failed to load $path — $e');
      return null;
    }
  }

  /// Removes [path] from the cache.
  ///
  /// Call this when a file is deleted to avoid holding stale entries.
  void removeFromCache(String path) {
    _cache.remove(path);
  }

  /// Clears all cached images from memory.
  void clearCache() {
    _cache.clear();
    debugPrint('ImageCacheService: Cache cleared ($cacheSize entries removed)');
  }
}
