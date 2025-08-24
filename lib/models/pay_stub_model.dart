class PayStubModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final double basicSalary;
  final double regularOvertime;
  final double weekendOvertime;
  final double statutoryHolidayOvertime;
  final double overtimePay;
  final double nightShiftAllowance;
  final double performancePay;
  final Map<String, dynamic> otherAdditionalItems;
  final double otherDeductions;
  final double socialInsurance;
  final double publicProvidentFund;
  final double individualIncomeTax;
  final double grossPay;
  final double netPay;
  final String payday;
  final String paymentYearAndMonth;
  final DateTime created;
  final DateTime updated;

  PayStubModel({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.basicSalary,
    required this.regularOvertime,
    required this.weekendOvertime,
    required this.statutoryHolidayOvertime,
    required this.overtimePay,
    required this.nightShiftAllowance,
    required this.performancePay,
    required this.otherAdditionalItems,
    required this.otherDeductions,
    required this.socialInsurance,
    required this.publicProvidentFund,
    required this.individualIncomeTax,
    required this.grossPay,
    required this.netPay,
    required this.payday,
    required this.paymentYearAndMonth,
    required this.created,
    required this.updated,
  });

  factory PayStubModel.fromJson(Map<String, dynamic> json) {
    return PayStubModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      basicSalary: (json['basic_salary'] ?? 0).toDouble(),
      regularOvertime: (json['regular_overtime'] ?? 0).toDouble(),
      weekendOvertime: (json['weekend_overtime'] ?? 0).toDouble(),
      statutoryHolidayOvertime: (json['statutory_holiday_overtime'] ?? 0).toDouble(),
      overtimePay: (json['overtime_pay'] ?? 0).toDouble(),
      nightShiftAllowance: (json['night_shift_allowance'] ?? 0).toDouble(),
      performancePay: (json['performance_pay'] ?? 0).toDouble(),
      otherAdditionalItems: json['other_additional_items'] is Map<String, dynamic> 
          ? json['other_additional_items'] 
          : <String, dynamic>{},
      otherDeductions: (json['other_deductions'] ?? 0).toDouble(),
      socialInsurance: (json['social_insurance'] ?? 0).toDouble(),
      publicProvidentFund: (json['public_provident_fund'] ?? 0).toDouble(),
      individualIncomeTax: (json['individual_income_tax'] ?? 0).toDouble(),
      grossPay: (json['gross_pay'] ?? 0).toDouble(),
      netPay: (json['net_pay'] ?? 0).toDouble(),
      payday: json['payday'] ?? '',
      paymentYearAndMonth: json['payment_year_and_month'] ?? '',
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'basic_salary': basicSalary,
      'regular_overtime': regularOvertime,
      'weekend_overtime': weekendOvertime,
      'statutory_holiday_overtime': statutoryHolidayOvertime,
      'overtime_pay': overtimePay,
      'night_shift_allowance': nightShiftAllowance,
      'performance_pay': performancePay,
      'other_additional_items': otherAdditionalItems,
      'other_deductions': otherDeductions,
      'social_insurance': socialInsurance,
      'public_provident_fund': publicProvidentFund,
      'individual_income_tax': individualIncomeTax,
      'gross_pay': grossPay,
      'net_pay': netPay,
      'payday': payday,
      'payment_year_and_month': paymentYearAndMonth,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}

class PayStubResponse {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<PayStubModel> items;

  PayStubResponse({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory PayStubResponse.fromJson(Map<String, dynamic> json) {
    return PayStubResponse(
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 30,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => PayStubModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}