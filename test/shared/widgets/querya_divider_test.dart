import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/shared/widgets/querya_divider.dart';

import '../../support/querya_theme_test_shell.dart';

void main() {
  group('QueryaDivider', () {
    testWidgets('a horizontal rule is as tall as its height', (tester) async {
      await tester.pumpWidget(
        queryaThemeTestShell(
          child: const material.Column(
            children: [QueryaDivider(height: 10)],
          ),
        ),
      );

      expect(tester.getSize(find.byType(QueryaDivider)).height, 10);
    });

    testWidgets('a vertical rule is as wide as its width', (tester) async {
      await tester.pumpWidget(
        queryaThemeTestShell(
          child: const material.SizedBox(
            height: 40,
            child: material.Row(
              children: [QueryaDivider.vertical(width: 6)],
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(QueryaDivider)).width, 6);
    });

    testWidgets('an explicit colour wins over the workbench border',
        (tester) async {
      await tester.pumpWidget(
        queryaThemeTestShell(
          child: const material.Column(
            children: [QueryaDivider(color: material.Color(0xFFFF0000))],
          ),
        ),
      );

      final box = tester.widget<material.ColoredBox>(
        find.descendant(
          of: find.byType(QueryaDivider),
          matching: find.byType(material.ColoredBox),
        ),
      );
      expect(box.color, const material.Color(0xFFFF0000));
    });
  });
}
