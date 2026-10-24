import 'package:flutter/material.dart';
import 'package:flutter_slide/widgets/feedback/debug/feedback/feedback_composer_screen.dart';
import 'package:flutter_slide/widgets/feedback/debug/feedback/feedback_session.dart';
import 'package:flutter_slide/widgets/feedback/slide_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    SlideLanguage.isEnglish = false;
    FeedbackSession.instance.reset();
  });

  for (final english in [false, true]) {
    testWidgets('Composer follows slide language: ${english ? 'en' : 'ja'}',
        (tester) async {
      SlideLanguage.isEnglish = english;
      FeedbackSession.instance.reset();
      FeedbackSession.instance.draft.title = 'User-entered title';
      await tester
          .pumpWidget(const MaterialApp(home: FeedbackComposerScreen()));
      expect(
          find.text(english ? 'Create an issue' : 'Issue を起票'), findsOneWidget);
      expect(
          find.text(english ? 'Target UI element (optional)' : '対象 UI 要素 (任意)'),
          findsOneWidget);
      expect(find.text(english ? 'Task' : 'タスク管理'), findsOneWidget);
      expect(
          find.text(english ? 'Summary (title)' : '概要 (タイトル)'), findsOneWidget);
      expect(find.text('User-entered title'), findsOneWidget);
      await tester.scrollUntilVisible(
          find.text(english ? 'Reproducibility' : '再現性'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(english ? 'Always' : '常に再現'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
