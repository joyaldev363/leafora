/// A generic, reusable wrapper for paginated collections across Leafora.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });

  /// The list of items on the current page.
  final List<T> items;

  /// The total number of items available across all pages.
  final int totalCount;

  /// The 1-based page index.
  final int page;

  /// Whether there are more pages available to fetch.
  final bool hasMore;

  /// Creates an empty paginated result.
  factory PaginatedResponse.empty() {
    return const PaginatedResponse(
      items: [],
      totalCount: 0,
      page: 1,
      hasMore: false,
    );
  }
}
