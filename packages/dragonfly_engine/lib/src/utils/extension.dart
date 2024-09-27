extension SelfMapper<T extends Object> on T {
  S apply<S>(S Function(T self) mapper) => mapper(this);
}
