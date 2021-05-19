part of sqflite_wrapper;

class Insert {
  final List<String> _conflictValues = <String>[
    'OR ROLLBACK',
    'OR ABORT',
    'OR FAIL',
    'OR IGNORE',
    'OR REPLACE'
  ];

  late final String sql;
  late final List<dynamic> args;

  Insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
    Where? rowIdConstraint,
    List<String>? upsertConflictValues,
    Update? upsertAction,
  }) {
    if (upsertConflictValues != null || upsertAction != null) {
      if (conflictAlgorithm != null) {
        throw ArgumentError(
            <String>["conflict algorithm can't be used on upsert"]);
      }
      if (upsertConflictValues == null || upsertAction == null) {
        throw ArgumentError(<String>[
          'Both upsertConflictValues and upsertAction need to needs to be defined'
        ]);
      }
      if (!upsertAction.forUpsert) {
        throw ArgumentError(<String>['forUpsert is false']);
      }
    }

    final StringBuffer insert = StringBuffer();

    insert.write('INSERT');
    if (conflictAlgorithm != null) {
      insert.write(' ${_conflictValues[conflictAlgorithm.index]}');
    }
    insert.write(' INTO ');
    insert.write(table);
    insert.write(' (');

    final List<dynamic> bindArgs = <dynamic>[];
    final int size = values.length;

    if (size > 0) {
      final StringBuffer sbValues = StringBuffer(') VALUES (');

      if (rowIdConstraint != null && rowIdConstraint.hasClause()) {
        insert.write('rowid, ');
        sbValues.write('(SELECT rowid FROM $table '
            'WHERE ${rowIdConstraint.statement}), ');
        bindArgs.addAll(rowIdConstraint.args);
      }

      int i = 0;
      values.forEach((String colName, dynamic value) {
        if (i++ > 0) {
          insert.write(', ');
          sbValues.write(', ');
        }

        insert.write(colName);

        if (value == null) {
          sbValues.write('NULL');
        } else {
          bindArgs.add(value);
          sbValues.write('?');
        }
      });
      insert.write(sbValues);
    } else {
      if (nullColumnHack == null &&
          (rowIdConstraint == null || !rowIdConstraint.hasClause())) {
        throw ArgumentError('nullColumnHack required when inserting no data');
      }

      if (rowIdConstraint != null && rowIdConstraint.hasClause()) {
        insert.write('rowid) VALUES ((SELECT rowid FROM $table '
            'WHERE ${rowIdConstraint.statement})');
        bindArgs.addAll(rowIdConstraint.args);
      } else {
        insert.write('$nullColumnHack) VALUES (NULL');
      }
    }
    insert.write(')');

    args = bindArgs;

    if (upsertConflictValues != null) {
      insert.write(' ON CONFLICT (');
      _writeColumns(insert, upsertConflictValues);
      insert.write(') DO ${upsertAction!.sql}');

      args.addAll(upsertAction.args);
    }

    sql = insert.toString();
  }
}
