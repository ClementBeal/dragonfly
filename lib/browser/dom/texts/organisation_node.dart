part of '../html_node.dart';

class UlNode extends DomNode {
  UlNode({required super.attributes});
}

class LiNode extends DomNode {
  LiNode(this.text, {required super.attributes});

  final String text;
}

class OlNode extends DomNode {
  OlNode({required super.attributes});
}

class ANode extends DomNode {
  ANode(this.text, {required super.attributes});

  final String text;
}
