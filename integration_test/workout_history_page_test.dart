import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'mocks/fake_app.dart';

Future<void> _loadWorkoutHistoryPage(WidgetTester tester) async {
  await tester.pumpWidget(await fakeApp());

  final tabBtn = find.byKey(const ValueKey('workout_tab'));
  await tester.tap(tabBtn);

  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("workout history page test", () {
    testWidgets("navigating to workout history page", (tester) async {
      await _loadWorkoutHistoryPage(tester);

      expect(find.text("Workout History"), findsOneWidget);
    });

    testWidgets("page with no workout history", (tester) async {
      await tester.pumpWidget(await fakeApp());
      await tester.pumpAndSettle();

      expect(find.text("The start of an epic journey..."), findsOneWidget);
    });

    testWidgets("start workout playlist selection", (tester) async {
      await tester.pumpWidget(await fakeApp());

      final startWorkoutBtn = find.text("Start Workout");
      await tester.tap(startWorkoutBtn);
      await tester.pumpAndSettle();

      expect(find.text("Select workout playlist"), findsOneWidget);
    });
  });
}
