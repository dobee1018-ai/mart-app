# Firebase 기초 설정 현황

## 프로젝트

- Project ID: `wonju-mart-app-1018`
- Display name: `Wonju Mart App`
- Google account: `dobee1018@gmail.com`

## 완료된 작업

- Firebase CLI 설치 및 로그인
- FlutterFire CLI 설치
- Firebase 프로젝트 생성 및 로컬 `.firebaserc` 연결
- Android 앱 등록: `com.example.mart_app`
- iOS 앱 등록: `com.example.martApp`
- Web 앱 등록: `mart_app (web)`
- Flutter 설정 파일 생성: `lib/firebase_options.dart`
- Android 설정 파일 생성: `android/app/google-services.json`
- iOS 설정 파일 생성: `ios/Runner/GoogleService-Info.plist`
- 앱 초기화 코드에서 `DefaultFirebaseOptions.currentPlatform` 연결
- Firestore 기본 데이터베이스 생성
  - Database ID: `(default)`
  - Location: `asia-northeast3`
  - Edition: `standard`
  - Free tier: enabled
- Firestore 보안 규칙 배포
- Firestore 인덱스 배포
- Firebase Storage API 활성화
- 마이페이지 Google 로그인/로그아웃 버튼 연결
- 로그인 성공 시 `users/{uid}` 사용자 문서 저장
- 장보기 메모/마트별 장바구니를 `shopping_memos` 컬렉션에 사용자별 동기화하도록 1차 구현

## 현재 앱에서 가능한 범위

- Web, Android, iOS에서 Firebase Core 초기화 가능
- Web에서 Firebase Auth Google 팝업 로그인을 호출할 수 있음
- 로그인 사용자의 기본 프로필을 Firestore `users` 컬렉션에 저장
- 로그인 사용자의 장보기 메모와 장바구니를 Firestore에 저장/삭제
- Firestore 규칙/인덱스 배포 완료

## 추가 확인이 필요한 콘솔 작업

1. Firebase Authentication에서 로그인 제공자 활성화
   - Google 로그인: 콘솔에서 사용 설정 완료 여부 확인 필요
   - Apple 로그인
   - Kakao/Naver는 Firebase 기본 제공자가 아니므로 커스텀 인증 또는 별도 SDK 연동 필요
2. Storage 생성
   - Storage API는 활성화됨
   - 현재 콘솔에서 프로젝트 요금제 업그레이드가 필요하다고 표시되어 보류
   - 사진 제보/영수증 업로드 기능을 구현할 때 Blaze 업그레이드 재검토
3. Android Google 로그인용 SHA-1 등록
   - 현재 로컬 Java Runtime이 없어 `keytool` 실행 불가
   - Java 설치 후 디버그/릴리즈 SHA-1을 Firebase Android 앱 설정에 추가 필요
4. 실제 배포 전 Android/iOS 패키지명을 출시용 이름으로 변경

## 참고

FlutterFire CLI가 macOS 설정 단계에서 로컬 Ruby `xcodeproj` 패키지 누락으로 한 번 중단되었습니다. 현재 모바일/웹 앱의 기본 Firebase 연결에는 문제가 없고, macOS 앱이 필요해질 때 별도로 보완하면 됩니다.
