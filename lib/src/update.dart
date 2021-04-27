part of sqflite_wrapper;

class Update {
  final List<String> _conflictValues = <String>[
    'OR ROLLBACK',
    'OR ABORT',
    'OR FAIL',
    'OR IGNORE',
    'OR REPLACE'
  ];
  late final String sql;
  late final List<dynamic> args;
  late final bool forUpsert;
  late final Map<String, dynamic> values;

  Update(String table, Map<String, dynamic> values,
      {Where? where, ConflictAlgorithm? conflictAlgorithm}) {
    _buildQuery(values,
        table: table, where: where, conflictAlgorithm: conflictAlgorithm);
  }

  Update.forUpsert(Map<String, dynamic> values,
      {Where? where, ConflictAlgorithm? conflictAlgorithm}) {
    _buildQuery(values,
        where: where, conflictAlgorithm: conflictAlgorithm, forUpsert: true);
  }

  void _buildQuery(
    Map<String, dynamic> values, {
    String? table,
    Where? where,
    ConflictAlgorithm? conflictAlgorithm,
    bool forUpsert = false,
  }) {
    if (values.isEmpty) {
      throw ArgumentError('Empty values');
    }

    final StringBuffer update = StringBuffer();
    args = <dynamic>[];
    this.values = values;
    this.forUpsert = forUpsert;

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

    final List<dynamic> bindArgs = <dynamic>[];
    int i = 0;

    for (final String colName in values.keys) {
      update.write((i++ > 0) ? ', ' : '');
      update.write(colName);

      final dynamic value = values[colName];

      if (value != null) {
        bindArgs.add(value);
        update.write(' = ?');
      } else {
        update.write(' = NULL');
      }
    }
    args.addAll(bindArgs);

    if (where != null && where.hasClause()) {
      update.write(' WHERE ${where.statement}');
      args.addAll(where.args);
    }

    sql = update.toString();
  }
}
