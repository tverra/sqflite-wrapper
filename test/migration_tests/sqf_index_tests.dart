import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('index is created with only required parameters', () {
      final SqfIndex index = SqfIndex(
        tableName: 'table_name',
        columnNames: <String>['col1'],
      );

      const String expected =
          'CREATE INDEX `idx_table_name_col1` ON `table_name` (`col1`);';

      expect(index.sql, expected);
    });

    test('asserts column list not empty', () {
      expect(() {
        SqfIndex(tableName: 'table_name', columnNames: <String>[]);
      }, throwsA(isA<AssertionError>()));
    });

    test('index name can be defined', () {
      final SqfIndex index = SqfIndex(
        tableName: 'table_name',
        columnNames: <String>['col1'],
        name: 'index_name',
      );

      const String expected =
          'CREATE INDEX `index_name` ON `table_name` (`col1`);';

      expect(index.sql, expected);
    });

    test('index can be unique', () {
      final SqfIndex index = SqfIndex(
        tableName: 'table_name',
        columnNames: <String>['col1'],
        unique: true,
      );

      const String expected =
          'CREATE UNIQUE INDEX `idx_table_name_col1` ON `table_name` (`col1`);';

      expect(index.sql, expected);
    });

    test('index can have multiple columns', () {
      final SqfIndex index = SqfIndex(
        tableName: 'table_name',
        columnNames: <String>['col1', 'col2', 'col3'],
      );

      const String expected = 'CREATE INDEX `idx_table_name_col1_col2_col3` '
          'ON `table_name` (`col1`, `col2`, `col3`);';

      expect(index.sql, expected);
    });
  });

  group('drop statement', () {
    test('drop statement is created', () {
      final SqfIndex index = SqfIndex(
        tableName: 'table_name',
        columnNames: <String>['col1'],
      );

      const String expected = 'DROP INDEX `idx_table_name_col1`;';

      expect(index.drop, expected);
    });
  });

  group('copy with', () {
    test('is copied with only given values changed', () {
      SqfIndex index = SqfIndex(
        tableName: 'table_name',
        columnNames: <String>['col'],
        unique: true,
      );

      expect(
          index.sql,
          'CREATE UNIQUE INDEX `idx_table_name_col` '
          'ON `table_name` (`col`);');

      index = index.copyWith(tableName: 'new_table_name');
      expect(
          index.sql,
          'CREATE UNIQUE INDEX `idx_table_name_col` '
          'ON `new_table_name` (`col`);');

      index = index.copyWith(columnNames: <String>['new_col']);
      expect(
          index.sql,
          'CREATE UNIQUE INDEX `idx_table_name_col` '
          'ON `new_table_name` (`new_col`);');

      index = index.copyWith(unique: false);
      expect(
          index.sql,
          'CREATE INDEX `idx_table_name_col` '
          'ON `new_table_name` (`new_col`);');

      index = index.copyWith(name: 'new_index_name');
      expect(
          index.sql,
          'CREATE INDEX `new_index_name` '
          'ON `new_table_name` (`new_col`);');
    });
  });
}
