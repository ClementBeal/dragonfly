import 'package:sqlite3/sqlite3.dart';

class BrowserFavoriteException implements Exception {
  final String message;

  BrowserFavoriteException(this.message);
}

class Favorite {
  final int? id;
  final String name;
  final Uri? link;
  final bool isFolder;
  final int? parentId;

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      link: (map['link'] != null) ? Uri.parse(map['link']) : null,
      name: map['name'],
      parentId: map['parentId'],
      isFolder: map['isFolder'] == 1,
    );
  }

  Favorite({
    this.id,
    required this.name,
    this.link,
    this.parentId,
    this.isFolder = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'link': link.toString(),
      'name': name,
      'parentId': parentId,
      'isFolder': isFolder,
    };
  }
}

class BrowserFavorites {
  final Database _db;
  final String _tableName = 'favorites';

  BrowserFavorites(this._db) {
    _createTable();
  }

  void _createTable() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        link TEXT,
        isFolder INTEGER DEFAULT FALSE,
        parentId INTEGER,
        FOREIGN KEY (parentId) REFERENCES $_tableName(id) ON DELETE CASCADE
      )
    ''');
  }

  void addFavorite(String name, Uri link, {int? parentId}) {
    // 1. Check if parent folder exists (if parentId is provided)
    if (parentId != null) {
      final parentExistsResult = _db.select('''
        SELECT EXISTS(SELECT 1 FROM $_tableName WHERE id = ?)
      ''', [parentId]);

      if (parentExistsResult.first.values.first == 0) {
        throw BrowserFavoriteException('Parent folder does not exist.');
      }
    }

    // 2. Insert the new favorite
    _db.execute('''
      INSERT INTO $_tableName (name, link, parentId) 
      VALUES (?, ?, ?)
    ''', [name, link.toString(), parentId]);
  }

  void removeFavorite(int id) {
    _db.execute('DELETE FROM $_tableName WHERE id = ?', [id]);
  }

  void createFolder(String name, {int? parentId}) {
    // (Logic for checking parent folder existence is the same as in addFavorite)

    _db.execute('''
      INSERT INTO $_tableName (name, link, parentId, isFolder) 
      VALUES (?, '', ?, true) 
    ''', [name, parentId]); // Link is empty string for folders
  }

  void removeFolder(int id) {
    // Recursive deletion is handled by the ON DELETE CASCADE constraint
    _db.execute('DELETE FROM $_tableName WHERE id = ?', [id]);
    _db.execute('DELETE FROM $_tableName WHERE parentId = ?', [id]);
  }

  void rename(int id, String newName) {
    _db.execute('UPDATE $_tableName SET name = ? WHERE id = ?', [newName, id]);
  }

  // Helper function (example - you can add more retrieval methods)
  List<Favorite> getAllFavorites() {
    final results = _db.select('SELECT * FROM $_tableName');
    return results.map((row) => Favorite.fromMap(row)).toList();
  }
}
