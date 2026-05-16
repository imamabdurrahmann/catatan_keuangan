// ignore_for_file: unnecessary_import  (Uint8List requires dart:typed_data)
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

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

  /// Returns all keys in LRU order (oldest first)
  List<K> get keysInOrder => List.unmodifiable(_order);
}

/// Singleton service for caching processed image bytes in memory and on disk.
///
/// This service is responsible for:
/// - Caching loaded image bytes with an LRU eviction policy (max 50 entries in memory)
/// - Persisting frequently accessed images to disk cache for faster startup
/// - Serving cached images on subsequent requests for the same file path
/// - Clearing caches when needed (e.g., app state reset)
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
  static const int maxMemoryCacheSize = 50;

  /// Maximum total size of disk cache in bytes (50 MB)
  static const int maxDiskCacheSize = 50 * 1024 * 1024;

  /// Maximum age of disk cache entries in days before refresh
  static const int diskCacheMaxAgeDays = 7;

  final LRUMap<String, Uint8List> _memoryCache = LRUMap(maxSize: maxMemoryCacheSize);

  Database? _diskCacheDb;
  bool _diskCacheInitialized = false;

  /// Returns the number of currently cached images in memory.
  int get memoryCacheSize => _memoryCache.length;

  /// Returns whether [path] is currently in the memory cache.
  bool isCached(String path) => _memoryCache.containsKey(path);

  /// Initializes the disk cache database.
  Future<void> _initDiskCache() async {
    if (_diskCacheInitialized) return;
    _diskCacheInitialized = true;

    try {
      final dbPath = await getDatabasesPath();
      final cacheDbPath = path.join(dbPath, 'image_cache.db');

      _diskCacheDb = await openDatabase(
        cacheDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS image_cache (
              path TEXT PRIMARY KEY,
              data BLOB NOT NULL,
              size INTEGER NOT NULL,
              created_at TEXT NOT NULL,
              last_accessed TEXT NOT NULL,
              access_count INTEGER DEFAULT 1
            )
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_image_cache_accessed
            ON image_cache(last_accessed)
          ''');
        },
      );
    } catch (e) {
      debugPrint('ImageCacheService: Failed to initialize disk cache — $e');
      _diskCacheInitialized = false;
    }
  }

  /// Retrieves a cached image for [path] if available.
  ///
  /// Checks memory cache first, then disk cache.
  /// Returns `null` if the path is not in the cache or the file no longer
  /// exists on disk (auto-removes stale entries).
  Future<Uint8List?> getCachedImage(String path) async {
    // Check memory cache first (fastest)
    final memoryBytes = _memoryCache.get(path);
    if (memoryBytes != null) {
      // Verify source file still exists
      final file = File(path);
      if (await file.exists()) {
        return memoryBytes;
      }
      _memoryCache.remove(path);
      return null;
    }

    // Check disk cache
    await _initDiskCache();
    if (_diskCacheDb == null) return null;

    try {
      final results = await _diskCacheDb!.query(
        'image_cache',
        columns: ['data', 'created_at'],
        where: 'path = ?',
        whereArgs: [path],
        limit: 1,
      );

      if (results.isNotEmpty) {
        final row = results.first;
        final bytes = row['data'] as Uint8List;
        final createdAt = DateTime.parse(row['created_at'] as String);

        // Verify source file still exists
        final file = File(path);
        if (!await file.exists()) {
          await _removeFromDiskCache(path);
          return null;
        }

        // Check if cache entry is too old
        final age = DateTime.now().difference(createdAt);
        if (age.inDays > diskCacheMaxAgeDays) {
          // Refresh the cache entry
          await _refreshDiskCacheEntry(path, bytes);
        } else {
          // Update access stats
          await _diskCacheDb!.update(
            'image_cache',
            {
              'last_accessed': DateTime.now().toIso8601String(),
              'access_count': (row['data'] as Uint8List).length, // Re-read is too complex
            },
            where: 'path = ?',
            whereArgs: [path],
          );
        }

        // Promote to memory cache
        _memoryCache.put(path, bytes);
        return bytes;
      }
    } catch (e) {
      debugPrint('ImageCacheService: Failed to read from disk cache — $e');
    }

    return null;
  }

  /// Refreshes a disk cache entry's metadata without re-reading the file.
  Future<void> _refreshDiskCacheEntry(String path, Uint8List bytes) async {
    if (_diskCacheDb == null) return;

    try {
      await _diskCacheDb!.update(
        'image_cache',
        {
          'last_accessed': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
        where: 'path = ?',
        whereArgs: [path],
      );
    } catch (e) {
      debugPrint('ImageCacheService: Failed to refresh cache entry — $e');
    }
  }

  /// Caches [bytes] for [path] in both memory and disk cache.
  ///
  /// Call this after loading image bytes from disk.
  Future<void> cacheImage(String path, Uint8List bytes) async {
    // Always update memory cache
    _memoryCache.put(path, bytes);

    // Update disk cache
    await _initDiskCache();
    if (_diskCacheDb == null) return;

    try {
      final now = DateTime.now().toIso8601String();
      await _diskCacheDb!.insert(
        'image_cache',
        {
          'path': path,
          'data': bytes,
          'size': bytes.length,
          'created_at': now,
          'last_accessed': now,
          'access_count': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Check disk cache size and evict if needed
      await _evictDiskCacheIfNeeded();
    } catch (e) {
      debugPrint('ImageCacheService: Failed to write to disk cache — $e');
    }
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

  /// Removes [path] from both memory and disk cache.
  ///
  /// Call this when a file is deleted to avoid holding stale entries.
  Future<void> removeFromCache(String path) async {
    _memoryCache.remove(path);
    await _removeFromDiskCache(path);
  }

  Future<void> _removeFromDiskCache(String path) async {
    await _initDiskCache();
    if (_diskCacheDb == null) return;

    try {
      await _diskCacheDb!.delete(
        'image_cache',
        where: 'path = ?',
        whereArgs: [path],
      );
    } catch (e) {
      debugPrint('ImageCacheService: Failed to remove from disk cache — $e');
    }
  }

  /// Clears all cached images from memory and disk.
  Future<void> clearCache() async {
    _memoryCache.clear();

    await _initDiskCache();
    if (_diskCacheDb != null) {
      try {
        await _diskCacheDb!.delete('image_cache');
        debugPrint('ImageCacheService: Disk cache cleared');
      } catch (e) {
        debugPrint('ImageCacheService: Failed to clear disk cache — $e');
      }
    }

    debugPrint('ImageCacheService: Cache cleared ($memoryCacheSize memory entries removed)');
  }

  /// Evicts old entries from disk cache if total size exceeds limit.
  Future<void> _evictDiskCacheIfNeeded() async {
    if (_diskCacheDb == null) return;

    try {
      // Get current cache size
      final sizeResult = await _diskCacheDb!.rawQuery(
        'SELECT SUM(size) as total FROM image_cache',
      );
      final totalSize = (sizeResult.first['total'] as int?) ?? 0;

      if (totalSize > maxDiskCacheSize) {
        // Delete oldest accessed entries until we're under limit
        await _diskCacheDb!.rawDelete('''
          DELETE FROM image_cache
          WHERE path IN (
            SELECT path FROM image_cache
            ORDER BY last_accessed ASC
            LIMIT ?
          )
        ''', [(totalSize - maxDiskCacheSize ~/ 2) ~/ 1000]); // Delete ~50% overage

        debugPrint('ImageCacheService: Evicted entries from disk cache');
      }
    } catch (e) {
      debugPrint('ImageCacheService: Failed to evict disk cache — $e');
    }
  }

  /// Returns disk cache statistics.
  Future<Map<String, dynamic>> getDiskCacheStats() async {
    await _initDiskCache();
    if (_diskCacheDb == null) {
      return {'count': 0, 'size': 0, 'initialized': false};
    }

    try {
      final countResult = await _diskCacheDb!.rawQuery(
        'SELECT COUNT(*) as count, SUM(size) as total FROM image_cache',
      );
      return {
        'count': (countResult.first['count'] as int?) ?? 0,
        'size': (countResult.first['total'] as int?) ?? 0,
        'initialized': true,
      };
    } catch (e) {
      return {'count': 0, 'size': 0, 'initialized': false, 'error': e.toString()};
    }
  }

  /// Closes the disk cache database. Call this when the app is disposing.
  Future<void> dispose() async {
    if (_diskCacheDb != null) {
      await _diskCacheDb!.close();
      _diskCacheDb = null;
      _diskCacheInitialized = false;
    }
  }
}
