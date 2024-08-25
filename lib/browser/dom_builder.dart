import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class Tree {
  DomNode data;
  late List<Tree> children;

  Tree(this.data) {
    children = [];
  }

  // Add a child node
  void addChild(Tree child) {
    children.add(child);
  }

  // Remove a child node
  void removeChild(Tree child) {
    children.remove(child);
  }

  // Check if the node has children
  bool hasChildren() {
    return children.isNotEmpty;
  }

  List<Tree> findSubtreesOfType<T>(Tree root) {
    List<Tree> result = [];

    // Helper function to recursively traverse the tree
    void search(Tree node) {
      if (node.data is T) {
        result.add(node);
      }

      // Recursively search in children
      for (Tree child in node.children) {
        search(child);
      }
    }

    search(root);
    return result;
  }

  @override
  String toString() {
    return _toStringHelper(this, "");
  }

  // Recursive helper function for pretty-printing the tree
  String _toStringHelper(Tree node, String prefix) {
    String result = "$prefix${node.data}\n";
    for (int i = 0; i < node.children.length; i++) {
      result += _toStringHelper(node.children[i],
          "$prefix${i == node.children.length - 1 ? "└── " : "├── "}");
    }
    return result;
  }
}

class DomBuilder {
  Tree parse(String html) {
    final document = HtmlParser(html).parse();

    final tree = Tree(PageNode());

    for (var child in document.children) {
      tree.addChild(_parse(child));
    }

    return tree;
  }

  Tree _parse(Element element) {
    DomNode node;

    if (element.localName == "head") {
      node = HeadNode(
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "html") {
      node = HtmlNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "body") {
      node = BodyNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "title") {
      node = TitleNode(element.text, attributes: element.attributes);
    } else if (element.localName == "div") {
      node = DivNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "nav") {
      node = NavNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "footer") {
      node = FooterNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "section") {
      node = SectionNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "header") {
      node = HeaderNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "ul") {
      node = UlNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "li") {
      node = LiNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "ol") {
      node = OlNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "a") {
      node = ANode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "h1") {
      node = H1Node(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "h2") {
      node = H2Node(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "h3") {
      node = H3Node(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "h4") {
      node = H4Node(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "h5") {
      node = H5Node(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "h6") {
      node = H6Node(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "i") {
      node = INode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "b") {
      node = BNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "em") {
      node = EmNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "strong") {
      node = StrongNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "p") {
      node = PNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "pre") {
      node = PreNode(element.text,
          attributes: element.attributes, classes: element.classes.toList());
    } else if (element.localName == "link") {
      node = LinkNode(attributes: element.attributes);
    } else {
      node = UnkownNode();
    }

    final tree = Tree(node);

    for (var child in element.children) {
      tree.addChild(_parse(child));
    }

    return tree;
  }
}
