import 'package:dragonfly_browservault/dragonfly_browservault.dart';

// TO DO : refactor that
// I really don't know how to make it better
// I need a way to store the DB into a special folder
// (here ./cache/)

final db = DatabaseManager().initialize("cache");
