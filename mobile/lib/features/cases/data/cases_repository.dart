import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/case.dart';

final casesRepositoryProvider = Provider<CasesRepository>((ref) {
  return CasesRepository(ref.read(apiClientProvider).dio);
});

class CasesRepository {
  final Dio _dio;

  CasesRepository(this._dio);

  Future<List<UserCase>> listCases() async {
    final response = await _dio.get('/cases');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UserCase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserCase> addCase({
    required String receiptNumber,
    String? nickname,
  }) async {
    final response = await _dio.post('/cases', data: {
      'receipt_number': receiptNumber.toUpperCase().trim(),
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    return UserCase.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserCase> updateCase({
    required String receiptNumber,
    String? nickname,
  }) async {
    final response = await _dio.patch(
      '/cases/$receiptNumber',
      data: {'nickname': nickname},
    );
    return UserCase.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCase(String receiptNumber) async {
    await _dio.delete('/cases/$receiptNumber');
  }

  Future<CaseWithStatus> getCaseStatus(String receiptNumber) async {
    final response = await _dio.get('/cases/$receiptNumber');
    return CaseWithStatus.fromJson(response.data as Map<String, dynamic>);
  }
}
