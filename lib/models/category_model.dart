class CategoryModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String type; // 支出或收入
  final String? icon;
  final String? ownerId; // 父分类ID，为空表示一级分类
  final DateTime created;
  final DateTime updated;

  CategoryModel({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.type,
    this.icon,
    this.ownerId,
    required this.created,
    required this.updated,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'],
      ownerId: json['owner_id'],
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'name': name,
      'type': type,
      'icon': icon,
      'owner_id': ownerId,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? type,
    String? icon,
    String? ownerId,
    DateTime? created,
    DateTime? updated,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      ownerId: ownerId ?? this.ownerId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // 判断是否为一级分类
  bool get isTopLevel => ownerId == null || ownerId!.isEmpty;

  // 判断是否为支出分类
  bool get isExpense => type == '支出';

  // 判断是否为收入分类
  bool get isIncome => type == '收入';
}

class CategoryListResponse {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<CategoryModel> items;

  CategoryListResponse({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 30,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}