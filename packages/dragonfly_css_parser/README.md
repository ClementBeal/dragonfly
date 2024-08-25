## Dragonfly CSS Parser

**A lightweight and robust CSS parser for Dart.**

This library provides a simple and efficient way to parse CSS stylesheets and manipulate their contents programmatically. 


### Installation

Add dragonfly_css_parser to your `pubspec.yaml` file:

```yaml
dependencies:
  dragonfly_css_parser: ^latest_version
```

Then, run `dart pub get` to install the package.

### Usage

```dart
import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';

void main() {
  var stylesheet = CssParser.parse('''
    h1 {
      color: blue;
      font-size: 24px;
    }
    
    p {
      color: gray;
    }
  ''');

  // Access rules
  for (var rule in stylesheet.rules) {
    print('Selector: ${rule.selector}');
    for (var declaration in rule.declarations) {
      print('  $declaration');
    }
  }
}
```

### Contributing

Contributions are welcome! Please open an issue or submit a pull request on the GitHub repository.

