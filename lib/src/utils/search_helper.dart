/// Helper class for search functionality
class SearchHelper {
  /// Performs a synchronous search on a list of items
  static List<T> searchSync<T>(
    List<T> items,
    String query, {
    String Function(T item)? itemToString,
  }) {
    if (query.isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      final itemText = itemToString != null
          ? itemToString(item).toLowerCase()
          : item.toString().toLowerCase();
      return itemText.contains(lowerQuery);
    }).toList();
  }

  /// Performs an asynchronous search with debouncing support
  static Future<List<T>> searchAsync<T>(
    Future<List<T>> Function(String query) searchFunction,
    String query,
  ) async {
    return await searchFunction(query);
  }
}

