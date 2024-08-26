/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/browser_favorites.dart'
    show Favorite, BrowserFavorites, BrowserFavoriteException;
export 'src/navigation_history.dart'
    show Link, NavigationHistory, NavigationHistoryException;
export 'src/initializer.dart' show initialize, initializeInMemory;
