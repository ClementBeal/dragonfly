part 'blocks/structure_node.dart';
part 'texts/organisation_node.dart';
part 'texts/header_node.dart';
part 'texts/text_node.dart';

sealed class DomNode {
  final Map<Object, String> attributes;
  final List<String> classes;
  final String text;

  DomNode(this.text,
      {required this.attributes,
      required this.classes}); // class ; id; style ; href...
}

class PageNode extends DomNode {
  PageNode() : super("", attributes: {}, classes: []);
}

class UnkownNode extends DomNode {
  UnkownNode() : super("", attributes: {}, classes: []);
}

class HtmlNode extends DomNode {
  HtmlNode(super.text, {required super.attributes, required super.classes});
}

class HeadNode extends DomNode {
  HeadNode({required super.attributes, required super.classes}) : super('');
}

class BodyNode extends DomNode {
  BodyNode(super.text, {required super.attributes, required super.classes});
}

class TitleNode extends DomNode {
  final String title;

  TitleNode(this.title, {required super.attributes}) : super("", classes: []);
}

class LinkNode extends DomNode {
  LinkNode({required super.attributes}) : super("", classes: []);
}
