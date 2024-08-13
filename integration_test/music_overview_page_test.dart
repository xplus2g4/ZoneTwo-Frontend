import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
  });
}
