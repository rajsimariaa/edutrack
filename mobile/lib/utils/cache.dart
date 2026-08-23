class SimpleCache<T> {
  final Duration ttl;
  T? _data;
  DateTime? _lastFetch;

  SimpleCache({this.ttl = const Duration(minutes: 5)});

  T? get data {
    if (_data == null || _lastFetch == null) return null;
    if (DateTime.now().difference(_lastFetch!) > ttl) {
      _data = null;
      return null;
    }
    return _data;
  }

  set data(T value) {
    _data = value;
    _lastFetch = DateTime.now();
  }

  void invalidate() {
    _data = null;
    _lastFetch = null;
  }
}
