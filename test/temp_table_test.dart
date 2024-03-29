import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

import 'helpers/mock_classes.dart';

void main() {
  group('constructor', () {
    test('creating temp table creates create-statement from identifier', () {
      final TempTable tempTable = TempTable('test_test');

      expect(
          tempTable.createTableSql,
          'CREATE TEMP TABLE _temp_table_test_test '
          '(test_test_value INT NOT NULL)');
    });

    test('creating temp table creates drop-statement from identifier', () {
      final TempTable tempTable = TempTable('test_test');

      expect(tempTable.dropTableSql, 'DROP TABLE temp._temp_table_test_test');
    });

    test('creating temp table creates select-statememt from identifier', () {
      final TempTable tempTable = TempTable('temptable');

      expect(
          tempTable.query.sql,
          'SELECT temp._temp_table_temptable.temptable_value '
          'FROM temp._temp_table_temptable');
    });
  });

  group('insertValues', () {
    test('test', () {
      const String insertStatement =
          'INSERT INTO temp._temp_table_test_test VALUES (?)';
      final MockBatch batch = MockBatch();
      final TempTable tempTable = TempTable('test_test');

      tempTable.insertValues(batch, <int>[1, 2, 3]);

      expect(batch.statements,
          <String>[insertStatement, insertStatement, insertStatement]);
      expect(batch.arguments, <int>[1, 2, 3]);
    });
  });
}
