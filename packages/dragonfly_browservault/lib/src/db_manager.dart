import 'dart:io';

import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;

class DatabaseManager {
  // Initialize the database and create necessary tables
  Database initialize(String vaultPath) {
    final path = p.join(vaultPath, "vault.sqlite");
    final db = sqlite3.open(path)..execute("PRAGMA foreign_keys=ON");
    _createTables(db);

    return db;
  }

  Database initializeInMemory() {
    final db = sqlite3.openInMemory()..execute("PRAGMA foreign_keys=ON");
    _createTables(db);

    return db;
  }

  void _createTables(Database db) {
    FileCacheRepo(db).createTable();
  }
}
