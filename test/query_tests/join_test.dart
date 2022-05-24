import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('returns empty string initially', () {
      final Join join = Join();
      expect(join.statement, '');
    });

    test('number of joins is initially zero', () {
      final Join join = Join();
      expect(join.numberOfJoins, 0);
    });

    test('adding join increments number of joins', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'fKey',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
      );

      expect(join.numberOfJoins, 1);
    });

    test('hasClause returns false initially', () {
      final Join join = Join();
      expect(join.hasClause(), false);
    });

    test('hasClause returns true if join is added', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'fKey',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
      );

      expect(join.hasClause(), true);
    });

    test('default join is left join if type is null', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'f_key',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
        type: null,
      );

      expect(
        join.statement,
        'LEFT JOIN `table_name` ON `table_name`.`f_key` = '
        '`ref_table_name`.`ref_key`',
      );
    });

    test('tableName is asserted not null', () {
      expect(
        () {
          Join(
            fKey: 'fKey',
            refTableName: 'ref_table_name',
            refKey: 'ref_key',
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('fKey is asserted not null', () {
      expect(
        () {
          Join(
            tableName: 'table_name',
            refTableName: 'ref_table_name',
            refKey: 'ref_key',
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('refTableName is asserted not null', () {
      expect(
        () {
          Join(
            tableName: 'table_name',
            fKey: 'fKey',
            refKey: 'ref_key',
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('refKey is asserted not null', () {
      expect(
        () {
          Join(
            tableName: 'table_name',
            fKey: 'fKey',
            refTableName: 'ref_table_name',
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('escaping names can be disabled', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'f_key',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
        escapeNames: false,
      );

      expect(
        join.statement,
        'LEFT JOIN table_name ON table_name.f_key = ref_table_name.ref_key',
      );
    });
  });

  group('addInnerJoin', () {
    test('adds inner join', () {
      final Join join = Join();
      join.addInnerJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');

      expect(
        join.statement,
        'INNER JOIN `table_name` '
        'ON `table_name`.`fkey` = `ref_table_name`.`ref_key`',
      );
    });

    test('increments numberOfJoins', () {
      final Join join = Join();

      join.addInnerJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');
      expect(join.numberOfJoins, 1);
    });

    test('hasClause is true after adding join', () {
      final Join join = Join();

      join.addInnerJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');
      expect(join.hasClause(), true);
    });

    test('can be added in constructor', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'f_key',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
        type: JoinType.innerJoin,
      );

      expect(
        join.statement,
        'INNER JOIN `table_name` '
        'ON `table_name`.`f_key` = `ref_table_name`.`ref_key`',
      );
    });

    test('multiple inner joins can be added', () {
      final Join join = Join();
      join.addInnerJoin('table_name1', 'fkey4', 'ref_table_name7', 'ref_key10');
      join.addInnerJoin('table_name2', 'fkey5', 'ref_table_name8', 'ref_key11');
      join.addInnerJoin('table_name3', 'fkey6', 'ref_table_name9', 'ref_key12');

      expect(
        join.statement,
        'INNER JOIN `table_name1` ON '
        '`table_name1`.`fkey4` = `ref_table_name7`.`ref_key10` '
        'INNER JOIN `table_name2` ON '
        '`table_name2`.`fkey5` = `ref_table_name8`.`ref_key11` '
        'INNER JOIN `table_name3` ON '
        '`table_name3`.`fkey6` = `ref_table_name9`.`ref_key12`',
      );
    });

    test('escaping names can be disabled', () {
      final Join join = Join();
      join.addInnerJoin(
        'table_name',
        'fkey',
        'ref_table_name',
        'ref_key',
        escapeNames: false,
      );

      expect(
        join.statement,
        'INNER JOIN table_name '
        'ON table_name.fkey = ref_table_name.ref_key',
      );
    });
  });

  group('addLeftJoin', () {
    test('adds left join', () {
      final Join join = Join();
      join.addLeftJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');

      expect(
        join.statement,
        'LEFT JOIN `table_name` '
        'ON `table_name`.`fkey` = `ref_table_name`.`ref_key`',
      );
    });

    test('increments numberOfJoins', () {
      final Join join = Join();

      join.addLeftJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');
      expect(join.numberOfJoins, 1);
    });

    test('hasClause is true after adding join', () {
      final Join join = Join();

      join.addLeftJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');
      expect(join.hasClause(), true);
    });

    test('can be added in constructor', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'f_key',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
        type: JoinType.leftJoin,
      );

      expect(
        join.statement,
        'LEFT JOIN `table_name` '
        'ON `table_name`.`f_key` = `ref_table_name`.`ref_key`',
      );
    });

    test('multiple left joins can be added', () {
      final Join join = Join();
      join.addLeftJoin('table_name1', 'fkey4', 'ref_table_name7', 'ref_key10');
      join.addLeftJoin('table_name2', 'fkey5', 'ref_table_name8', 'ref_key11');
      join.addLeftJoin('table_name3', 'fkey6', 'ref_table_name9', 'ref_key12');

      expect(
        join.statement,
        'LEFT JOIN `table_name1` ON '
        '`table_name1`.`fkey4` = `ref_table_name7`.`ref_key10` '
        'LEFT JOIN `table_name2` ON '
        '`table_name2`.`fkey5` = `ref_table_name8`.`ref_key11` '
        'LEFT JOIN `table_name3` ON '
        '`table_name3`.`fkey6` = `ref_table_name9`.`ref_key12`',
      );
    });

    test('escaping names can be disabled', () {
      final Join join = Join();
      join.addLeftJoin(
        'table_name',
        'fkey',
        'ref_table_name',
        'ref_key',
        escapeNames: false,
      );

      expect(
        join.statement,
        'LEFT JOIN table_name '
        'ON table_name.fkey = ref_table_name.ref_key',
      );
    });
  });

  group('addCrossJoin', () {
    test('adds cross join', () {
      final Join join = Join();
      join.addCrossJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');

      expect(
        join.statement,
        'CROSS JOIN `table_name` '
        'ON `table_name`.`fkey` = `ref_table_name`.`ref_key`',
      );
    });

    test('increments numberOfJoins', () {
      final Join join = Join();

      join.addCrossJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');
      expect(join.numberOfJoins, 1);
    });

    test('hasClause is true after adding join', () {
      final Join join = Join();

      join.addCrossJoin('table_name', 'fkey', 'ref_table_name', 'ref_key');
      expect(join.hasClause(), true);
    });

    test('can be added in constructor', () {
      final Join join = Join(
        tableName: 'table_name',
        fKey: 'f_key',
        refTableName: 'ref_table_name',
        refKey: 'ref_key',
        type: JoinType.crossJoin,
      );

      expect(
        join.statement,
        'CROSS JOIN `table_name` '
        'ON `table_name`.`f_key` = `ref_table_name`.`ref_key`',
      );
    });

    test('multiple cross joins can be added', () {
      final Join join = Join();
      join.addCrossJoin('table_name1', 'fkey4', 'ref_table_name7', 'ref_key10');
      join.addCrossJoin('table_name2', 'fkey5', 'ref_table_name8', 'ref_key11');
      join.addCrossJoin('table_name3', 'fkey6', 'ref_table_name9', 'ref_key12');

      expect(
        join.statement,
        'CROSS JOIN `table_name1` ON '
        '`table_name1`.`fkey4` = `ref_table_name7`.`ref_key10` '
        'CROSS JOIN `table_name2` ON '
        '`table_name2`.`fkey5` = `ref_table_name8`.`ref_key11` '
        'CROSS JOIN `table_name3` ON '
        '`table_name3`.`fkey6` = `ref_table_name9`.`ref_key12`',
      );
    });

    test('escaping names can be disabled', () {
      final Join join = Join();
      join.addCrossJoin(
        'table_name',
        'fkey',
        'ref_table_name',
        'ref_key',
        escapeNames: false,
      );

      expect(
        join.statement,
        'CROSS JOIN table_name '
        'ON table_name.fkey = ref_table_name.ref_key',
      );
    });
  });

  group('addJoin', () {
    test('multiple different joins can be added', () {
      final Join join = Join();
      join.addCrossJoin('table_name1', 'fkey4', 'ref_table_name7', 'ref_key10');
      join.addLeftJoin('table_name2', 'fkey5', 'ref_table_name8', 'ref_key11');
      join.addInnerJoin('table_name3', 'fkey6', 'ref_table_name9', 'ref_key12');

      expect(
        join.statement,
        'CROSS JOIN `table_name1` ON '
        '`table_name1`.`fkey4` = `ref_table_name7`.`ref_key10` '
        'LEFT JOIN `table_name2` ON '
        '`table_name2`.`fkey5` = `ref_table_name8`.`ref_key11` '
        'INNER JOIN `table_name3` ON '
        '`table_name3`.`fkey6` = `ref_table_name9`.`ref_key12`',
      );
    });
  });
}
