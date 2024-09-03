import 'dart:io';

/// Guess the scheme of the input and return a correct URI
/// Detect if is URL, file or search content
String detectUrl(String input) {
  input = input.trim();

  if (_isUrl(input)) {
    if (!input.startsWith(RegExp(r'https?://'))) {
      return 'http://$input';
    }
    return input;
  }

  if (_isFilePath(input)) {
    return 'file://$input';
  }

  // Treat as a search query
  return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
}

/// Checks if the input is a URL
bool _isUrl(String input) {
  // Regex pattern to match typical URLs
  final urlPattern = RegExp(
    r'^(https?://)?' // optional schene
    r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' // www.blabla.com
    r'|' // OR
    r'[a-zA-Z0-9-]+(:\d+))' // localhost:8000 (with port number)
    r'(\/\S*)?$', // optional path (/search)
  );

  return urlPattern.hasMatch(input);
}

/// Checks if the input is a valid file path
bool _isFilePath(String input) {
  // Attempt to create a File object to verify if it's a valid path
  final file = File(input);
  return file.existsSync() || input.contains(Platform.pathSeparator);
}
