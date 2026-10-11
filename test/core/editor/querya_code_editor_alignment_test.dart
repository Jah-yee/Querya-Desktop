import 'package:flutter/material.dart' as material;
import 'package:flutter/painting.dart' show TextPosition;
import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/core/editor/querya_code_editor.dart';
import 'package:querya_desktop/core/editor/querya_code_language.dart';

import '../../support/querya_theme_test_shell.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    QueryaCodeEditorVariant variant = QueryaCodeEditorVariant.shadcn,
    material.TextAlignVertical? align,
  }) async {
    await tester.pumpWidget(
      queryaThemeTestShell(
        child: material.Center(
          child: material.SizedBox(
            width: 480,
            height: 360,
            child: QueryaCodeEditor(
              language: QueryaCodeLanguage.plain,
              variant: variant,
              enableHighlighting: false,
              textAlignVertical: align,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<double> textOffsetFromTop(WidgetTester tester) async {
    await tester.enterText(find.byType(material.EditableText), 'select 1');
    await tester.pump();
    final field = tester.getRect(find.byType(QueryaCodeEditor));
    // The widget fills the field either way; the caret shows where the text is.
    final render = tester
        .state<material.EditableTextState>(find.byType(material.EditableText))
        .renderEditable;
    final caret = render.getLocalRectForCaret(const TextPosition(offset: 0));
    return render.localToGlobal(caret.topLeft).dy - field.top;
  }

  testWidgets('the shadcn editor starts its text at the top', (tester) async {
    await pump(tester);

    expect(await textOffsetFromTop(tester), lessThan(60));
  });

  testWidgets('the material editor starts its text at the top',
      (tester) async {
    await pump(tester, variant: QueryaCodeEditorVariant.material);

    expect(await textOffsetFromTop(tester), lessThan(60));
  });

  testWidgets('an explicit alignment still wins', (tester) async {
    await pump(
      tester,
      variant: QueryaCodeEditorVariant.material,
      align: material.TextAlignVertical.center,
    );

    expect(await textOffsetFromTop(tester), greaterThan(100));
  });
}
