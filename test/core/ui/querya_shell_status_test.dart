import 'package:flutter_test/flutter_test.dart';
import 'package:querya_desktop/core/ui/querya_shell_status.dart';

void main() {
  final status = QueryaShellStatus.instance;

  setUp(status.resetForTest);
  tearDown(status.resetForTest);

  test('the busy message goes away with the busy state', () {
    status.beginBusy(message: 'Running query…');
    expect(status.isBusy, isTrue);
    expect(status.statusMessage, 'Running query…');

    status.endBusy();

    expect(status.isBusy, isFalse);
    expect(status.statusMessage, isNull);
  });

  test('a failure replaces the busy message and drops old counts', () {
    status.reportQueryResult(
      duration: const Duration(milliseconds: 7),
      rowCount: 12,
      columnCount: 8,
      message: '12 row(s).',
    );
    status.beginBusy(message: 'Running query…');

    status.reportQueryFailure(
      duration: const Duration(milliseconds: 3),
      message: 'Query failed',
    );

    expect(status.isBusy, isFalse);
    expect(status.statusMessage, 'Query failed');
    expect(status.rowCount, isNull);
    expect(status.columnCount, isNull);
    expect(status.lastQueryDuration, const Duration(milliseconds: 3));
  });

  test('endBusy after a failure keeps the failure message', () {
    status.beginBusy(message: 'Explaining query…');
    status.reportQueryFailure(message: 'Explain failed');

    status.endBusy();

    expect(status.statusMessage, 'Explain failed');
  });

  test('a result message is not cleared by a later endBusy', () {
    status.reportQueryResult(rowCount: 1, columnCount: 1, message: '1 row(s).');

    status.endBusy();

    expect(status.statusMessage, '1 row(s).');
  });
}
