# Flutter 마이그레이션 메모

## 작업 기준

- 원본 프로젝트: `/Users/hanseunghan/test.py/mart.app`
- 마이그레이션 프로젝트: `/Users/hanseunghan/test.py/mart.app_flutter_migration`
- 기존 Capacitor/정적 웹 프로토타입 보관 위치: `legacy_capacitor_prototype/`

원본 프로젝트는 수정하지 않고, 복사본에서 Flutter 재구축을 시작했다.

## 현재 완료된 작업

- Flutter 프로젝트 골격 생성
- Firebase 기본 의존성 추가
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
  - `firebase_storage`
  - `firebase_messaging`
  - `google_sign_in`
- 기획서 기준 Firestore 컬렉션 상수 추가
- 기획서 기준 핵심 데이터 모델 추가
  - 사용자
  - 마트
  - 상품
  - 가격/할인 정보
  - 제보
  - 포인트
  - 장보기 메모
  - 영수증 기록
  - 레시피
- MVP 하단 탭 구조 추가
  - 검색
  - 마트
  - 제보
  - 레시피
  - 마이
- Firebase 접근 계층 초안 추가
  - `AuthService`
  - `MartRepository`
  - `ProductRepository`
  - `PriceItemRepository`
  - `ReportRepository`
  - `ShoppingMemoRepository`
- Firebase Storage 업로드 서비스 추가
- Firestore/Storage 보안 규칙 초안 추가
- Firestore 복합 인덱스 초안 추가
- Firestore 날짜 변환 유틸리티 추가
- 주요 모델의 `fromMap`/`toMap` 구조 보강

## Firebase 연결 전 상태

아직 Firebase 프로젝트 설정 파일은 연결하지 않았다.

추가 필요 파일:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`
- FlutterFire 생성 파일: `lib/firebase_options.dart`

Firebase 설정 파일이 없는 환경에서도 앱 구조를 확인할 수 있도록, 현재는 Firebase 초기화 실패 시 안내 배너를 표시한다.

## 다음 작업 순서

1. Firebase 프로젝트 생성 또는 기존 프로젝트 연결
2. `flutterfire configure` 실행
3. Android/iOS Firebase 설정 파일 추가
4. Firebase Auth 로그인 UI 구현
5. 검색 화면을 `products` + `price_items` 컬렉션과 연결
6. 마트 화면을 `marts` + `price_items` 컬렉션과 연결
7. 제보 화면을 Storage 업로드 + `reports` 컬렉션과 연결
8. 관리자 웹/관리자 모드의 승인 플로우 구현
9. Firebase Emulator로 보안 규칙 검증
10. 실제 Firebase 프로젝트에 rules/indexes 배포

## 검증

마이그레이션 초기 골격은 아래 명령으로 확인했다.

```sh
flutter analyze
flutter test
```

결과:
- `flutter analyze`: No issues found
- `flutter test`: All tests passed

repository/model 보강 후에도 동일하게 통과했다.
