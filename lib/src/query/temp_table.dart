part of sqflite_wrapper;

class TempTable {
  final String identifier;
  late final String createTableSql;
  late final String dropTableSql;
  late final Query query;

  TempTable(this.identifier) {
    createTableSql = 'CREATE TEMP TABLE _temp_table_$identifier '
        '(${identifier}_value INT NOT NULL)';
    dropTableSql = 'DROP TABLE temp._temp_table_$identifier';
    query = Query(
      'temp._temp_table_$identifier',
      columns: <String>['${identifier}_value'],
    );
  }

  void insertValues(Batch batch, List<dynamic> values) {
    for (final dynamic value in values) {
      batch.rawInsert(
        'INSERT INTO temp._temp_table_$identifier VALUES (?)',
        <dynamic>[value],
      );
    }
  }
}
