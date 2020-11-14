part of sqflite_wrapper;

class Where {
  final List<String> _whereCombinators = <String>['AND', 'OR'];

  int _numberOfConditions = 0;
  String _statement;
  List _args;

  Where(
      {String table,
      String col,
      dynamic val,
      bool not = false,
      WhereCombinator combinator,
      WhereType type}) {
    if (table != null || col != null || val != null) {
      assert(col != null);

      if (type == null) {
        if (val == null) {
          addIs(col, val, table: table, not: not, combinator: combinator);
        } else {
          addEquals(col, val, table: table, not: not, combinator: combinator);
        }
      } else {
        if (val == null) {
          if (type == WhereType.sqfIn) {
            addIn(col, val, table: table, not: not, combinator: combinator);
          } else {
            addIs(col, val, table: table, not: not, combinator: combinator);
          }
        } else {
          if (type == WhereType.sqfIn) {
            addIn(col, val, table: table, not: not, combinator: combinator);
          } else if (type == WhereType.sqfIs) {
            addIs(col, val, table: table, not: not, combinator: combinator);
          } else {
            addEquals(col, val, table: table, not: not, combinator: combinator);
          }
        }
      }
    }
  }

  String get statement {
    return _statement;
  }

  List get args {
    return _args;
  }

  int get numberOfConditions {
    return _numberOfConditions;
  }

  bool hasClause() {
    return _numberOfConditions > 0;
  }

  String _getCombinator(WhereCombinator combinator) {
    if (_statement == '')
      return '';
    else if (combinator == null)
      return ' ${_whereCombinators[WhereCombinator.and.index]} ';
    else
      return ' ${_whereCombinators[combinator.index]} ';
  }

  void _init() {
    if (_statement == null) _statement = '';
    if (_args == null) _args = [];
  }

  void add(String col, String condition, dynamic value,
      {String table, bool not = false, WhereCombinator combinator}) {
    _init();

    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write('$table.');
    buffer.write('$col $condition ');

    if (value == null) {
      buffer.write('NULL');
    } else {
      buffer.write('?');
      _args.add(value);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addEquals(String col, dynamic value,
      {String table, bool not = false, WhereCombinator combinator}) {
    _init();

    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write('$table.');
    buffer.write(col);

    if (not) {
      buffer.write(' != ');
    } else {
      buffer.write(' = ');
    }

    if (value == null) {
      buffer.write('NULL');
    } else {
      buffer.write('?');
      _args.add(value);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addIn(String col, List values,
      {String table, bool not = false, WhereCombinator combinator}) {
    _init();

    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write('$table.');
    buffer.write(col);

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
        _args.add(values[i]);
      }
      if (i < values.length - 1) buffer.write(', ');
    }
    buffer.write(')');

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addSubQuery(String col, Query query,
      {String table, bool not = false, WhereCombinator combinator}) {
    _init();

    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write('$table.');
    buffer.write(col);

    if (not) {
      buffer.write(' NOT IN ');
    } else {
      buffer.write(' IN ');
    }

    if (query.sql == null) {
      buffer.write('(NULL)');
    } else {
      buffer.write('(${query.sql})');
      if (query.args != null) _args.addAll(query.args);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void addIs(String col, dynamic value,
      {String table, bool not = false, WhereCombinator combinator}) {
    _init();

    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);
    buffer.write(_getCombinator(combinator));
    if (table != null) buffer.write('$table.');
    buffer.write(col);

    if (not) {
      buffer.write(' IS NOT ');
    } else {
      buffer.write(' IS ');
    }

    if (value == null) {
      buffer.write('NULL');
    } else {
      buffer.write('?');
      _args.add(value);
    }

    _statement = buffer.toString();
    _numberOfConditions++;
  }

  void combine(Where where, {WhereCombinator combinator}) {
    _init();

    final StringBuffer buffer = StringBuffer();
    buffer.write(_statement);

    if (where != null) {
      if (where.hasClause()) {
        buffer.write(_getCombinator(combinator));
        buffer.write(where.statement);
      }
      if (where.args != null) {
        args.addAll(where.args);
      }
      _numberOfConditions += where.numberOfConditions;
    }
    _statement = buffer.toString();
  }
}

enum WhereCombinator { and, or }
enum WhereType { sqfIn, sqfIs }
