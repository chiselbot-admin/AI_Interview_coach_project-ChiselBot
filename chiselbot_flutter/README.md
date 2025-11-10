# 🎯 ChiselBot - AI 면접 코치

> 주니어 개발자를 위한 AI 기반 실시간 면접 코칭 시스템

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#️-기술-스택)
- [프로젝트 구조](#-프로젝트-구조)
- [시작하기](#-시작하기)
- [개발 환경 설정](#️-개발-환경-설정)
- [API 문서](#-api-문서)
- [라이선스](#-라이선스)

## 🎓 프로젝트 소개

**ChiselBot**은 주니어 개발자들이 기술 면접을 준비할 수 있도록 돕는 AI 기반 면접 코칭 플랫폼입니다.
사용자가 면접 질문에 답변하면 GPT 모델이 실시간으로 상세한 피드백을 제공하여 면접 실력 향상을 지원합니다.

### 핵심 가치

- 🎯 **맞춤형 학습**: 난이도별 질문과 개인화된 피드백
- ⚡ **실시간 코칭**: AI 기반 즉각적인 답변 분석
- 📊 **성장 추적**: 면접 아카이브를 통한 학습 이력 관리
- 🔐 **간편 인증**: 카카오 소셜 로그인 지원

## 🌟 주요 기능

### 1. 면접 질문 연습
- 다양한 주제별 질문 제공 (Frontend, Backend, Database, API 등)
- 난이도별(Level 1-2) 질문 필터링
- 카테고리별 질문 탐색

### 2. AI 피드백 시스템
- **GPT-5-nano** 모델 기반 답변 분석
- 레벨별 맞춤 피드백 전략
    - Level 1: 기본 개념 이해도 평가
    - Level 2: 심화 내용 및 실무 적용성 분석
- 유사도 점수 및 개선 제안 제공

### 3. 면접 아카이브
- 답변 내역 저장 및 조회
- 피드백 이력 관리
- 학습 진도 추적

### 4. 사용자 관리
- 카카오 OAuth 2.0 간편 로그인
- JWT 기반 인증/인가
- 이메일 인증 (선택적)

### 5. 커뮤니티 기능
- 공지사항 조회
- 1:1 문의 시스템
- 관리자 대시보드

## 🛠️ 기술 스택

### 📱 Frontend (Flutter)

| 카테고리 | 기술 |
|---------|------|
| **프레임워크** | Flutter 3.6.2, Dart |
| **상태관리** | Riverpod 2.5.1 |
| **UI/UX** | Material Design, Google Fonts, FlexColorScheme |
| **네트워킹** | Dio 5.9.0 |
| **인증** | Kakao Flutter SDK 1.9.5 |
| **로컬 저장소** | SharedPreferences 2.5.3 |
| **코드 생성** | Freezed 2.5.8, JSON Serializable 6.8.0 |

### 💻 Backend (Spring Boot)

| 카테고리 | 기술 |
|---------|------|
| **프레임워크** | Spring Boot 3.4.10 |
| **언어** | Java 21 |
| **AI 연동** | Spring AI, OpenAI GPT-5-nano |
| **데이터베이스** | H2 (Dev), PostgreSQL (Prod) |
| **ORM** | Spring Data JPA, Hibernate |
| **보안** | JWT (JJWT 0.12.6), Spring Security Crypto |
| **템플릿 엔진** | Mustache |
| **이메일** | Spring Mail (Gmail SMTP) |

### 🏗️ 아키텍처 패턴

- **클린 아키텍처**: 레이어별 명확한 책임 분리
- **SOLID 원칙**: 단일 책임, 의존성 역전 원칙 적용
- **전략 패턴**: 로그인 전략, 피드백 전략 구현
- **팩토리 패턴**: 전략 객체 생성 관리

## 📂 프로젝트 구조

### Flutter Client (`chiselbot_flutter/lib`)

```
lib/
├── core/                    # 앱 전역 설정
│   ├── app_router.dart      # 라우팅 관리
│   ├── app_theme.dart       # 테마 설정
│   └── constants.dart       # 상수 정의
│
├── models/                  # 데이터 모델 (DTO)
│   ├── auth/               # 인증 관련 모델
│   ├── login/              # 로그인 모델
│   ├── user_model.dart     # 사용자 모델
│   └── common_response.dart # 공통 응답 모델
│
├── providers/              # 상태 관리 (비즈니스 로직)
│   ├── auth_notifier.dart
│   ├── notice_provider.dart
│   └── qna_provider.dart
│
├── repositories/           # API 호출 계층
│   ├── i_auth_repository.dart
│   └── server_notice_repository.dart
│
├── services/               # API 클라이언트
│   ├── api_service.dart
│   └── auth_api_service.dart
│
├── screens/                # UI 화면
│   ├── chat/              # 면접 채팅 화면
│   ├── notice/            # 공지사항
│   ├── qna/               # Q&A
│   └── login_screen.dart
│
└── widgets/                # 재사용 컴포넌트
    ├── auth/
    └── card_view.dart
```

### Spring Boot Backend (`chiselbot_api_server/src`)

```
src/main/java/com/coach/chiselbot/
├── _global/                           # 전역 설정
│   ├── config/                        # 설정 클래스
│   │   ├── jwt/                      # JWT 인증
│   │   │   ├── JwtTokenProvider.java
│   │   │   └── JwtInterceptor.java
│   │   ├── WebConfig.java
│   │   └── WebClientConfig.java
│   ├── dto/                          # 공통 DTO
│   │   └── CommonResponseDto.java
│   ├── entity/                       # 공통 엔티티
│   │   └── BaseEntity.java
│   └── errors/                       # 예외 처리
│       ├── Exception400.java
│       └── ApiExceptionHandler.java
│
├── domain/
│   ├── user/                         # 사용자 도메인
│   │   ├── User.java                # 엔티티
│   │   ├── UserService.java         # 비즈니스 로직
│   │   ├── UserRestController.java  # API 컨트롤러
│   │   ├── login/                   # 로그인 전략
│   │   │   ├── LoginStrategy.java
│   │   │   ├── LocalLoginStrategy.java
│   │   │   ├── KakaoLoginStrategy.java
│   │   │   └── LoginStrategyFactory.java
│   │   └── dto/
│   │       ├── UserRequestDTO.java
│   │       └── UserResponseDTO.java
│   │
│   ├── kakao/                        # 카카오 OAuth
│   │   ├── KakaoOAuthController.java
│   │   └── KakaoOAuthClient.java
│   │
│   ├── interview_question/           # 면접 질문 도메인
│   │   ├── InterviewQuestion.java
│   │   ├── InterviewQuestionService.java
│   │   ├── InterviewQuestionRestController.java
│   │   └── dto/
│   │
│   ├── interview_coach/              # AI 코칭 도메인
│   │   ├── InterviewCoachService.java
│   │   ├── EmbeddingService.java
│   │   ├── feedback/                # 피드백 전략
│   │   │   ├── FeedbackStrategy.java
│   │   │   ├── Level1FeedbackStrategy.java
│   │   │   ├── Level2FeedbackStrategy.java
│   │   │   └── FeedbackStrategyFactory.java
│   │   └── prompt/                  # 프롬프트 관리
│   │       ├── PromptService.java
│   │       └── PromptFactory.java
│   │
│   ├── userStorage/                  # 면접 아카이브
│   │   ├── UserStorage.java
│   │   ├── UserStorageService.java
│   │   └── UserStorageRestController.java
│   │
│   ├── notice/                       # 공지사항
│   │   ├── Notice.java
│   │   ├── NoticeService.java
│   │   └── controller/
│   │
│   └── inquiry/                      # 문의사항
│       ├── Inquiry.java
│       ├── InquiryService.java
│       └── controller/
│
└── resources/
    ├── application.yml               # 기본 설정
    ├── application-local.yml         # 로컬 환경
    ├── application-dev.yml           # 개발 환경
    └── application-prod.yml          # 운영 환경
```

## 🚀 시작하기

### 필수 요구사항

- **Flutter SDK**: 3.6.2 이상
- **Dart SDK**: 3.6.2 이상
- **Java**: 21 이상
- **Gradle**: 8.x
- **IDE**: Android Studio / IntelliJ IDEA / VS Code

### 환경 변수 설정

#### Backend (.env 또는 환경변수)

```properties
# OpenAI API
OPENAI_API_KEY=your_openai_api_key

# Kakao OAuth
KAKAO_CLIENT_ID=your_kakao_client_id
KAKAO_REDIRECT_URI=http://localhost:8080/api/oauth/kakao/callback

# JWT
JWT_SECRET=your_jwt_secret_key_minimum_256_bits
```

#### Flutter (.env)

```properties
# API Base URL
BASE_URL=http://localhost:8080
API_BASE_URL=http://localhost:8080/api

# Kakao
KAKAO_NATIVE_APP_KEY=your_kakao_native_app_key
```

### 설치 및 실행

#### 1. Backend 실행

```bash
# 프로젝트 클론
git clone <repository-url>
cd chiselbot_api_server

# 의존성 설치 및 빌드
./gradlew clean build

# 애플리케이션 실행
./gradlew bootRun
```

서버가 `http://localhost:8080`에서 실행됩니다.

#### 2. Flutter 앱 실행

```bash
# Flutter 프로젝트로 이동
cd chiselbot_flutter

# 의존성 설치
flutter pub get

# 코드 생성 (Freezed, JSON Serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

## 🛠️ 개발 환경 설정

### H2 Database 콘솔 접근

로컬 개발 환경에서 H2 콘솔 사용:

1. 브라우저에서 `http://localhost:8080/h2-console` 접속
2. 접속 정보:
    - JDBC URL: `jdbc:h2:mem:chiselbot`
    - Username: `sa`
    - Password: (비어있음)

### 코드 생성 (Flutter)

모델 클래스 수정 후 자동 코드 생성:

```bash
# 일회성 빌드
flutter pub run build_runner build --delete-conflicting-outputs

# 변경사항 감지 및 자동 빌드
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 📚 API 문서

### 주요 엔드포인트

#### 인증 (Authentication)

```
POST   /api/users/login              # 로컬 로그인
POST   /api/users/join               # 회원가입
GET    /api/oauth/kakao/login        # 카카오 로그인 (리다이렉트)
GET    /api/oauth/kakao/callback     # 카카오 콜백
```

#### 면접 질문 (Interview Questions)

```
GET    /api/interview-questions                    # 질문 목록 조회
GET    /api/interview-questions/{id}               # 질문 상세 조회
GET    /api/interview-questions/category/{name}    # 카테고리별 조회
GET    /api/interview-questions/level/{level}      # 난이도별 조회
```

#### AI 피드백 (Interview Coach)

```
POST   /api/interview-coach/feedback   # 답변에 대한 AI 피드백 요청
```

요청 예시:
```json
{
  "questionId": 1,
  "userAnswer": "사용자의 답변 내용",
  "level": "LEVEL1"
}
```

#### 사용자 저장소 (User Storage)

```
GET    /api/user-storage           # 내 아카이브 목록
POST   /api/user-storage           # 아카이브 저장
GET    /api/user-storage/{id}      # 아카이브 상세 조회
DELETE /api/user-storage/{id}      # 아카이브 삭제
```

#### 공지사항 (Notice)

```
GET    /api/notices        # 공지사항 목록
GET    /api/notices/{id}   # 공지사항 상세
```

#### 문의사항 (Inquiry)

```
GET    /api/inquiries          # 내 문의 목록
POST   /api/inquiries          # 문의 등록
GET    /api/inquiries/{id}     # 문의 상세
```

## 🔐 보안

- **JWT 인증**: 토큰 기반 stateless 인증
- **비밀번호 암호화**: BCrypt 해싱
- **CORS 설정**: 프론트엔드 도메인만 허용
- **환경변수 관리**: 민감정보 분리

## 🎨 UI/UX

- Material Design 3 기반
- 다크/라이트 테마 지원
- 반응형 레이아웃
- 부드러운 애니메이션 효과

