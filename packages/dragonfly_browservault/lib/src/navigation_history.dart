import 'package:sqlite3/sqlite3.dart';

class NavigationHistoryException implements Exception {
  final String message;

  NavigationHistoryException(this.message);
}

class Link {
  final int? id;
  final String title;
  final Uri link;
  final DateTime timestamp;

  Link(
      {this.id,
      required this.title,
      required this.link,
      required this.timestamp});

  factory Link.fromMap(Map<String, dynamic> map) {
    return Link(
      id: map["id"],
      title: map["title"],
      link: Uri.parse(map['link'] as String), // Parse string back to Uri
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'link': link.toString(),
      'title': title,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class NavigationHistory {
  final Database _db;
  final String _tableName = 'history';

  NavigationHistory(this._db) {
    createTable();
  }

  void createTable() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        link TEXT NOT NULL,
        title TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  void addLink(Uri link, String title) {
    var newLink = Link(link: link, timestamp: DateTime.now(), title: title);

    try {
      _db.execute(
          "INSERT INTO $_tableName (link, timestamp, title) VALUES (?,?,?)", [
        newLink.link.toString(),
        newLink.timestamp.millisecondsSinceEpoch,
        newLink.title,
      ]);
    } catch (e) {
      throw NavigationHistoryException('Error adding link: $e');
    }
  }

  void removeLink(Link linkToRemove) {
    _db.execute("DELETE FROM $_tableName WHERE id = ${linkToRemove.id}");
  }

  List<Link> getAllLinks() {
    var results =
        _db.select('SELECT * FROM $_tableName ORDER BY timestamp DESC');
    return results.map((row) => Link.fromMap(row)).toList();
  }

  void clearHistory() {
    _db.execute("DELETE FROM $_tableName");
  }

  void fakeData(Uri link, String title, DateTime timestamp) {
    var newLink = Link(link: link, timestamp: timestamp, title: title);

    try {
      _db.execute(
          "INSERT INTO $_tableName (link, timestamp, title) VALUES (?,?,?)", [
        newLink.link.toString(),
        newLink.timestamp.millisecondsSinceEpoch,
        newLink.title,
      ]);
    } catch (e) {
      throw NavigationHistoryException('Error adding link: $e');
    }
  }
}
