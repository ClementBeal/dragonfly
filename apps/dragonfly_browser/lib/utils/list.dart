Iterable<T> intersperseOuter<T>(
    T Function() element, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;

  if (iterator.moveNext()) {
    yield element();
    do {
      yield iterator.current;
      yield element();
    } while (iterator.moveNext());
  } else {
    yield element();
  }
}

Iterable<T> intersperseInner<T>(
    T Function() element, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;

  if (iterator.moveNext()) {
    do {
      yield iterator.current;
      yield element();
    } while (iterator.moveNext());
  } else {
    yield element();
  }
}
