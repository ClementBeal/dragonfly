StyleSheet parseCSS(String css) {
  return CssParser(css).parse();
}

enum CssParserState {
  nothing,
  selector,
  selectorEmpty,
  selectorParsing,
  singleComment,
  multiComment,
  finish,
  parseDeclaration,
}

class Declaration {
  final String property;
  final String value;

  Declaration(this.property, this.value);

  @override
  String toString() {
    return "${property}: ${value}";
  }
}

class Rule {
  final String selector;
  final List<Declaration> declarations;

  Rule(this.selector, this.declarations);
}

class StyleSheet {
  final List<Rule> rules;

  StyleSheet() : rules = [];
}

class CssParser {
  final String css;

  CssParserState state = CssParserState.nothing;

  CssParser(this.css);

  StyleSheet parse() {
    final styleSheet = StyleSheet();
    Rule? currentRule;

    int length = css.length;
    int i = 0;

    while (i < length && state != CssParserState.finish) {
      switch (state) {
        case CssParserState.nothing:
          final char = css[i++];

          if (char == "/") {
            final nextChar = css[i++];
            if (nextChar == "/") {
              state = CssParserState.singleComment;
            } else if (nextChar == "*") {
              state = CssParserState.multiComment;
            }
          } else if (char != " " && char != "\n") {
            state = CssParserState.selector;
            i--;
          }

          break;
        case CssParserState.selector:
          // capture the selector -> body {font-color: red;}
          // I capture the "bpdy"
          final selector = [];
          var char = css[i++];

          while (char != " ") {
            selector.add(char);
            char = css[i++];
          }

          currentRule = Rule(selector.join(""), []);
          state = CssParserState.selectorEmpty;
          break;
        case CssParserState.selectorEmpty:
          // between the "body" and the "{"
          var char = css[i++];
          while (char != "{") {
            char = css[i++];
          }

          state = CssParserState.selectorParsing;

          break;
        case CssParserState.singleComment:
          // if we have a single comment of type "//"
          var char = css[i++];
          while (char != "\n") {
            char = css[i++];
          }
          break;
        case CssParserState.multiComment:
          // if we have a multiline comment /* */
          var char = css[i++];

          if (char == "*") {
            char = css[i++];
            if (char == "/") {
              state = CssParserState.nothing;
            }
          }
          break;
        case CssParserState.finish:
          // we're done
          break;
        case CssParserState.selectorParsing:
          // parse the inside of body {}
          // if it's empty, we go to the next char (next loop iteration)
          // if we have "}", we're done parsing
          var char = css[i++];

          if (char == "}") {
            if (currentRule != null) styleSheet.rules.add(currentRule);
            state = CssParserState.nothing;
          } else if (char != " " && char != "\n") {
            i--;
            state = CssParserState.parseDeclaration;
          }
          break;
        case CssParserState.parseDeclaration:
          // when we have something like "border: 2px solid red;"
          // propert name: parse until we have a ":"
          // then we skip the whitespaces
          // when we first encounter a char,it's the value
          // we stop when we reach ";"
          // and we go bac kto the selector parsing
          var char = css[i++];
          final a = [];
          while (char != ":") {
            a.add(char);
            char = css[i++];
          }

          final property = a.join("");

          while (char == " ") {
            char = css[i++];
          }

          a.clear();

          while (char != ";") {
            a.add(char);
            char = css[i++];
          }

          currentRule?.declarations.add(Declaration(property, a.join("")));
          state = CssParserState.selectorParsing;
          break;
      }
    }

    return styleSheet;
  }
}
