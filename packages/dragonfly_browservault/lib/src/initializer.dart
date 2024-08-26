import 'package:sqlite3/sqlite3.dart';

Database initialize(String vaultPath) {
  return sqlite3.open(vaultPath)..execute("PRAGMA foregn_keys=ON");
}

Database initializeInMemory() {
  return sqlite3.openInMemory()..execute("PRAGMA foregn_keys=ON");
}
