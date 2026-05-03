import 'package:flutter_test/flutter_test.dart';

import 'package:mart_app/firebase/firebase_bootstrap.dart';
import 'package:mart_app/main.dart';

void main() {
  testWidgets('shows migrated bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MartApp(
        firebaseStatus: FirebaseBootstrapStatus.missingConfiguration,
      ),
    );

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('동네마트'), findsOneWidget);
    expect(find.text('소분모임'), findsOneWidget);
    expect(find.text('레시피'), findsOneWidget);
    expect(find.text('메모'), findsOneWidget);
    expect(find.text('마이'), findsOneWidget);

    await tester.tap(find.text('동네마트'));
    await tester.pump();

    expect(find.text('24시간 운영 대형 식자재마트'), findsOneWidget);
  });
}
