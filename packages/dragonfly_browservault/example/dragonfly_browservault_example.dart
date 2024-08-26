import 'package:dragonfly_browservault/src/browser_favorites.dart';
import 'package:dragonfly_browservault/src/initializer.dart';
import 'package:dragonfly_browservault/src/navigation_history.dart';

void main() {
  final db = initializeInMemory();

  final favorites = BrowserFavorites(db);
  final history = NavigationHistory(db);

  favorites.createFolder("Search Engines");
  final searchEnginesFolderId = favorites.getAllFavorites()[0].id!;

  favorites.addFavorite(
    "Google",
    Uri.parse("https://google.com"),
    parentId: searchEnginesFolderId,
  );
  favorites.addFavorite(
    "DuckDuckGo",
    Uri.parse("https://duckduckgo.com/"),
    parentId: searchEnginesFolderId,
  );

  history.addLink(
      Uri.parse("https://www.google.com/search?q=dart"), "google.com");
  history.addLink(
      Uri.parse("https://www.google.com/search?q=flutter"), "google.com");

  history.clearHistory();
}
