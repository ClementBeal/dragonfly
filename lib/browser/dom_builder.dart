import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class Node {
  DomNode data;
  late List<Node> children;

  Node(this.data) {
    children = [];
  }

  // Add a child node
  void addChild(Node child) {
    children.add(child);
  }

  // Remove a child node
  void removeChild(Node child) {
    children.remove(child);
  }

  // Check if the node has children
  bool hasChildren() {
    return children.isNotEmpty;
  }

  @override
  String toString() {
    return _toStringHelper(this, "");
  }

  // Recursive helper function for pretty-printing the tree
  String _toStringHelper(Node node, String prefix) {
    if (node == null) return "";
    String result = "$prefix${node.data}\n";
    for (int i = 0; i < node.children.length; i++) {
      result += _toStringHelper(node.children[i],
          "$prefix${i == node.children.length - 1 ? "└── " : "├── "}");
    }
    return result;
  }
}

class DomBuilder {
  Node parse(String html) {
    final document = HtmlParser(html).parse();

    final tree = Node(PageNode());

    for (var child in document.children) {
      tree.addChild(_parse(child));
    }

    return tree;
  }

  Node _parse(Element element) {
    DomNode node;

    if (element.localName == "head") {
      node = HeadNode(attributes: element.attributes);
    } else if (element.localName == "html") {
      node = HtmlNode(attributes: element.attributes);
    } else if (element.localName == "body") {
      node = BodyNode(attributes: element.attributes);
    } else if (element.localName == "title") {
      node = TitleNode(element.text, attributes: element.attributes);
    } else if (element.localName == "div") {
      node = DivNode(attributes: element.attributes);
    } else if (element.localName == "nav") {
      node = NavNode(attributes: element.attributes);
    } else if (element.localName == "footer") {
      node = FooterNode(attributes: element.attributes);
    } else if (element.localName == "section") {
      node = SectionNode(attributes: element.attributes);
    } else if (element.localName == "header") {
      node = HeaderNode(attributes: element.attributes);
    } else if (element.localName == "ul") {
      node = UlNode(attributes: element.attributes);
    } else if (element.localName == "li") {
      node = LiNode(attributes: element.attributes);
    } else if (element.localName == "ol") {
      node = OlNode(attributes: element.attributes);
    } else if (element.localName == "a") {
      node = ANode(attributes: element.attributes);
    } else if (element.localName == "h1") {
      node = H1Node(attributes: element.attributes);
    } else if (element.localName == "h2") {
      node = H2Node(attributes: element.attributes);
    } else if (element.localName == "h3") {
      node = H3Node(attributes: element.attributes);
    } else if (element.localName == "h4") {
      node = H4Node(attributes: element.attributes);
    } else if (element.localName == "h5") {
      node = H5Node(attributes: element.attributes);
    } else if (element.localName == "h6") {
      node = H6Node(attributes: element.attributes);
    } else if (element.localName == "i") {
      node = INode(attributes: element.attributes);
    } else if (element.localName == "b") {
      node = BNode(attributes: element.attributes);
    } else if (element.localName == "em") {
      node = EmNode(attributes: element.attributes);
    } else if (element.localName == "strong") {
      node = StrongNode(attributes: element.attributes);
    } else if (element.localName == "p") {
      node = PNode(attributes: element.attributes);
    } else if (element.localName == "link") {
      node = LinkNode(attributes: element.attributes);
    } else {
      node = UnkownNode();
    }

    final tree = Node(node);

    for (var child in element.children) {
      tree.addChild(_parse(child));
    }

    return tree;
  }
}
