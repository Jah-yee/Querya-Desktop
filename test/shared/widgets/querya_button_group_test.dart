import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_button.dart';
import 'package:querya_desktop/shared/widgets/querya_button_group.dart';

import '../../support/querya_theme_test_shell.dart';

material.Widget _shell(material.Widget child) => queryaThemeTestShell(
      child: material.Center(
        child: material.Row(
          mainAxisSize: material.MainAxisSize.min,
          children: [child],
        ),
      ),
    );

void main() {
  group('QueryaButtonGroup', () {
    testWidgets('each segment runs its own action', (tester) async {
      final pressed = <int>[];
      await tester.pumpWidget(
        _shell(
          QueryaButtonGroup(
            items: [
              QueryaButtonGroupItem(
                label: 'Depth 1',
                isActive: true,
                onPressed: () => pressed.add(1),
              ),
              QueryaButtonGroupItem(
                label: 'Depth 2',
                onPressed: () => pressed.add(2),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Depth 2'));
      await tester.tap(find.text('Depth 1'));

      expect(pressed, [2, 1]);
    });

    testWidgets('a disabled segment does not fire', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        _shell(
          QueryaButtonGroup(
            items: [
              const QueryaButtonGroupItem(label: 'Off'),
              QueryaButtonGroupItem(
                label: 'On',
                onPressed: () => fired = true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Off'));
      expect(fired, isFalse);

      await tester.tap(find.text('On'));
      expect(fired, isTrue);
    });

    testWidgets('segments have the control height and a 1 px divider',
        (tester) async {
      await tester.pumpWidget(
        _shell(
          QueryaButtonGroup(
            size: QueryaControlSize.sm,
            items: [
              QueryaButtonGroupItem(label: 'A', onPressed: () {}),
              QueryaButtonGroupItem(label: 'B', onPressed: () {}),
            ],
          ),
        ),
      );

      final segments = find.byType(QueryaButton);
      final a = tester.getRect(segments.at(0));
      final b = tester.getRect(segments.at(1));

      expect(a.height, QueryaControlSize.sm.height);
      expect(b.height, QueryaControlSize.sm.height);
      expect(b.left - a.right, 1);
    });
  });
}
