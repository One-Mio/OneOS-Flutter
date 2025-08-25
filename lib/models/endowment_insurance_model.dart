class EndowmentInsuranceModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final String cityOfInsuranceParticipation;
  final String unitName;
  final double contributionBase;
  final double personalContribution;
  final double unitContribution;
  final String contributionYearAndMonth;
  final DateTime created;
  final DateTime updated;

  EndowmentInsuranceModel({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.cityOfInsuranceParticipation,
    required this.unitName,
    required this.contributionBase,
    required this.personalContribution,
    required this.unitContribution,
    required this.contributionYearAndMonth,
    required this.created,
    required this.updated,
  });

  factory EndowmentInsuranceModel.fromJson(Map<String, dynamic> json) {
    return EndowmentInsuranceModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      cityOfInsuranceParticipation: json['city_of_insurance_participation'] ?? '',
      unitName: json['unit_name'] ?? '',
      contributionBase: (json['contribution_base'] ?? 0).toDouble(),
      personalContribution: (json['personal_contribution'] ?? 0).toDouble(),
      unitContribution: (json['unit_contribution'] ?? 0).toDouble(),
      contributionYearAndMonth: json['contribution_year_and_month'] ?? '',
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'city_of_insurance_participation': cityOfInsuranceParticipation,
      'unit_name': unitName,
      'contribution_base': contributionBase,
      'personal_contribution': personalContribution,
      'unit_contribution': unitContribution,
      'contribution_year_and_month': contributionYearAndMonth,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'EndowmentInsuranceModel(id: $id, cityOfInsuranceParticipation: $cityOfInsuranceParticipation, unitName: $unitName, contributionBase: $contributionBase, personalContribution: $personalContribution, unitContribution: $unitContribution, contributionYearAndMonth: $contributionYearAndMonth)';
  }
}

class EndowmentInsuranceListResponse {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<EndowmentInsuranceModel> items;

  EndowmentInsuranceListResponse({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory EndowmentInsuranceListResponse.fromJson(Map<String, dynamic> json) {
    return EndowmentInsuranceListResponse(
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 30,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => EndowmentInsuranceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'perPage': perPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}