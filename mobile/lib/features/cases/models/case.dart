class UserCase {
  final String id;
  final String receiptNumber;
  final String? nickname;
  final String createdAt;

  const UserCase({
    required this.id,
    required this.receiptNumber,
    this.nickname,
    required this.createdAt,
  });

  factory UserCase.fromJson(Map<String, dynamic> json) => UserCase(
        id: json['id'] as String,
        receiptNumber: json['receipt_number'] as String,
        nickname: json['nickname'] as String?,
        createdAt: json['created_at'] as String,
      );

  String get displayName => nickname ?? receiptNumber;
}

class CaseStatus {
  final String? description;
  final String? externalText;
  final String? statusDate;

  const CaseStatus({
    this.description,
    this.externalText,
    this.statusDate,
  });

  factory CaseStatus.fromJson(Map<String, dynamic> json) => CaseStatus(
        description: json['description'] as String?,
        externalText: json['external_text'] as String?,
        statusDate: json['status_date'] as String?,
      );
}

class CaseHistoryEvent {
  final String? date;
  final String? description;
  final String? externalText;

  const CaseHistoryEvent({
    this.date,
    this.description,
    this.externalText,
  });

  factory CaseHistoryEvent.fromJson(Map<String, dynamic> json) => CaseHistoryEvent(
        date: json['date'] as String?,
        description: json['description'] as String?,
        externalText: json['external_text'] as String?,
      );
}

class CaseUscisData {
  final String? receiptNumber;
  final CaseStatus? currentStatus;
  final List<CaseHistoryEvent> history;
  final String? formType;
  final String? applicantName;

  const CaseUscisData({
    this.receiptNumber,
    this.currentStatus,
    this.history = const [],
    this.formType,
    this.applicantName,
  });

  factory CaseUscisData.fromJson(Map<String, dynamic> json) {
    final statusJson = json['case_status'] as Map<String, dynamic>?;
    final historyList = json['case_history'] as List<dynamic>?;

    return CaseUscisData(
      receiptNumber: json['receipt_number'] as String?,
      currentStatus:
          statusJson != null ? CaseStatus.fromJson(statusJson) : null,
      history: historyList
              ?.map((e) => CaseHistoryEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      formType: json['form_type'] as String?,
      applicantName: json['applicant_name'] as String?,
    );
  }
}

class CaseWithStatus {
  final String id;
  final String receiptNumber;
  final String? nickname;
  final String createdAt;
  final CaseUscisData? uscisData;
  final String? cachedAt;

  const CaseWithStatus({
    required this.id,
    required this.receiptNumber,
    this.nickname,
    required this.createdAt,
    this.uscisData,
    this.cachedAt,
  });

  factory CaseWithStatus.fromJson(Map<String, dynamic> json) {
    final uscisJson = json['uscis_data'] as Map<String, dynamic>?;
    return CaseWithStatus(
      id: json['id'] as String,
      receiptNumber: json['receipt_number'] as String,
      nickname: json['nickname'] as String?,
      createdAt: json['created_at'] as String,
      uscisData: uscisJson != null ? CaseUscisData.fromJson(uscisJson) : null,
      cachedAt: json['cached_at'] as String?,
    );
  }

  String get displayName => nickname ?? receiptNumber;

  String? get currentStatusDescription =>
      uscisData?.currentStatus?.description;
}
