import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'mocks/fake_app.dart';

Future<void> _loadPlaylistOverviewPage(WidgetTester tester) async {
  await tester.pumpWidget(await fakeApp());

  final tabBtn = find.byKey(const ValueKey('playlist_tab'));
  await tester.tap(tabBtn);

  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("playlist overview page test", () {
    testWidgets("navigating to playlist overview page", (tester) async {
      await _loadPlaylistOverviewPage(tester);

      expect(find.text("All Playlists"), findsOneWidget);
    });

    testWidgets("page with no playlist", (tester) async {
      await _loadPlaylistOverviewPage(tester);

      expect(find.text("Create your playlist now!"), findsOneWidget);
    });
  });
}
