class AccountBookModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final double amount;
  final String accountId;
  final String categoryId;
  final DateTime accountBookDate;
  final String? description;
  final String? attachment;
  final DateTime created;
  final DateTime updated;

  AccountBookModel({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.amount,
    required this.accountId,
    required this.categoryId,
    required this.accountBookDate,
    this.description,
    this.attachment,
    required this.created,
    required this.updated,
  });

  factory AccountBookModel.fromJson(Map<String, dynamic> json) {
    return AccountBookModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      accountId: json['account_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      accountBookDate: DateTime.parse(json['transaction_date'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      attachment: json['attachment'],
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'amount': amount,
      'account_id': accountId,
      'category_id': categoryId,
      'transaction_date': accountBookDate.toIso8601String(),
      'description': description,
      'attachment': attachment,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  AccountBookModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    double? amount,
    String? accountId,
    String? categoryId,
    DateTime? accountBookDate,
    String? description,
    String? attachment,
    DateTime? created,
    DateTime? updated,
  }) {
    return AccountBookModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      accountBookDate: accountBookDate ?? this.accountBookDate,
      description: description ?? this.description,
      attachment: attachment ?? this.attachment,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // 判断是否为正数（收入）
  bool get isIncome => amount > 0;

  // 判断是否为负数（支出）
  bool get isExpense => amount < 0;

  // 获取绝对值金额
  double get absoluteAmount => amount.abs();
  
  // Helper method for getting absolute amount
  double getAbsoluteAmount() => amount.abs();
  
  // 格式化交易时间（UTC转北京时间）
  String get formattedCreatedTime {
    try {
      // 转换为北京时间（UTC+8）
      final DateTime beijingDateTime = accountBookDate.add(const Duration(hours: 8));
      return '${beijingDateTime.hour.toString().padLeft(2, '0')}:${beijingDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '${accountBookDate.hour.toString().padLeft(2, '0')}:${accountBookDate.minute.toString().padLeft(2, '0')}';
    }
  }
}

class AccountBookListResponse {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<AccountBookModel> items;

  AccountBookListResponse({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory AccountBookListResponse.fromJson(Map<String, dynamic> json) {
    return AccountBookListResponse(
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 30,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => AccountBookModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}