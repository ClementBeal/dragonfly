part 'blocks/structure_node.dart';
part 'texts/organisation_node.dart';
part 'texts/header_node.dart';
part 'texts/text_node.dart';

sealed class DomNode {
  final Map<Object, String> attributes;

  DomNode({required this.attributes}); // class ; id; style ; href...
}

class PageNode extends DomNode {
  PageNode() : super(attributes: {});
}

class UnkownNode extends DomNode {
  UnkownNode() : super(attributes: {});
}

class HtmlNode extends DomNode {
  HtmlNode({required super.attributes});
}

class HeadNode extends DomNode {
  HeadNode({required super.attributes});
}

class BodyNode extends DomNode {
  BodyNode({required super.attributes});
}

class TitleNode extends DomNode {
  final String title;

  TitleNode(this.title, {required super.attributes});
}

class LinkNode extends DomNode {
  LinkNode({required super.attributes});
}
