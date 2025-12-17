import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/ui/widgets/recipe_renderer/recipe_renderer.dart';

void main() {
  testWidgets('main portrait recipe renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 1024,
            child: RecipeRenderer(
              screen: 'main',
              textOverrides: {
                'config': 'Rounds: 5 | Duration: 60s | Numbers: 1-9',
              },
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RecipeRenderer),
      matchesGoldenFile('goldens/main_portrait.png'),
    );
  });

  testWidgets('main landscape recipe renders', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1024,
            height: 768,
            child: RecipeRenderer(
              screen: 'main',
              textOverrides: {
                'config': 'Rounds: 5 | Duration: 60s | Numbers: 1-9',
              },
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RecipeRenderer),
      matchesGoldenFile('goldens/main_landscape.png'),
    );
  });

  testWidgets('active session portrait recipe renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 1024,
            child: RecipeRenderer(
              screen: 'active_session',
              textOverrides: {
                'chrome.roundLabel': 'Round 1 / 5',
                'chrome.timeLabel': '00:15/01:00',
                'chrome.bottomTimer': '00:45',
                'body.bigNumber': '7',
              },
              colorOverrides: {
                'bg': Color(0xFF2FA64A),
              },
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RecipeRenderer),
      matchesGoldenFile('goldens/active_session_portrait.png'),
    );
  });
}
