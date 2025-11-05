import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/storage_models.dart';
import '../services/api_service.dart';
import '../services/storage_api.dart'; // extension 불러오기
import 'auth_notifier.dart';
import 'qna_provider.dart'
    show apiServiceProvider; // 여기서 제공 중인 apiServiceProvider 재사용

class StorageListState {
  final bool loading;
  final List<StorageItem> items;
  final String? error;
  const StorageListState(
      {this.loading = false, this.items = const [], this.error});
  StorageListState copyWith(
          {bool? loading, List<StorageItem>? items, String? error}) =>
      StorageListState(
          loading: loading ?? this.loading,
          items: items ?? this.items,
          error: error);
}

final storageListProvider =
    StateNotifierProvider<StorageListNotifier, StorageListState>((ref) {
  final authApi = ref.watch(authApiServiceProvider);
  final api = authApi.api;
  return StorageListNotifier(api);
});

class StorageListNotifier extends StateNotifier<StorageListState> {
  final ApiService _api;
  StorageListNotifier(this._api) : super(const StorageListState());

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _api.fetchStorages();
      state = state.copyWith(loading: false, items: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: '$e');
    }
  }

  Future<void> deleteOne(int storageId) async {
    final prev = state.items;
    state = state.copyWith(
        items: prev.where((e) => e.storageId != storageId).toList());
    try {
      await _api.deleteStorage(storageId);
    } catch (e) {
      state = state.copyWith(items: prev, error: '$e'); // 롤백
      rethrow;
    }
  }
}

// 상세는 요청 시점에만
final storageDetailProvider =
    FutureProvider.family<StorageDetail, int>((ref, id) async {
  final authApi = ref.watch(authApiServiceProvider);
  final api = authApi.api;
  return api.fetchStorageDetail(id);
});
