import 'package:dragonfly_browservault/src/browser_favorites.dart';
import 'package:dragonfly_browservault/src/initializer.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Database db;
  late BrowserFavorites favorites;

  setUp(() {
    db = initializeInMemory();
    favorites = BrowserFavorites(db);
  });

  tearDown(() {
    db.dispose();
  });

  test('createTable should create the favorites table', () {
    final result = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='favorites';",
    );

    expect(result.isNotEmpty, true);
  });

  test('addFavorite should add a new favorite to the database', () {
    final testLink = Uri.parse('https://www.google.com');
    favorites.addFavorite('Google', testLink);

    final allFavorites = favorites.getAllFavorites();

    expect(allFavorites.length, 1);
    expect(allFavorites[0].name, 'Google');
    expect(allFavorites[0].link, testLink);
    expect(allFavorites[0].parentId, null);
  });

  test('addFavorite should throw exception if parent folder does not exist',
      () {
    final testLink = Uri.parse('https://www.google.com');

    expect(
        () => favorites.addFavorite('Google', testLink, parentId: 1),
        throwsA((e) =>
            e is BrowserFavoriteException &&
            e.message == 'Parent folder does not exist.'));
  });

  test(
      'addFavorite should add a favorite to an existing folder if parentId is provided',
      () {
    favorites.createFolder('My Folder');
    final folderId = favorites.getAllFavorites()[0].id!;

    final testLink = Uri.parse('https://www.example.com');
    favorites.addFavorite('Example', testLink, parentId: folderId);

    final allFavorites = favorites.getAllFavorites();
    expect(allFavorites.length, 2);

    final newFavorite = allFavorites.firstWhere((fav) => fav.name == 'Example');
    expect(newFavorite.parentId, folderId);
  });

  test('removeFavorite should remove the specified favorite', () {
    favorites.addFavorite('Google', Uri.parse('https://www.google.com'));

    final favoriteId = favorites.getAllFavorites()[0].id!;
    favorites.removeFavorite(favoriteId);

    expect(favorites.getAllFavorites(), isEmpty);
  });

  test('createFolder should create a new folder', () {
    favorites.createFolder('Test Folder');

    final allFavorites = favorites.getAllFavorites();

    expect(allFavorites.length, 1);
    expect(allFavorites[0].name, 'Test Folder');
    expect(allFavorites[0].link, Uri.parse('')); // Empty URI for folders
  });

  test('createFolder should create a subfolder if parentId is provided', () {
    favorites.createFolder('Main Folder');
    final mainFolderId = favorites.getAllFavorites()[0].id!;
    favorites.createFolder('Subfolder', parentId: mainFolderId);

    final allFavorites = favorites.getAllFavorites();
    expect(allFavorites.length, 2);

    final subfolder = allFavorites.firstWhere((fav) => fav.name == 'Subfolder');
    expect(subfolder.parentId, mainFolderId);
  });

  test('removeFolder should remove the folder and its contents', () {
    favorites.createFolder('Main Folder');

    final mainFolderId = favorites.getAllFavorites()[0].id!;

    favorites.addFavorite(
      'Google',
      Uri.parse('https://www.google.com'),
      parentId: mainFolderId,
    );

    favorites.removeFolder(mainFolderId);

    expect(favorites.getAllFavorites(), isEmpty);
  });

  test('rename should update the name of a favorite or folder', () {
    favorites.addFavorite('Google', Uri.parse('https://www.google.com'));

    final favoriteId = favorites.getAllFavorites()[0].id!;
    favorites.rename(favoriteId, 'New Name');

    final updatedFavorite = favorites.getAllFavorites()[0];

    expect(updatedFavorite.name, 'New Name');
  });
}
