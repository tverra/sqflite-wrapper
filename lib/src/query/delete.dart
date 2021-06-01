part of sqflite_wrapper;

class Delete {
  late final String sql;
  late final List<dynamic> args;

  Delete(String table, {Where? where}) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('DELETE FROM ');
    buffer.write(table);

    if (where != null && where.hasClause()) {
      buffer.write(' WHERE ${where.statement}');
      args = where.args;
    } else {
      args = <dynamic>[];
    }

    this.sql = buffer.toString();
  }
}
