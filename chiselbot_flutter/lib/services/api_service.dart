import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/api_models.dart';
import '../models/inquiry.dart';

class ApiService {
  final String baseUrl;
  String? _jwt;

  ApiService(this.baseUrl);

  void setToken(String? token) => _jwt = token;

  Map<String, String> _headers({bool jsonBody = true}) {
    final h = <String, String>{};
    // 서버에 "JSON 주세요" 힌트를 주기 위해 Accept 추가
    h['Accept'] = 'application/json';
    if (jsonBody) h['Content-Type'] = 'application/json; charset=utf-8';
    if (_jwt != null && _jwt!.isNotEmpty) h['Authorization'] = 'Bearer $_jwt';
    return h;
  }

  // extension에서 쓸 수 있도록 공개 메서드
  Map<String, String> getHeaders({bool jsonBody = true}) =>
      _headers(jsonBody: jsonBody);

  Future<List<InterviewCategory>> fetchCategories() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/interview/categories'),
      headers: _headers(jsonBody: false),
    );
    final m = jsonDecode(res.body);
    if (res.statusCode == 200) {
      if (m is List) {
        return m
            .map<InterviewCategory>((e) => InterviewCategory.fromJson(e))
            .toList();
      }
      final env = ApiEnvelope.fromJson(m, (obj) => obj);
      final list =
          (env.data as List).map((e) => InterviewCategory.fromJson(e)).toList();
      return list;
    }
    throw Exception('카테고리 조회 실패');
  }

  Future<InterviewQuestion> fetchOneQuestion({
    required int categoryId,
    required String level,
  }) async {
    final uri = Uri.parse('$baseUrl/api/interview/questions/one').replace(
        queryParameters: {'categoryId': '$categoryId', 'level': level});

    final res = await http.get(uri, headers: _headers(jsonBody: false));

    // 먼저 상태코드 확인
    if (res.statusCode != 200) {
      // HTML이 온 경우를 쉽게 눈치채기 위한 보호
      final body = res.body;
      final preview = body.length > 200 ? body.substring(0, 200) : body;
      throw Exception('질문 조회 실패 (HTTP ${res.statusCode})\n'
          'URL: $uri\n'
          'Preview: ${preview.replaceAll('\n', ' ')}');
    }

    // 여기서부터 JSON만 파싱
    final m = jsonDecode(res.body);
    if (m is Map && m['success'] == true) {
      return InterviewQuestion.fromJson(m['data']);
    }
    return InterviewQuestion.fromJson(m as Map<String, dynamic>);
  }

  Future<CoachFeedback> coach(
      {required int questionId, required String userAnswer}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/interview/coach'),
      headers: _headers(),
      body: jsonEncode({'questionId': questionId, 'userAnswer': userAnswer}),
    );
    final m = jsonDecode(res.body);
    if (res.statusCode == 200) {
      if (m is Map && m['success'] == true) {
        return CoachFeedback.fromJson(m['data']);
      }
      return CoachFeedback.fromJson(m);
    }
    throw Exception(m is Map ? (m['error'] ?? '코칭 요청 실패') : '코칭 요청 실패');
  }

  // ========================
  // QnA (1:1 문의)
  // ========================

  // 목록: 백에서 Page 래핑을 주므로 content 파싱 대응
  Future<List<Inquiry>> fetchInquiries({int page = 0, int size = 50}) async {
    final uri = Uri.parse('$baseUrl/api/inquiries')
        .replace(queryParameters: {'page': '$page', 'size': '$size'});
    final res = await http.get(uri, headers: _headers(jsonBody: false));
    final m = jsonDecode(res.body);

    if (res.statusCode == 200) {
      dynamic data = m;
      if (m is Map && m['success'] == true) data = m['data'];
      // Page 형태면 content 추출
      final listLike =
          (data is Map && data['content'] is List) ? data['content'] : data;
      return (listLike as List).map((e) => Inquiry.fromJson(e)).toList();
    }
    throw Exception(m is Map ? (m['error'] ?? '문의 목록 조회 실패') : '문의 목록 조회 실패');
  }

  Future<Inquiry> fetchInquiryDetail(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/inquiries/$id'),
      headers: _headers(jsonBody: false),
    );
    final m = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final data = (m is Map && m['success'] == true) ? m['data'] : m;
      return Inquiry.fromJson(data as Map<String, dynamic>);
    }
    throw Exception(m is Map ? (m['error'] ?? '문의 상세 조회 실패') : '문의 상세 조회 실패');
  }

  Future<void> createInquiry(
      {required String title, required String content}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/inquiries'),
      headers: _headers(),
      body: jsonEncode({'title': title, 'content': content}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final m = jsonDecode(res.body);
      throw Exception(m is Map ? (m['error'] ?? '문의 등록 실패') : '문의 등록 실패');
    }
  }

  // 관리자 답변 등록 (임시)
  // Future<void> answerInquiry(
  //     {required int inquiryId, required String answer}) async {
  //   final res = await http.post(
  //     Uri.parse('$baseUrl/api/inquiries/$inquiryId/answer'),
  //     headers: _headers(),
  //     body: jsonEncode({'answerContent': answer}),
  //   );
  //   if (res.statusCode != 200) {
  //     final m = jsonDecode(res.body);
  //     throw Exception(m is Map ? (m['error'] ?? '답변 등록 실패') : '답변 등록 실패');
  //   }
  // }
}
