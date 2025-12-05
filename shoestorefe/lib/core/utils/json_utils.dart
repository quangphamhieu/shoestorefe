class JsonUtils {
  static Map<String, dynamic> normalizeMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    throw ArgumentError('Expected Map<String, dynamic> but got ${source.runtimeType}');
  }
}
