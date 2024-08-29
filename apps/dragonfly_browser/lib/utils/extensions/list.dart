import 'package:dragonfly/utils/list.dart' as core;

extension BetterIterable<T> on Iterable<T> {
  Iterable<T> intersperseOuter(T Function() element) {
    return core.intersperseOuter(element, this);
  }

  Iterable<T> addAfterEach(T Function(int i) element) sync* {
    final iterator = this.iterator;
    int i = 0;

    yield element(i++);

    if (iterator.moveNext()) {
      do {
        yield iterator.current;
        yield element(i++);
      } while (iterator.moveNext());
    }
  }
}
