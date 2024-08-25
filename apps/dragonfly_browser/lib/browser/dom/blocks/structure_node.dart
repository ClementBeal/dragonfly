part of '../html_node.dart';

class DivNode extends DomNode {
  DivNode(super.text, {required super.attributes, required super.classes});
}

class MainNode extends DomNode {
  MainNode(super.text, {required super.attributes, required super.classes});
}

class NavNode extends DomNode {
  NavNode(super.text, {required super.attributes, required super.classes});
}

class FooterNode extends DomNode {
  FooterNode(super.text, {required super.attributes, required super.classes});
}

class SectionNode extends DomNode {
  SectionNode(super.text, {required super.attributes, required super.classes});
}

class HeaderNode extends DomNode {
  HeaderNode(super.text, {required super.attributes, required super.classes});
}

class ImgNode extends DomNode {
  ImgNode({required super.attributes, required super.classes}) : super('');
}
