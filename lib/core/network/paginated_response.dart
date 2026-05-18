/// Wraps the standard paginated envelope returned by all list endpoints:
///
/// ```json
/// { "items": [...], "total": 42, "page": 1, "size": 20, "pages": 3 }
/// ```
///
/// Usage:
/// ```dart
/// final page = PaginatedResponse.fromJson(
///   json,
///   (item) => SucursalDto.fromJson(item),
/// );
/// final sucursales = page.items; // List<SucursalDto>
/// ```
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  final List<T> items;

  /// Total number of records across all pages.
  final int total;

  /// Current page number (1-based).
  final int page;

  /// Number of records per page.
  final int size;

  /// Total number of pages.
  final int pages;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final List<dynamic> rawItems = json['items'] as List<dynamic>;

    return PaginatedResponse<T>(
      items: rawItems
          .map((dynamic item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
      pages: json['pages'] as int,
    );
  }
}
