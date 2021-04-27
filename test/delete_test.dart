import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('args is initially empty list', () {
      final Delete delete = Delete('table_name');
      expect(delete.args, <dynamic>[]);
    });
  });

  group('table', () {
    test('table is given table value', () {
      final Delete delete = Delete('table_name');
      expect(delete.sql, 'DELETE FROM table_name');
    });

    test('table name can be empty string', () {
      final Delete delete = Delete('');
      expect(delete.sql, 'DELETE FROM ');
    });
  });

  group('where', () {
    test('is added to delete', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      final Delete delete = Delete('table_name', where: where);

      expect(delete.sql, 'DELETE FROM table_name WHERE table_name.col = ?');
      expect(delete.args, <dynamic>['val']);
    });

    test('multiple where conditions is added to delete', () {
      final Where where = Where(table: 'table_name', col: 'col1', val: 'val1');
      where.addIs('col2', 'val2', combinator: WhereCombinator.or);
      final Delete delete = Delete('table_name', where: where);

      expect(delete.sql,
          'DELETE FROM table_name WHERE table_name.col1 = ? OR col2 IS ?');
      expect(delete.args, <dynamic>['val1', 'val2']);
    });

    test('without args is added to delete', () {
      final Where where = Where(
          table: 'table_name', col: 'col', val: null, type: WhereType.sqfIs);
      final Delete delete = Delete('table_name', where: where);

      expect(delete.sql, 'DELETE FROM table_name WHERE table_name.col IS NULL');
      expect(delete.args, <dynamic>[]);
    });

    test('empty where is not added', () {
      final Where where = Where();
      final Delete delete = Delete('table_name', where: where);

      expect(delete.sql, 'DELETE FROM table_name');
      expect(delete.args, <dynamic>[]);
    });
  });
}
