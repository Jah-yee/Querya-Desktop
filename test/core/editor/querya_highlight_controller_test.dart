import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/core/editor/querya_code_language.dart';
import 'package:querya_desktop/core/editor/querya_highlight_controller.dart';
import 'package:querya_desktop/core/editor/syntax_highlight_isolate.dart';
import 'package:querya_desktop/core/editor/syntax_highlight_service.dart';
import 'package:querya_desktop/core/theme/parser/token_colors_highlighter_config.dart';
import 'package:querya_desktop/core/theme/querya_theme.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await SyntaxHighlightService.ensureInitialized();
  });

  testWidgets('buildTextSpan ensures span.toPlainText() == text when text changes for > 8KB script',
      (tester) async {
    final pair = SyntaxHighlightService.createPair(
      language: QueryaCodeLanguage.sql,
      queryaTheme: QueryaTheme.darkDefault,
    );
    final lightHighlighter = pair.light;
    final darkHighlighter = pair.dark;
    final lightConfig = buildDefaultEditorHighlighterConfig(
      QueryaTheme.lightDefault.editor,
    );
    final darkConfig = buildDefaultEditorHighlighterConfig(
      QueryaTheme.darkDefault.editor,
    );
    final grammarJson = SyntaxHighlightService.grammarJsonFor(
      QueryaCodeLanguage.sql,
    );

    // 1. Initialize controller with small text (< threshold) to populate _cachedSpan synchronously
    const smallText = 'SELECT 1 FROM users; -- test';
    final controller = QueryaHighlightController(
      text: smallText,
      language: QueryaCodeLanguage.sql,
      lightHighlighter: lightHighlighter,
      darkHighlighter: darkHighlighter,
      lightThemeConfig: lightConfig,
      darkThemeConfig: darkConfig,
      grammarJson: grammarJson,
      wrapperColor: Colors.black,
    );

    late BuildContext buildContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (ctx) {
            buildContext = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    var span = controller.buildTextSpan(
      context: buildContext,
      withComposing: false,
    );
    expect(span.toPlainText(), smallText);
    expect(span.children, isNotNull);

    // 2. Switch to large text (> 8KB). Stale _cachedSpan from smallText must NOT be returned.
    final largeText = List.filled(500, 'SELECT 1 FROM users; -- test row').join('\n');
    expect(largeText.length, greaterThan(kSyntaxHighlightIsolateThreshold));
    controller.text = largeText;

    span = controller.buildTextSpan(
      context: buildContext,
      withComposing: false,
    );
    // span.toPlainText() MUST match largeText, never stale smallText
    expect(span.toPlainText(), largeText);
    expect(span.toPlainText() == controller.text, isTrue);

    // 3. User edits text while isolate highlight is pending (typing characters)
    final modifiedLargeText = '$largeText\n-- extra query';
    controller.text = modifiedLargeText;

    span = controller.buildTextSpan(
      context: buildContext,
      withComposing: false,
    );
    expect(span.toPlainText(), modifiedLargeText);
    expect(span.toPlainText() == controller.text, isTrue);
    // Must NOT fall back to plain monochrome text: children should be present and styled
    expect(span.children, isNotNull);
    expect(span.children, isNotEmpty);
    bool checkColors(InlineSpan node) {
      if (node is TextSpan) {
        if (node.style?.color != null) return true;
        if (node.children != null && node.children!.any(checkColors)) return true;
      }
      return false;
    }
    expect(checkColors(span), isTrue, reason: 'Syntax highlighting must be preserved during typing');

    // 4. User deletes characters
    final deletedText = modifiedLargeText.substring(0, modifiedLargeText.length - 25);
    controller.text = deletedText;

    span = controller.buildTextSpan(
      context: buildContext,
      withComposing: false,
    );
    expect(span.toPlainText(), deletedText);
    expect(span.toPlainText() == controller.text, isTrue);
    expect(span.children, isNotNull);
    expect(span.children, isNotEmpty);

    controller.dispose();
  });

  group('patchHighlightSegments (#1351)', () {
    test('preserves prefix and suffix colors with accurate length on insertion', () {
      const oldText = 'SELECT * FROM users WHERE active = 1;';
      const newText = 'SELECT * FROM users WHERE active = 1 AND age > 18;';
      final oldSegments = [
        const HighlightSegment(text: 'SELECT', colorArgb: 0xFF569CD6),
        const HighlightSegment(text: ' * FROM ', colorArgb: null),
        const HighlightSegment(text: 'users', colorArgb: 0xFF4EC9B0),
        const HighlightSegment(text: ' WHERE active = 1;', colorArgb: null),
      ];

      final patched = patchHighlightSegments(
        oldText: oldText,
        oldSegments: oldSegments,
        newText: newText,
      );

      final fullText = patched.map((s) => s.text).join();
      expect(fullText, newText);
      expect(patched.first.text, 'SELECT');
      expect(patched.first.colorArgb, 0xFF569CD6);
      expect(patched.any((s) => s.text.contains('users') && s.colorArgb == 0xFF4EC9B0), isTrue);
    });

    test('preserves intact segments on character deletion in the middle', () {
      const oldText = 'SELECT id, name, email FROM accounts;';
      const newText = 'SELECT id, email FROM accounts;';
      final oldSegments = [
        const HighlightSegment(text: 'SELECT', colorArgb: 0xFF569CD6),
        const HighlightSegment(text: ' id, ', colorArgb: null),
        const HighlightSegment(text: 'name', colorArgb: 0xFF9CDCFE),
        const HighlightSegment(text: ', email FROM accounts;', colorArgb: null),
      ];

      final patched = patchHighlightSegments(
        oldText: oldText,
        oldSegments: oldSegments,
        newText: newText,
      );

      final fullText = patched.map((s) => s.text).join();
      expect(fullText, newText);
      expect(patched.first.text, 'SELECT');
      expect(patched.first.colorArgb, 0xFF569CD6);
    });

    test('handles empty strings and complete replacement cleanly', () {
      expect(
        patchHighlightSegments(
          oldText: 'abc',
          oldSegments: [const HighlightSegment(text: 'abc', colorArgb: 123)],
          newText: '',
        ),
        isEmpty,
      );

      final replaced = patchHighlightSegments(
        oldText: 'abc',
        oldSegments: [const HighlightSegment(text: 'abc', colorArgb: 123)],
        newText: 'xyz',
      );
      expect(replaced.map((s) => s.text).join(), 'xyz');
    });
  });
}
