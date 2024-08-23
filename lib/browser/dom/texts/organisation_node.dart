part of '../html_node.dart';

class UlNode extends DomNode {
  UlNode({required super.attributes, required super.classes});
}

class LiNode extends DomNode {
  LiNode(this.text, {required super.attributes, required super.classes});

  final String text;
}

class OlNode extends DomNode {
  OlNode({required super.attributes, required super.classes});
}

class ANode extends DomNode {
  ANode(this.text, {required super.attributes, required super.classes});

  final String text;
}
