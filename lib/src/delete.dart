part of sqflite_wrapper;

class Delete {
  late final String sql;
  late final List<dynamic> args;

  Delete(String table, {Where? where, bool escapeNames = true}) {
    final StringBuffer sql = StringBuffer();

    sql.write('DELETE FROM ');

    if (escapeNames) {
      sql.write('`$table`');
    } else {
      sql.write(table);
    }

    if (where != null && where.hasClause()) {
      sql.write(' WHERE ${where.statement}');
      args = where.args;
    } else {
      args = <dynamic>[];
    }

    this.sql = sql.toString();
  }
}
