part of sqflite_wrapper;

class Query {
  late final String sql;
  final List<dynamic> args = <dynamic>[];

  Query(
    String table, {
    bool? distinct,
    List<String>? columns,
    List<SqfFunction>? functions,
    Where? where,
    Preload? preload,
    Join? join,
    List<String>? groupBy,
    String? having,
    OrderBy? orderBy,
    int? limit,
    int? offset,
    bool escapeNames = true,
  }) {
    if (groupBy == null && having != null) {
      throw ArgumentError(
          'HAVING clauses are only permitted when using a groupBy clause');
    }

    final StringBuffer query = StringBuffer();

    query.write('SELECT');
    if (distinct == true) {
      query.write(' DISTINCT');
    }

    if (columns == null && functions == null) {
      if (escapeNames) {
        query.write(' `$table`.*');
      } else {
        query.write(' $table.*');
      }
    } else {
      if (functions != null && functions.isNotEmpty) {
        query.write(' ');
        for (int i = 0; i < functions.length; i++) {
          if (i > 0) query.write(', ');
          query.write(functions[i].sql);
        }
        if (columns != null && columns.isNotEmpty) query.write(',');
      }
      if (columns != null && columns.isNotEmpty) {
        query.write(' ');
        _writeColumns(query, columns, table: table, escapeNames: escapeNames);
      }
    }

    if (preload != null && preload.hasClause()) {
      for (int i = 0; i < preload.columns.length; i++) {
        query.write(', ');
        query.write(preload.columns[i]);
      }
    }

    if (escapeNames) {
      query.write(' FROM `$table`');
    } else {
      query.write(' FROM $table');
    }

    if (preload != null && preload.join.hasClause()) {
      query.write(' ${preload.join.statement}');
    }
    if (join != null && join.hasClause()) {
      query.write(' ${join.statement}');
    }

    if (where != null && where.hasClause()) {
      query.write(' WHERE ${where.statement}');
      args.addAll(where.args);
    }

    if (groupBy != null && groupBy.isNotEmpty) {
      query.write(' GROUP BY ');

      for (int i = 0; i < groupBy.length; i++) {
        if (escapeNames) {
          query.write('`${groupBy[i]}`');
        } else {
          query.write(groupBy[i]);
        }
        if (i < groupBy.length - 1) {
          query.write(', ');
        }
      }
    }
    if (having != null) query.write(' HAVING $having');
    if (orderBy != null && orderBy.hasClause()) {
      query.write(' ORDER BY ${orderBy.sql}');
    }
    if (limit != null) query.write(' LIMIT ${limit.toString()}');
    if (offset != null) query.write(' OFFSET ${offset.toString()}');

    sql = query.toString();
  }
}
