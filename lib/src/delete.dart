part of sqflite_wrapper;

class Delete {
  String _sql;
  List _args;

  Delete(String table, {Where where}) {
    final delete = StringBuffer();
    _args = [];

    delete.write('DELETE FROM ');
    if (table == null) {
      delete.write('NULL');
    } else {
      delete.write(table);
    }
    if (where != null && where.hasClause()) {
      delete.write(' WHERE ${where.statement}');
      _args = where.args;
    }
    _sql = delete.toString();
  }

  String get sql {
    return _sql;
  }

  List get args {
    return _args;
  }
}