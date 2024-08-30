import 'package:dragonfly_browservault/dragonfly_browservault.dart'; // Adjust import to your actual package path
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Database db;
  late FileCacheRepo repo;

  setUp(() {
    db = DatabaseManager().initializeInMemory();
    repo = FileCacheRepo(db);
  });

  tearDown(() {
    db.dispose();
  });

  group('FileCacheRepo Tests', () {
    test('Should create table correctly', () {
      // Test table creation (already done in setup)
      final result = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='file_cache';",
      );
      expect(result, isNotEmpty, reason: 'Table file_cache should exist.');
    });

    test('Should add file to cache', () {
      repo.addFileToCache('testfile1', 'http://example.com/file1', "");
      final result = db.select('SELECT * FROM file_cache WHERE uri = ?',
          ['http://example.com/file1']);
      expect(result, hasLength(1));
      expect(result.first['filename'], 'testfile1');
    });

    test('Should retrieve file from cache', () {
      repo.addFileToCache('testfile2', 'http://example.com/file2', "");
      final filename = repo.getFileFromCache('http://example.com/file2');
      expect(filename, equals('testfile2'));
    });

    test('Should return null when file is not found in cache', () {
      final filename = repo.getFileFromCache('http://example.com/nonexistent');
      expect(filename, isNull);
    });

    test('Should remove file from cache', () {
      repo.addFileToCache('testfile3', 'http://example.com/file3', "");
      repo.removeFileFromCache('http://example.com/file3');
      final filename = repo.getFileFromCache('http://example.com/file3');
      expect(filename, isNull);
    });

    test('Should clear file cache', () {
      repo.addFileToCache('testfile4', 'http://example.com/file4', "");
      repo.addFileToCache('testfile5', 'http://example.com/file5', "");
      repo.clearFileCache();
      final result = db.select('SELECT * FROM file_cache');
      expect(result, isEmpty, reason: 'Cache should be empty after clearing.');
    });
  });
}
