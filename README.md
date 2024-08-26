# Dragonfly

An attempt to build a web browser with Flutter.

# How to test it

```bash
git clone https://github.com/ClementBeal/dragonfly.git
dart pub global activate melos
melos boostrap
cd apps/dragonfly_browser
flutter run
```

If you want to test with some pages that work more or less, run the following command in another bash

```
melos run browser_website
```
# Project strucure

`apps/dragonfly_browser` : the browser project. The UI is there

The following packages are used by the UI :

`apps/dragonfly_browservault` : contains all the side-features of the browser that needs access to a local database (history, favorites...)

`apps/dragonfly_navigation` : more or less a headless browser that can be controlled with code.

`apps/dragonfly_css_parser` : a CSS parser that create a `Stylesheet` object used by the navigator

## Some explainations

The browser model is like more or less like this:

```dart
class Browser {
    List<Tab> tabs;
}

class Tab {
    final List<Page> history;
}

class Page {
    final DOM dom;
    final CssOM cssOM;
}
```

When the user navigate to a page, the browser launch a request. When he receives the HTML, it will parse it and build the DOM. Then he extracts the CSS stylesheet and fetches them. He also parse the CSS to build the CSSOM.

Once we have the DOM and the CSSOM, we can render the page. Almost all the nodes have a similar behavior.

## What's working now?

The browser can open tabs and navigate through them and through the history. It can render a bit of HTML and CSS. It's hard to implement all the properties because there's hundreds now.

I haven't implemented a JS interpreter yet. 

## Wanna contribute?

Create issues or make some PRs! You're all welcome!