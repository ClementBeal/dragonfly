import 'dart:io';

void main(List<String> args) async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8088,
  );

  print('Serving at http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    // Get the requested path.
    final path = request.uri.path;

    request.response.headers.contentType = ContentType.html;

    // Serve different HTML based on the path.
    if (path == '/other-page') {
      request.response.write(generateOtherPage());
    } else {
      request.response.write(generateHomePage());
    }

    await request.response.close();
  }
}

// HTML for the home page.
String generateHomePage() {
  return '''
<!DOCTYPE html>
<html>
<head>
  <title>Home Page</title>
</head>
<body>

  <h1>Home Page</h1>
  <a href="/other-page">Go to Other Page</a>
  <!-- Other HTML elements... -->

</body>
</html>
  ''';
}

// HTML for the linked page.
String generateOtherPage() {
  return '''
<!DOCTYPE html>
<html>
<head>
  <title>Other Page</title>
</head>
<body>

  <h1>Other Page</h1>
  <p>You have navigated to another page!</p>
  <a href="/">Go Back Home</a> 
  <a href="https://perdu.com">Or if you are lost...</a>

</body>
</html>
  ''';
}
