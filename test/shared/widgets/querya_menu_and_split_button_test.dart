import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_action_menu.dart'
    show QueryaActionMenuItem;
import 'package:querya_desktop/shared/widgets/querya_button.dart';
import 'package:querya_desktop/shared/widgets/querya_menu_button.dart';
import 'package:querya_desktop/shared/widgets/querya_split_button.dart';

import '../../support/querya_theme_test_shell.dart';

const _items = [
  QueryaActionMenuItem<String>(value: 'svg', label: 'SVG'),
  QueryaActionMenuItem<String>(value: 'png', label: 'PNG'),
];

material.Widget _shell(material.Widget child) => queryaThemeTestShell(
      child: material.Center(child: material.Row(
        mainAxisSize: material.MainAxisSize.min,
        children: [child],
      )),
    );

void main() {
  group('QueryaMenuButton', () {
    testWidgets('opens its menu and reports the picked value', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _shell(
          QueryaMenuButton<String>(
            label: 'Export',
            items: _items,
            onSelected: (v) => picked = v,
          ),
        ),
      );

      expect(find.text('SVG'), findsNothing);

      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      expect(find.text('SVG'), findsOneWidget);
      expect(find.text('PNG'), findsOneWidget);

      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();

      expect(picked, 'png');
      expect(find.text('SVG'), findsNothing);
    });

    testWidgets('is as tall as a QueryaButton of the same size',
        (tester) async {
      await tester.pumpWidget(
        _shell(
          QueryaMenuButton<String>(
            label: 'Export',
            items: _items,
            onSelected: (_) {},
            size: QueryaControlSize.md,
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(QueryaButton)).height,
        QueryaControlSize.md.height,
      );
    });

    testWidgets('a disabled menu button does not open', (tester) async {
      await tester.pumpWidget(
        _shell(
          QueryaMenuButton<String>(
            label: 'Export',
            items: _items,
            onSelected: (_) {},
            enabled: false,
          ),
        ),
      );

      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();

      expect(find.text('SVG'), findsNothing);
    });

    testWidgets('Enter on the focused button opens the menu', (tester) async {
      await tester.pumpWidget(
        _shell(
          QueryaMenuButton<String>(
            label: 'Export',
            items: _items,
            onSelected: (_) {},
          ),
        ),
      );
      // Tab moves focus to the trigger.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('SVG'), findsOneWidget);
    });
  });

  group('QueryaSplitButton', () {
    testWidgets('the main half runs the action', (tester) async {
      var runs = 0;
      await tester.pumpWidget(
        _shell(
          QueryaSplitButton<String>(
            label: 'Execute',
            onPressed: () => runs++,
            items: _items,
            onSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pump();

      expect(runs, 1);
    });

    testWidgets('the chevron half opens the menu and picks', (tester) async {
      var runs = 0;
      String? picked;
      await tester.pumpWidget(
        _shell(
          QueryaSplitButton<String>(
            label: 'Execute',
            onPressed: () => runs++,
            items: _items,
            onSelected: (v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();
      expect(find.text('SVG'), findsOneWidget);

      await tester.tap(find.text('SVG'));
      await tester.pumpAndSettle();

      expect(picked, 'svg');
      expect(runs, 0);
    });

    testWidgets('both halves have the height of the control size',
        (tester) async {
      await tester.pumpWidget(
        _shell(
          QueryaSplitButton<String>(
            label: 'Execute',
            onPressed: () {},
            items: _items,
            onSelected: (_) {},
            size: QueryaControlSize.md,
          ),
        ),
      );

      final halves = find.byType(QueryaButton);
      expect(halves, findsNWidgets(2));
      for (final half in halves.evaluate()) {
        expect(
          tester.getSize(find.byWidget(half.widget)).height,
          QueryaControlSize.md.height,
        );
      }
      expect(
        tester.getSize(find.byType(QueryaSplitButton<String>)).height,
        QueryaControlSize.md.height,
      );
    });

    testWidgets('loading disables the main half and the menu', (tester) async {
      var runs = 0;
      await tester.pumpWidget(
        _shell(
          QueryaSplitButton<String>(
            label: 'Execute',
            loading: true,
            onPressed: () => runs++,
            items: _items,
            onSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(QueryaButton).first);
      await tester.pump();
      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();

      expect(runs, 0);
      expect(find.text('SVG'), findsNothing);
    });

    testWidgets('no gap between the halves except the 1 px divider',
        (tester) async {
      await tester.pumpWidget(
        _shell(
          QueryaSplitButton<String>(
            label: 'Execute',
            onPressed: () {},
            items: _items,
            onSelected: (_) {},
          ),
        ),
      );

      final halves = find.byType(QueryaButton);
      final left = tester.getRect(halves.at(0));
      final right = tester.getRect(halves.at(1));

      expect(right.left - left.right, 1);
    });
  });
}
