part of '../html_node.dart';

class INode extends DomNode {
  INode(this.text, {required super.attributes});

  final String text;
}

class BNode extends DomNode {
  BNode(this.text, {required super.attributes});

  final String text;
}

class EmNode extends DomNode {
  EmNode(this.text, {required super.attributes});

  final String text;
}

class StrongNode extends DomNode {
  StrongNode(this.text, {required super.attributes});

  final String text;
}

class PNode extends DomNode {
  PNode(this.text, {required super.attributes});

  final String text;
}
