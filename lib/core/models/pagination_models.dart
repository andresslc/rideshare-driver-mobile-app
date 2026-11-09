import 'package:driver_app/core/entities.dart/pagination_entity.dart';

class PaginationModel extends PaginationEntity {
  PaginationModel({
    required super.itemsPerPage,
    required super.currentPage,
    required super.totalItems,
    required super.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      itemsPerPage: json['itemsPerPage'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  PaginationEntity get toEntity => PaginationEntity(
    itemsPerPage: itemsPerPage,
    currentPage: currentPage,
    totalItems: totalItems,
    totalPages: totalPages,
  );
}
