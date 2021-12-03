part of sqflite_wrapper;

class Where {
  final List<String> _whereCombinators = <String>['AND', 'OR'];
  final List<dynamic> args = <dynamic>[];
  String _statement = '';
  int _numberOfConditions = 0;

  Where({
    String? table,
    String? col,
    dynamic val,
    WhereCombinator? combinator,
    WhereType? type,
    bool not = false,
    bool escapeNames = true,
  }) {
    if (table != null || col != null || val != null) {
      assert(col != null);

      if (type == null) {
        if (val == null) {
          addIs(
            col!,
            val,
            table: table,
            not: not,
            combinator: combinator,
            escapeNames: escapeNames,
          );
        } else {
          addEquals(
            col!,
            val,
            table: table,
            not: not,
            combinator: combinator,
            escapeNames: escapeNames,
          );
        }
      } else {
        if (val == null) {
          if (type == WhereType.sqfIn) {
            addIn(
              col!,
              val,
              table: table,
              not: not,
              combinator: combinator,
              escapeNames: escapeNames,
            );
          } else {
            addIs(
              col!,
              val,
              table: table,
              not: not,
              combinator: combinator,
              escapeNames: escapeNames,
            );
          }
        } else {
          if (type == WhereType.sqfIn) {
            addIn(
              col!,
              val,
              table: table,
              not: not,
              combinator: combinator,
              escapeNames: escapeNames,
            );
          } else if (type == WhereType.sqfIs) {
            addIs(
              col!,
              val,
              table: table,
              not: not,
              combinator: combinator,
              escapeNames: escapeNames,
            );
          } else {
            addEquals(
              col!,
              val,
              table: table,
              not: not,
              combinator: combinator,
              escapeNames: escapeNames,
            );
          }
        }
      }
    }
  }

  String get statement {
    return _statement;
  }

  int get numberOfConditions {
    return _numberOfConditions;
  }

  bool hasClause() {
    return _numberOfConditions > 0;
  }

  String _getCombinator(WhereCombinator? combinator) {
    if (_statement == '') {
      return '';
    } else if (combinator == null) {
      return ' ${_whereCombinators[WhereCombinator.and.index]} ';
    } else {
      return ' ${_whereCombinators[combinator.index]} ';
    }
  }

  void add(
    String col,
    String condition,
    dynamic value, {
    String? table,
    WhereCombinator? combinator,
    bool not = false,
    bool escapeNames = true,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write(escapeNames ? '`$table`.' : '$table.');
    buffer.write(escapeNames ? '`$col`' : col);
    buffer.write(' $condition ');

    if (value == null) {
      buffer.write('NULL');
    } else {
      buffer.write('?');
      args.add(value);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addEquals(
    String col,
    dynamic value, {
    String? table,
    WhereCombinator? combinator,
    bool not = false,
    bool escapeNames = true,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write(escapeNames ? '`$table`.' : '$table.');
    buffer.write(escapeNames ? '`$col`' : col);

    if (not) {
      buffer.write(' != ');
    } else {
      buffer.write(' = ');
    }

    if (value == null) {
      buffer.write('NULL');
    } else {
      buffer.write('?');
      args.add(value);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addIn(
    String col,
    List<dynamic> values, {
    String? table,
    WhereCombinator? combinator,
    bool not = false,
    bool escapeNames = true,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write(escapeNames ? '`$table`.' : '$table.');
    buffer.write(escapeNames ? '`$col`' : col);

    if (not) {
      buffer.write(' NOT IN ');
    } else {
      buffer.write(' IN ');
    }

    buffer.write('(');

    for (int i = 0; i < values.length; i++) {
      if (values[i] == null) {
        buffer.write('NULL');
      } else {
        buffer.write('?');
        args.add(values[i]);
      }
      if (i < values.length - 1) buffer.write(', ');
    }
    buffer.write(')');

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addSubQuery(
    String col,
    Query query, {
    String? table,
    WhereCombinator? combinator,
    bool not = false,
    bool escapeNames = true,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write(escapeNames ? '`$table`.' : '$table.');
    buffer.write(escapeNames ? '`$col`' : col);

    if (not) {
      buffer.write(' NOT IN ');
    } else {
      buffer.write(' IN ');
    }

    buffer.write('(${query.sql})');
    args.addAll(query.args);

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addIs(
    String col,
    dynamic value, {
    String? table,
    WhereCombinator? combinator,
    bool not = false,
    bool escapeNames = true,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write(escapeNames ? '`$table`.' : '$table.');
    buffer.write(escapeNames ? '`$col`' : col);

    if (not) {
      buffer.write(' IS NOT ');
    } else {
      buffer.write(' IS ');
    }

    if (value == null) {
      buffer.write('NULL');
    } else {
      buffer.write('?');
      args.add(value);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void combine(Where where, {WhereCombinator? combinator}) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);

    if (where.hasClause()) {
      buffer.write(_getCombinator(combinator));
      buffer.write(where.statement);
    }
    args.addAll(where.args);

    _numberOfConditions += where.numberOfConditions;

    _statement = buffer.toString();
  }
}

enum WhereCombinator { and, or }
enum WhereType { sqfIn, sqfIs }
