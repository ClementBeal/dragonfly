import 'package:sqlite3/sqlite3.dart';

class FileCacheRepo {
  final Database _db;
  final String _tableName = 'file_cache';

  FileCacheRepo(Database db) : _db = db;

  void createTable() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        filename TEXT PRIMARY KEY,
        mimetype TEXT NON NULL,
        uri TEXT NOT NULL UNIQUE
      )
    ''');
  }

  void addFileToCache(String filename, String uri, String mimetype) {
    _db.execute('''
      INSERT INTO $_tableName (filename, uri, mimetype) 
      VALUES (?, ?, ?)
    ''', [filename, uri, mimetype]);
  }

  /// Returns the filename and the mimetype
  (String, String)? getFileFromCache(String uri) {
    final result = _db.select('''
      SELECT filename, mimetype FROM $_tableName
      WHERE uri = ?
    ''', [uri]);

    if (result.isNotEmpty) {
      return (result.first['filename'], result.first['mimetype']);
    } else {
      return null;
    }
  }

  void removeFileFromCache(String uri) {
    _db.execute('DELETE FROM $_tableName WHERE uri = ?', [uri]);
  }

  void clearFileCache() {
    _db.execute('DELETE FROM $_tableName');
  }
}
