import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  late Map<String, dynamic> _map;

  setUp(() {
    _map = <String, dynamic>{'val1': 1, 'val2': 2, 'val3': 3};
  });

  group('table', () {
    test('table is given table value', () {
      final Update update = Update('table_name', _map);
      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
    });

    test('table name can be empty string', () {
      final Update update = Update('', _map);
      expect(update.sql, 'UPDATE `` SET `val1` = ?, `val2` = ?, `val3` = ?');
    });

    test('escaping names can be disabled', () {
      final Update update = Update('table_name', _map, escapeNames: false);
      expect(update.sql, 'UPDATE table_name SET val1 = ?, val2 = ?, val3 = ?');
    });
  });

  group('values', () {
    test('values are added to query', () {
      final Update update = Update('table_name', _map);

      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
      expect(update.args, <dynamic>[1, 2, 3]);
    });

    test('values are added if null', () {
      final Update update =
          Update('table_name', <String, dynamic>{'value': null});

      expect(update.sql, 'UPDATE `table_name` SET `value` = NULL');
      expect(update.args, <dynamic>[]);
    });

    test('empty map throws ArgumentError', () {
      expect(
        () {
          Update('table_name', <String, dynamic>{});
        },
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('where', () {
    test('is added to update', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      final Update update = Update('table_name', _map, where: where);

      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ? '
        'WHERE `table_name`.`col` = ?',
      );
      expect(update.args, <dynamic>[1, 2, 3, 'val']);
    });

    test('multiple where conditions is added to update', () {
      final Where where = Where(table: 'table_name', col: 'col1', val: 'val1');
      where.addIs('col2', 'val2', combinator: WhereCombinator.or);
      final Update update = Update('table_name', _map, where: where);

      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ? '
        'WHERE `table_name`.`col1` = ? OR `col2` IS ?',
      );
      expect(update.args, <dynamic>[1, 2, 3, 'val1', 'val2']);
    });

    test('without args is added to update', () {
      final Where where = Where(
        table: 'table_name',
        col: 'col',
        val: null,
        type: WhereType.sqfIs,
      );
      final Update update = Update('table_name', _map, where: where);

      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ? '
        'WHERE `table_name`.`col` IS NULL',
      );
      expect(update.args, <dynamic>[1, 2, 3]);
    });

    test('empty where is not added', () {
      final Where where = Where();
      final Update update = Update('table_name', _map, where: where);

      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
      expect(update.args, <dynamic>[1, 2, 3]);
    });
  });

  group('conflictAlgorithm', () {
    test('does add rollback algorithm if given', () {
      Update update = Update(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      expect(
        update.sql,
        'UPDATE OR ROLLBACK `table_name` '
        'SET `val1` = ?, `val2` = ?, `val3` = ?',
      );

      update = Update(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      expect(
        update.sql,
        'UPDATE OR ABORT `table_name` '
        'SET `val1` = ?, `val2` = ?, `val3` = ?',
      );

      update =
          Update('table_name', _map, conflictAlgorithm: ConflictAlgorithm.fail);
      expect(
        update.sql,
        'UPDATE OR FAIL `table_name` SET `val1` = ?, `val2` = ?, `val3` = ?',
      );

      update = Update(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      expect(
        update.sql,
        'UPDATE OR IGNORE `table_name` '
        'SET `val1` = ?, `val2` = ?, `val3` = ?',
      );

      update = Update(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      expect(
        update.sql,
        'UPDATE OR REPLACE `table_name` '
        'SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
    });

    test('conflict algorithm is not added if null', () {
      final Update update = Update('table_name', _map, conflictAlgorithm: null);
      expect(
        update.sql,
        'UPDATE `table_name` SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
    });

    test('escaping names can be disabled', () {
      final Update update = Update(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.rollback,
        escapeNames: false,
      );
      expect(
        update.sql,
        'UPDATE OR ROLLBACK table_name SET val1 = ?, val2 = ?, val3 = ?',
      );
    });
  });

  group('forUpsert', () {
    test('forUpsert is initially false', () {
      final Update update = Update('table_name', _map);

      expect(update.forUpsert, false);
    });

    test('forUpsert is true if query is for upsert', () {
      final Update update = Update.forUpsert(_map);

      expect(update.forUpsert, true);
    });

    test('table name is not included if forUpsert', () {
      final Update update = Update.forUpsert(_map);
      expect(update.sql, 'UPDATE SET `val1` = ?, `val2` = ?, `val3` = ?');
    });

    test('values are added to query', () {
      final Update update = Update.forUpsert(_map);

      expect(update.sql, 'UPDATE SET `val1` = ?, `val2` = ?, `val3` = ?');
      expect(update.args, <dynamic>[1, 2, 3]);
    });

    test('where is added to query', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      final Update update = Update.forUpsert(_map, where: where);

      expect(
        update.sql,
        'UPDATE SET `val1` = ?, `val2` = ?, `val3` = ? '
        'WHERE `table_name`.`col` = ?',
      );
      expect(update.args, <dynamic>[1, 2, 3, 'val']);
    });

    test('conflictAlgorithm is added', () {
      final Update update =
          Update.forUpsert(_map, conflictAlgorithm: ConflictAlgorithm.rollback);
      expect(
        update.sql,
        'UPDATE OR ROLLBACK SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
    });

    test('escaping names can be disabled', () {
      final Update update = Update.forUpsert(_map, escapeNames: false);
      expect(update.sql, 'UPDATE SET val1 = ?, val2 = ?, val3 = ?');
    });
  });
}
