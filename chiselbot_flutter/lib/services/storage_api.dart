import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import '../models/storage_models.dart';

extension StorageApi on ApiService {
  void _ensureJson(http.Response res) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    if (!ct.contains('application/json')) {
      final preview =
          res.body.length > 200 ? res.body.substring(0, 200) : res.body;
      throw Exception(
          '서버가 JSON이 아닌 응답을 반환했습니다. (status=${res.statusCode})\n$preview');
    }
  }

  Future<List<StorageItem>> fetchStorages() async {
    final uri = Uri.parse('$baseUrl/api/storages');
    final res = await http.get(uri, headers: getHeaders(jsonBody: false));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('인증이 필요합니다. 로그인 후 다시 시도해 주세요.');
    }
    if (res.statusCode == 302 || res.statusCode == 301) {
      throw Exception('서버가 로그인/다른 페이지로 리디렉션했습니다. (status=${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw Exception('보관함 목록 조회 실패 (HTTP ${res.statusCode})');
    }
    _ensureJson(res);

    final m = jsonDecode(res.body);
    final data = (m is Map && m['success'] == true) ? m['data'] : m;
    return (data as List).map((e) => StorageItem.fromJson(e)).toList();
  }

  Future<StorageDetail> fetchStorageDetail(int storageId) async {
    final uri = Uri.parse('$baseUrl/api/storages/$storageId');
    final res = await http.get(uri, headers: getHeaders(jsonBody: false));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('인증이 필요합니다. 로그인 후 다시 시도해 주세요.');
    }
    if (res.statusCode == 302 || res.statusCode == 301) {
      throw Exception('서버가 로그인/다른 페이지로 리디렉션했습니다. (status=${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw Exception('보관함 상세 조회 실패 (HTTP ${res.statusCode})');
    }
    _ensureJson(res);

    final m = jsonDecode(res.body);
    final data = (m is Map && m['success'] == true) ? m['data'] : m;
    return StorageDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<StorageDetail> saveStorage({
    required int questionId,
    required String userAnswer,
    required double similarity,
    String feedback = '',
    String hint = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/storages/storage/save');
    final res = await http.post(
      uri,
      headers: getHeaders(), // JSON 본문
      body: jsonEncode({
        'questionId': questionId,
        'userAnswer': userAnswer,
        'similarity': similarity,
        'feedback': feedback,
        'hint': hint,
      }),
    );

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('인증이 만료되었거나 로그인되지 않았습니다.');
    }
    if (res.statusCode == 302 || res.statusCode == 301) {
      throw Exception('서버가 로그인/다른 페이지로 리디렉션했습니다. (status=${res.statusCode})');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      final preview =
          res.body.length > 200 ? res.body.substring(0, 200) : res.body;
      throw Exception('보관함 저장 실패 (HTTP ${res.statusCode}) $preview');
    }
    _ensureJson(res);

    final m = jsonDecode(res.body);
    final data = (m is Map && m['success'] == true) ? m['data'] : m;
    return StorageDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteStorage(int storageId) async {
    final uri = Uri.parse('$baseUrl/api/storages/storage/$storageId/delete');
    final res = await http.delete(uri, headers: getHeaders(jsonBody: false));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('인증이 필요합니다. 로그인 후 다시 시도해 주세요.');
    }
    if (res.statusCode == 302 || res.statusCode == 301) {
      throw Exception('서버가 로그인/다른 페이지로 리디렉션했습니다. (status=${res.statusCode})');
    }
    if (res.statusCode != 200) {
      final preview =
          res.body.length > 200 ? res.body.substring(0, 200) : res.body;
      throw Exception('보관함 삭제 실패 (HTTP ${res.statusCode}) $preview');
    }
  }
}
