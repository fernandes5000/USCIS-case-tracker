import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cases_repository.dart';
import '../models/case.dart';

// List of tracked cases
final casesProvider = StateNotifierProvider<CasesNotifier, AsyncValue<List<UserCase>>>((ref) {
  return CasesNotifier(ref.read(casesRepositoryProvider));
});

class CasesNotifier extends StateNotifier<AsyncValue<List<UserCase>>> {
  final CasesRepository _repository;

  CasesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.listCases());
  }

  Future<void> addCase({
    required String receiptNumber,
    String? nickname,
  }) async {
    final newCase = await _repository.addCase(
      receiptNumber: receiptNumber,
      nickname: nickname,
    );
    state = state.whenData((cases) => [newCase, ...cases]);
  }

  Future<void> updateCase({
    required String receiptNumber,
    String? nickname,
  }) async {
    final updated = await _repository.updateCase(
      receiptNumber: receiptNumber,
      nickname: nickname,
    );
    state = state.whenData(
      (cases) => cases.map((c) => c.receiptNumber == receiptNumber ? updated : c).toList(),
    );
  }

  Future<void> deleteCase(String receiptNumber) async {
    await _repository.deleteCase(receiptNumber);
    state = state.whenData(
      (cases) => cases.where((c) => c.receiptNumber != receiptNumber).toList(),
    );
  }
}

// Individual case status (fetched on demand)
final caseStatusProvider = FutureProvider.family<CaseWithStatus, String>(
  (ref, receiptNumber) async {
    return ref.read(casesRepositoryProvider).getCaseStatus(receiptNumber);
  },
);
