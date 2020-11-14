part of sqflite_wrapper;

class TempTable {
  final String identifier;
  String _createTableSql;
  String _dropTableSql;
  Query _query;

  TempTable(this.identifier) {
    _createTableSql = 'CREATE TEMP TABLE _temp_table_$identifier '
        '(${identifier}_value INT NOT NULL)';
    _dropTableSql = 'DROP TABLE temp._temp_table_$identifier';
    _query = Query('temp._temp_table_$identifier', columns: ['${identifier}_value']);
  }

  String get createTableSql {
    return _createTableSql;
  }

  String get dropTableSql {
    return _dropTableSql;
  }

  Query get query {
    return _query;
  }

  void insertValues(Batch batch, List<int> values) {
    values.forEach((value) => batch.rawInsert(
        'INSERT INTO temp._temp_table_$identifier VALUES (?)', [value]));
  }
}
