import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth/user_update_request_model.dart';
import '../models/user_model.dart';
import '../repositories/i_auth_repository.dart';
import 'auth_notifier.dart';

/// 회원정보 수정 상태
class ProfileState {
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;
  final bool isSuccess;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// 회원정보 관리 Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final IAuthRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const ProfileState());

  /// 내 정보 조회
  Future<void> loadMyProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // AuthState에서 토큰 가져오기
      final authState = _ref.read(authNotifierProvider);
      final token = authState.maybeWhen(
        (isLoading, isLoggedIn, user, token, errorMessage) => token,
        orElse: () => null,
      );

      if (token == null || token.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final user = await _repository.getMyProfile(token: token);
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// 회원정보 수정
  Future<void> updateProfile({
    required String name,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      // AuthState에서 토큰 가져오기
      final authState = _ref.read(authNotifierProvider);
      final token = authState.maybeWhen(
        (isLoading, isLoggedIn, user, token, errorMessage) => token,
        orElse: () => null,
      );

      if (token == null || token.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final request = UserUpdateRequestModel(
        name: name,
        password: password,
      );

      await _repository.updateProfile(token: token, request: request);

      // 수정 성공 시 AuthState의 사용자 이름도 업데이트
      _ref.read(authNotifierProvider.notifier).updateUserName(name);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: state.user?.copyWith(name: name),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 성공 상태 초기화
  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}

/// ProfileNotifier Provider
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ProfileNotifier(repository, ref);
});
