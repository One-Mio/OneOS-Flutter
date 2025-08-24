class AccountModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String type;
  final double initialAmount;
  final DateTime created;
  final DateTime updated;

  AccountModel({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    required this.type,
    required this.initialAmount,
    required this.created,
    required this.updated,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      initialAmount: (json['initial_amount'] ?? 0).toDouble(),
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
      'initial_amount': initialAmount,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  AccountModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? type,
    double? initialAmount,
    DateTime? created,
    DateTime? updated,
  }) {
    return AccountModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      name: name ?? this.name,
      type: type ?? this.type,
      initialAmount: initialAmount ?? this.initialAmount,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}

class AccountListResponse {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<AccountModel> items;

  AccountListResponse({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory AccountListResponse.fromJson(Map<String, dynamic> json) {
    return AccountListResponse(
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 30,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}