part of sqflite_wrapper;

class TempTable {
  final String identifier;
  late final String createTableSql;
  late final String dropTableSql;
  late final Query query;

  TempTable(this.identifier, {bool escapeNames = true}) {
    if (escapeNames) {
      createTableSql = 'CREATE TEMP TABLE `_temp_table_$identifier` '
          '(`${identifier}_value` INT NOT NULL)';
      dropTableSql = 'DROP TABLE temp.`_temp_table_$identifier`';
    } else {
      createTableSql = 'CREATE TEMP TABLE _temp_table_$identifier '
          '(${identifier}_value INT NOT NULL)';
      dropTableSql = 'DROP TABLE temp._temp_table_$identifier';
    }
    query = Query(
      escapeNames
          ? 'temp.`_temp_table_$identifier`'
          : 'temp._temp_table_$identifier',
      columns: <String>[
        if (escapeNames) '`${identifier}_value`' else '${identifier}_value'
      ],
      escapeNames: false,
    );
  }

  void insertValues(
    Batch batch,
    List<dynamic> values, {
    bool escapeNames = true,
  }) {
    for (final dynamic value in values) {
      batch.rawInsert(
        escapeNames
            ? 'INSERT INTO temp.`_temp_table_$identifier` VALUES (?)'
            : 'INSERT INTO temp._temp_table_$identifier VALUES (?)',
        <dynamic>[value],
      );
    }
  }
}
