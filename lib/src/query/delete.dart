part of sqflite_wrapper;

class Delete {
  late final String sql;
  late final List<dynamic> args;

  Delete(String table, {Where? where, bool escapeNames = true}) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('DELETE FROM ');

    if (escapeNames) {
      buffer.write('`$table`');
    } else {
      buffer.write(table);
    }

    if (where != null && where.hasClause()) {
      buffer.write(' WHERE ${where.statement}');
      args = where.args;
    } else {
      args = <dynamic>[];
    }

    this.sql = buffer.toString();
  }
}
