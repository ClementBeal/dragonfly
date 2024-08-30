import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Database db;
  late NavigationHistory history;

  setUp(() {
    // Initialize in-memory database for testing
    db = DatabaseManager().initializeInMemory();
    history = NavigationHistory(db);
  });

  tearDown(() {
    db.dispose();
  });

  test('createTable should create the history table', () {
    var result = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='history';");
    expect(result.isNotEmpty, true);
  });

  test('addLink should add a new link to the database', () {
    var testLink = Uri.parse('https://www.example.com');
    history.addLink(testLink, "example.com");

    var links = history.getAllLinks();
    expect(links.length, 1);
    expect(links[0].link, testLink);
  });

  test('removeLink should remove the specified link from the database', () {
    var testLink1 = Uri.parse('https://www.google.com');
    var testLink2 = Uri.parse('https://www.example.com');
    history.addLink(testLink1, "google.com");
    history.addLink(testLink2, "example.com");

    var linkToRemove = history.getAllLinks()[0]; // Get the first added link
    history.removeLink(linkToRemove);

    var links = history.getAllLinks();
    expect(links.length, 1);
    expect(links[0].link, testLink2); // The first link should be removed
  });

  test('getAllLinks should return all links in descending order of timestamp',
      () async {
    var testLink1 = Uri.parse('https://www.google.com');
    var testLink2 = Uri.parse('https://www.example.com');

    history.addLink(testLink1, "google.com");

    await Future.delayed(Duration(milliseconds: 10));
    history.addLink(testLink2, 'example.com');

    var links = history.getAllLinks();

    expect(links.length, 2);
    expect(links[0].link, testLink2); // Most recent link first
    expect(links[1].link, testLink1);
  });

  test('clearHistory should remove all links from the database', () {
    history.addLink(Uri.parse('https://www.google.com'), "google.com");
    history.addLink(Uri.parse('https://www.example.com'), "example.com");

    history.clearHistory();
    expect(history.getAllLinks(), isEmpty);
  });
}
