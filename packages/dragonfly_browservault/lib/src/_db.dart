import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:sqlite3/sqlite3.dart';

// TO DO : refactor that
// I really don't know how to make it better
// I need a way to store the DB into a special folder
// (here ./cache/)

late Database db;

void initializeDb(String path) {
  db = DatabaseManager().initialize(path);
}
