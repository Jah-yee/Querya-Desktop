import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// #1443: Material's `Divider` reads the Material `dividerColor` and is
/// near-black in the light theme. Rules in `lib/` go through `QueryaDivider`
/// (`lib/shared/widgets/querya_divider.dart`).
void main() {
  test('no raw Divider / VerticalDivider in lib/ outside of QueryaDivider', () {
    final banned = RegExp(r'(?<![\w.])(material\.)?(Vertical)?Divider\(');
    final offenders = <String>[];

    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('lib/shared/widgets/querya_divider.dart')) continue;

      if (banned.hasMatch(f.readAsStringSync())) {
        offenders.add(f.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Found raw Divider / VerticalDivider in: $offenders. '
          'Use QueryaDivider from lib/shared/widgets/widgets.dart instead.',
    );
  });
}
