part of sqflite_wrapper;

class Update {
  String _sql;
  List _args;
  bool _forUpsert;
  Map<String, dynamic> _values;
  final List<String> _conflictValues = <String>[
    'OR ROLLBACK',
    'OR ABORT',
    'OR FAIL',
    'OR IGNORE',
    'OR REPLACE'
  ];

  Update(String table, Map<String, dynamic> values,
      {Where where, ConflictAlgorithm conflictAlgorithm}) {
    _buildQuery(values,
        table: table, where: where, conflictAlgorithm: conflictAlgorithm);
  }

  Update.forUpsert(Map<String, dynamic> values,
      {Where where, ConflictAlgorithm conflictAlgorithm}) {
    _buildQuery(values,
        where: where, conflictAlgorithm: conflictAlgorithm, forUpsert: true);
  }

  void _buildQuery(Map<String, dynamic> values,
      {String table,
      Where where,
      ConflictAlgorithm conflictAlgorithm,
      bool forUpsert = false}) {
    if (values == null || values.isEmpty) {
      throw ArgumentError('Empty values');
    }

    final StringBuffer update = StringBuffer();
    _args = [];
    _values = values;
    _forUpsert = forUpsert;

    update.write('UPDATE');
    if (conflictAlgorithm != null) {
      update.write(' ${_conflictValues[conflictAlgorithm.index]}');
    }
    if (!forUpsert) {
      if (table == null) {
        update.write(' NULL');
      } else {
        update.write(' $table');
      }
    }
    update.write(' SET ');

    final List bindArgs = <dynamic>[];
    int i = 0;

    values.keys.forEach((String colName) {
      update.write((i++ > 0) ? ', ' : '');
      if (colName == null) {
        update.write('NULL');
      } else {
        update.write(colName);
      }
      final value = values[colName];
      if (value != null) {
        bindArgs.add(value);
        update.write(' = ?');
      } else {
        update.write(' = NULL');
      }
    });
    _args.addAll(bindArgs);

    if (where != null && where.hasClause()) {
      update.write(' WHERE ${where.statement}');
      _args.addAll(where.args);
    }

    _sql = update.toString();
  }

  String get sql {
    return _sql;
  }

  List get args {
    return _args;
  }

  Map<String, dynamic> get values {
    return _values;
  }

  bool get forUpsert {
    return _forUpsert;
  }
}
