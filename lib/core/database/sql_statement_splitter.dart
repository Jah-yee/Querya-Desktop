import 'package:flutter/foundation.dart';

/// One statement of a script, as offsets into the script.
class SqlStatementSpan {
  const SqlStatementSpan({
    required this.start,
    required this.end,
    required this.line,
  });

  /// Offset of the first character of the statement (leading blanks skipped).
  final int start;

  /// Offset after its last character (trailing blanks and the `;` excluded).
  final int end;

  /// 1-based line of [start].
  final int line;

  String textIn(String sql) => sql.substring(start, end);
}

/// Splits SQL scripts into statement ranges. Semicolons inside string
/// literals, quoted identifiers, comments and PostgreSQL dollar quotes do not
/// end a statement.
abstract final class SqlStatementSplitter {
  /// `$tag$` or `$$`, matched at an offset (no `^`: it would only match at the
  /// start of the script). One compiled instance for every dollar sign.
  static final RegExp _dollarTag = RegExp(r'\$([a-zA-Z0-9_]*)\$');

  static const int _chDash = 0x2D;
  static const int _chSlash = 0x2F;
  static const int _chAsterisk = 0x2A;
  static const int _chDollar = 0x24;
  static const int _chSingleQuote = 0x27;
  static const int _chDoubleQuote = 0x22;
  static const int _chBacktick = 0x60;
  static const int _chSemicolon = 0x3B;
  static const int _chBackslash = 0x5C;
  static const int _chLf = 0x0A;
  static const int _chCr = 0x0D;

  /// Default script size threshold (64 KB) above which [spansAsync] offloads
  /// parsing to a background isolate via [compute].
  static const int defaultIsolateThreshold = 64 * 1024;

  /// Splits [sql] into statement ranges asynchronously. If [sql.length] exceeds
  /// [isolateThreshold], parsing runs in a background isolate via [compute] so
  /// large scripts do not block the UI thread (#1350).
  static Future<List<SqlStatementSpan>> spansAsync(
    String sql, {
    int isolateThreshold = defaultIsolateThreshold,
  }) async {
    if (sql.length <= isolateThreshold) {
      return spans(sql);
    }
    return compute(spans, sql);
  }

  static List<SqlStatementSpan> spans(String sql) {
    final out = <SqlStatementSpan>[];
    final len = sql.length;
    var i = 0;
    var segmentStart = 0;

    // Statement starts only move forward, so the line of each one is found by
    // counting newlines from the previous start instead of from the top of the
    // script: one pass in total (#1350).
    var lineCountedTo = 0;
    var line = 1;
    int lineAt(int offset) {
      while (lineCountedTo < offset) {
        if (sql.codeUnitAt(lineCountedTo) == _chLf) line++;
        lineCountedTo++;
      }
      return line;
    }

    void close(int end) {
      var s = segmentStart;
      var e = end;
      while (s < e && _isBlank(sql.codeUnitAt(s))) {
        s++;
      }
      while (e > s && _isBlank(sql.codeUnitAt(e - 1))) {
        e--;
      }
      if (e > s) {
        out.add(SqlStatementSpan(start: s, end: e, line: lineAt(s)));
      }
    }

    while (i < len) {
      final code = sql.codeUnitAt(i);

      // Line comment: runs to the end of the line.
      if (code == _chDash && i + 1 < len && sql.codeUnitAt(i + 1) == _chDash) {
        while (i < len &&
            sql.codeUnitAt(i) != _chLf &&
            sql.codeUnitAt(i) != _chCr) {
          i++;
        }
        continue;
      }

      // Block comment.
      if (code == _chSlash &&
          i + 1 < len &&
          sql.codeUnitAt(i + 1) == _chAsterisk) {
        i += 2;
        while (i + 1 < len &&
            !(sql.codeUnitAt(i) == _chAsterisk &&
                sql.codeUnitAt(i + 1) == _chSlash)) {
          i++;
        }
        i = i + 1 < len ? i + 2 : len;
        continue;
      }

      // Dollar quote: $tag$ ... $tag$.
      if (code == _chDollar) {
        final match = _dollarTag.matchAsPrefix(sql, i);
        if (match != null) {
          final tag = match.group(0)!;
          final close = sql.indexOf(tag, i + tag.length);
          i = close == -1 ? len : close + tag.length;
          continue;
        }
      }

      // String literal, with doubled quotes and backslash escapes.
      if (code == _chSingleQuote) {
        i++;
        while (i < len) {
          final curr = sql.codeUnitAt(i);
          if (curr == _chSingleQuote) {
            if (i + 1 < len && sql.codeUnitAt(i + 1) == _chSingleQuote) {
              i += 2;
            } else {
              i++;
              break;
            }
          } else if (curr == _chBackslash && i + 1 < len) {
            i += 2;
          } else {
            i++;
          }
        }
        continue;
      }

      // Quoted identifier: "name" (PostgreSQL) or `name` (MySQL).
      if (code == _chDoubleQuote || code == _chBacktick) {
        final quoteChar = code;
        i++;
        while (i < len) {
          final curr = sql.codeUnitAt(i);
          if (curr == quoteChar) {
            if (i + 1 < len && sql.codeUnitAt(i + 1) == quoteChar) {
              i += 2;
            } else {
              i++;
              break;
            }
          } else {
            i++;
          }
        }
        continue;
      }

      if (code == _chSemicolon) {
        close(i);
        i++;
        segmentStart = i;
        continue;
      }

      i++;
    }
    close(len);
    return out;
  }

  /// The statement the caret at [offset] belongs to. Between statements (a
  /// blank line, or after the last `;`) it is the statement above; before the
  /// first statement it is the first one. Null for an empty script.
  static SqlStatementSpan? at(List<SqlStatementSpan> spans, int offset) {
    if (spans.isEmpty) return null;
    for (final s in spans) {
      if (offset >= s.start && offset <= s.end) return s;
    }
    SqlStatementSpan? above;
    for (final s in spans) {
      if (s.end <= offset) above = s;
    }
    return above ?? spans.first;
  }

  static bool _isBlank(int c) =>
      c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0x0B || c == 0x0C;
}
