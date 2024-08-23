import 'dart:io';

void main(List<String> args) async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8088,
  );

  print('Serving at http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    final path = request.uri.path;

    if (path == "/style.css") {
      request.response.headers.contentType =
          ContentType("text", "css", charset: "utf-8");
      request.response.write(
        File(r"/home/clement/Documents/Projets/librairies/dragonfly/style.css")
            .readAsStringSync(),
      );
    } else {
      request.response.headers.contentType = ContentType.html;
      request.response.write(generateHomePage());
    }

    await request.response.close();
  }
}

// HTML for the home page.
String generateHomePage() {
  return File(r"/home/clement/Documents/Projets/librairies/dragonfly/a.html")
      .readAsStringSync();
}
