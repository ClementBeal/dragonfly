import 'package:dragonfly/utils/list.dart' as core;

extension IntersperseOuterExtension<T> on Iterable<T> {
  Iterable<T> intersperseOuter(T Function() element) {
    return core.intersperseOuter(element, this);
  }
}
