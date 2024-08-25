class Declaration {
  final String property;
  final String value;

  Declaration(this.property, this.value);

  @override
  String toString() {
    return "$property: $value";
  }
}

class Rule {
  final String selector;
  final List<Declaration> declarations;

  Rule(this.selector, this.declarations);

  Rule copyWith({String? selector, List<Declaration>? declarations}) {
    return Rule(
      selector ?? this.selector,
      declarations ?? this.declarations,
    );
  }

  @override
  String toString() {
    return "$selector {\n  ${declarations.join(';\n  ')};\n}";
  }
}

class StyleSheet {
  final List<Rule> rules;

  StyleSheet(this.rules);

  @override
  String toString() {
    return rules.join('\n');
  }
}
