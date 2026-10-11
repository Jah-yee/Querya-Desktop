import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_button.dart';
import 'package:querya_desktop/shared/widgets/querya_dialog_actions.dart';

import '../../support/querya_theme_test_shell.dart';

material.Widget _shell(material.Widget child) => queryaThemeTestShell(
      child: material.Center(child: material.SizedBox(width: 600, child: child)),
    );

void main() {
  testWidgets('orders cancel, secondary and the main action left to right',
      (tester) async {
    await tester.pumpWidget(
      _shell(
        QueryaDialogActions(
          cancel: QueryaButton.ghost(label: 'Cancel', onPressed: () {}),
          secondary: [
            QueryaButton.secondary(label: 'Test', onPressed: () {}),
          ],
          primary: QueryaButton.primary(label: 'Save', onPressed: () {}),
        ),
      ),
    );

    final cancel = tester.getTopLeft(find.text('Cancel')).dx;
    final test = tester.getTopLeft(find.text('Test')).dx;
    final save = tester.getTopLeft(find.text('Save')).dx;

    expect(cancel, lessThan(test));
    expect(test, lessThan(save));
  });

  testWidgets('buttons are lg and 8 px apart', (tester) async {
    await tester.pumpWidget(
      _shell(
        QueryaDialogActions(
          cancel: QueryaButton.ghost(label: 'Cancel', onPressed: () {}),
          primary: QueryaButton.primary(label: 'Save', onPressed: () {}),
        ),
      ),
    );

    final buttons = find.byType(QueryaButton);
    final cancel = tester.getRect(buttons.at(0));
    final save = tester.getRect(buttons.at(1));

    expect(cancel.height, QueryaControlSize.lg.height);
    expect(save.height, QueryaControlSize.lg.height);
    expect(save.left - cancel.right, 8);
  });

  testWidgets('the main action is right-aligned', (tester) async {
    await tester.pumpWidget(
      _shell(
        QueryaDialogActions(
          primary: QueryaButton.primary(label: 'Save', onPressed: () {}),
        ),
      ),
    );

    final footer = tester.getRect(find.byType(QueryaDialogActions));
    final save = tester.getRect(find.byType(QueryaButton));

    // 16 px of footer padding on the right.
    expect(footer.right - save.right, 16);
  });

  testWidgets('Esc runs cancel while focus is in the footer', (tester) async {
    var cancelled = 0;
    await tester.pumpWidget(
      _shell(
        QueryaDialogActions(
          cancel: QueryaButton.ghost(
            label: 'Cancel',
            autofocus: true,
            onPressed: () => cancelled++,
          ),
          primary: QueryaButton.primary(label: 'Save', onPressed: () {}),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(cancelled, 1);
  });

  test('bindings map Esc to cancel and Enter to the main action', () {
    var cancelled = 0;
    var saved = 0;
    final bindings = QueryaDialogActions.bindings(
      cancel: QueryaButton.ghost(label: 'Cancel', onPressed: () => cancelled++),
      primary: QueryaButton.primary(label: 'Save', onPressed: () => saved++),
    );

    bindings[const SingleActivator(LogicalKeyboardKey.escape)]!();
    bindings[const SingleActivator(LogicalKeyboardKey.enter)]!();

    expect(cancelled, 1);
    expect(saved, 1);
  });

  test('bindings do not run a disabled or loading main action', () {
    final disabled = QueryaDialogActions.bindings(
      primary: const QueryaButton.primary(label: 'Save'),
    );
    final loading = QueryaDialogActions.bindings(
      primary: QueryaButton.primary(
        label: 'Save',
        loading: true,
        onPressed: () {},
      ),
    );

    expect(disabled, isEmpty);
    expect(loading, isEmpty);
  });

  test('a footer cannot have both a primary and a destructive action', () {
    expect(
      () => QueryaDialogActions(
        primary: QueryaButton.primary(label: 'Save', onPressed: () {}),
        destructive: QueryaButton.destructive(label: 'Delete', onPressed: () {}),
      ),
      throwsAssertionError,
    );
  });

  testWidgets('a cancel that is not ghost is rejected in debug',
      (tester) async {
    await tester.pumpWidget(
      _shell(
        QueryaDialogActions(
          cancel: QueryaButton.primary(label: 'Cancel', onPressed: () {}),
        ),
      ),
    );

    expect(tester.takeException(), isNotNull);
  });
}
