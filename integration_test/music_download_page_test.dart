import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'mocks/fake_app.dart';

Future<void> _loadDownloadMusicPage(WidgetTester tester) async {
  await tester.pumpWidget(await fakeApp());
  final addMusicBtn = find.text('Add Music');
  await tester.tap(addMusicBtn);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("music download page test", () {
    testWidgets("navigating to page", (tester) async {
      await _loadDownloadMusicPage(tester);

      expect(find.text("Download Music"), findsOneWidget);
    });

    testWidgets("download music", (tester) async {
      await tester.pumpWidget(await fakeApp());
      await tester.enterText(
        find.byType(TextField),
        'https://www.youtube.com/watch?v=zGDzdps75ns',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text("zGDzdps75ns"), findsOneWidget);
      await Future.delayed(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text("Small short test video.mp3"), findsOneWidget);
    });
  });
}
