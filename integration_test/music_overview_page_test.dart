import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zonetwo/music_player/music_player.dart';

import 'mocks/fake_app.dart';
import 'music_download_page_test.dart';

Future<void> _loadMusicOverviewPage(WidgetTester tester) async {
  await tester.pumpWidget(await fakeApp());
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("music overview page test", () {
    testWidgets("navigating to music overview page", (tester) async {
      await _loadMusicOverviewPage(tester);

      expect(find.text("All Music"), findsOneWidget);
    });

    testWidgets("page with no music", (tester) async {
      await _loadMusicOverviewPage(tester);

      expect(find.text("Add your music now!"), findsOneWidget);
    });

    testWidgets("page with music", (tester) async {
      await downloadMusic(tester);

      expect(find.text("Add your music now!"), findsNothing);
      expect(find.text("Small short test video"), findsOneWidget);
    });

    testWidgets("playing music", (tester) async {
      await _loadMusicOverviewPage(tester);

      await tester.tap(find.byKey(
          const ValueKey("overview_music_list_tile_Small short test video")));
      await tester.pumpFrames(
          tester.firstWidget(find.byType(FloatingMusicPlayer)),
          const Duration(seconds: 1));

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets("deleting music", (tester) async {
      await _loadMusicOverviewPage(tester);

      await tester.longPress(find.byKey(
          const ValueKey("overview_music_list_tile_Small short test video")));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();

      expect(find.text("Small short test video"), findsNothing);
    });

  });
}
