class PaginationEntity {
  final num itemsPerPage;
  final num currentPage;
  final num totalItems;
  final num totalPages;

  PaginationEntity({
    required this.itemsPerPage,
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
