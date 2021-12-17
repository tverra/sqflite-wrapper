import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  late Map<String, dynamic> _map;

  setUp(() {
    _map = <String, dynamic>{'val1': 1, 'val2': 2, 'val3': 3};
  });

  group('constructor', () {
    test('args is initially empty list', () {
      final Insert insert = Insert(
        'table_name',
        <String, dynamic>{},
        nullColumnHack: 'col',
      );
      expect(insert.args, <dynamic>[]);
    });
  });

  group('table', () {
    test('table is given table value', () {
      final Insert insert = Insert('table_name', _map);
      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?)',
      );
    });

    test('table name can be empty string', () {
      final Insert insert = Insert('', _map);
      expect(
        insert.sql,
        'INSERT INTO `` (`val1`, `val2`, `val3`) VALUES (?, ?, ?)',
      );
    });

    test('escaping names can be disabled', () {
      final Insert insert = Insert('table_name', _map, escapeNames: false);
      expect(
        insert.sql,
        'INSERT INTO table_name (val1, val2, val3) VALUES (?, ?, ?)',
      );
    });
  });

  group('values', () {
    test('values are added to query', () {
      final Insert insert = Insert('table_name', _map);

      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?)',
      );
      expect(insert.args, <dynamic>[1, 2, 3]);
    });

    test('values are added if null', () {
      final Insert insert = Insert(
        'table_name',
        <String, dynamic>{'value': null},
      );

      expect(insert.sql, 'INSERT INTO `table_name` (`value`) VALUES (NULL)');
      expect(insert.args, <dynamic>[]);
    });

    test('empty map throws ArgumentError', () {
      expect(
        () {
          Insert('table_name', <String, dynamic>{});
        },
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('nullColumnHack', () {
    test('inserts null-column hack if map is empty', () {
      final Insert insert = Insert(
        'table_name',
        <String, dynamic>{},
        nullColumnHack: 'hack',
      );
      expect(insert.sql, 'INSERT INTO `table_name` (`hack`) VALUES (NULL)');
      expect(insert.args, <dynamic>[]);
    });

    test('does not insert null-column hack if map is not empty', () {
      final Insert insert = Insert(
        'table_name',
        <String, dynamic>{'val': 1},
        nullColumnHack: 'hack',
      );
      expect(insert.sql, 'INSERT INTO `table_name` (`val`) VALUES (?)');
      expect(insert.args, <dynamic>[1]);
    });

    test('escaping names can be disabled', () {
      final Insert insert = Insert(
        'table_name',
        <String, dynamic>{},
        nullColumnHack: 'hack',
        escapeNames: false,
      );
      expect(insert.sql, 'INSERT INTO table_name (hack) VALUES (NULL)');
    });
  });

  group('conflictAlgorithm', () {
    test('does add rollback algorithm if given', () {
      Insert insert = Insert(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      expect(
        insert.sql,
        'INSERT OR ROLLBACK INTO `table_name` (`val1`, `val2`, `val3`) '
        'VALUES (?, ?, ?)',
      );

      insert = Insert(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      expect(
        insert.sql,
        'INSERT OR ABORT INTO `table_name` (`val1`, `val2`, `val3`) '
        'VALUES (?, ?, ?)',
      );

      insert =
          Insert('table_name', _map, conflictAlgorithm: ConflictAlgorithm.fail);
      expect(
        insert.sql,
        'INSERT OR FAIL INTO `table_name` (`val1`, `val2`, `val3`) '
        'VALUES (?, ?, ?)',
      );

      insert = Insert(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      expect(
        insert.sql,
        'INSERT OR IGNORE INTO `table_name` (`val1`, `val2`, `val3`) '
        'VALUES (?, ?, ?)',
      );

      insert = Insert(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      expect(
        insert.sql,
        'INSERT OR REPLACE INTO `table_name` (`val1`, `val2`, `val3`) '
        'VALUES (?, ?, ?)',
      );
    });

    test('conflict algorithm is not added if null', () {
      final Insert insert = Insert('table_name', _map, conflictAlgorithm: null);
      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?)',
      );
    });

    test('escaping names can be disabled', () {
      final Insert insert = Insert(
        'table_name',
        _map,
        conflictAlgorithm: ConflictAlgorithm.rollback,
        escapeNames: false,
      );
      expect(
        insert.sql,
        'INSERT OR ROLLBACK INTO table_name (val1, val2, val3) '
        'VALUES (?, ?, ?)',
      );
    });
  });

  group('rowIdConstraint', () {
    test('does add row id constraint if given', () {
      final Insert insert = Insert(
        'table',
        _map,
        rowIdConstraint: Where(
          col: 'col',
          val: 'val',
        ),
      );

      expect(
        insert.sql,
        'INSERT INTO `table` (`rowid`, `val1`, `val2`, `val3`) VALUES ('
        '(SELECT `rowid` FROM `table` WHERE `col` = ?), ?, ?, ?)',
      );
      expect(insert.args, <dynamic>['val', 1, 2, 3]);
    });

    test('does add row id constraint with multiple conditions', () {
      final Where where = Where();
      where.addIs('col1', 'val1');
      where.addIn(
        'col2',
        <dynamic>['val2', 'val3'],
        combinator: WhereCombinator.or,
      );

      final Insert insert = Insert('table', _map, rowIdConstraint: where);

      expect(
        insert.sql,
        'INSERT INTO `table` (`rowid`, `val1`, `val2`, `val3`) VALUES ('
        '(SELECT `rowid` FROM `table` '
        'WHERE `col1` IS ? OR `col2` IN (?, ?)), ?, ?, ?)',
      );
      expect(insert.args, <dynamic>['val1', 'val2', 'val3', 1, 2, 3]);
    });

    test('table is added to condition', () {
      final Insert insert = Insert(
        'table',
        _map,
        rowIdConstraint: Where(
          table: 'table',
          col: 'col',
          val: 'val',
        ),
      );

      expect(
        insert.sql,
        'INSERT INTO `table` (`rowid`, `val1`, `val2`, `val3`) VALUES ('
        '(SELECT `rowid` FROM `table` WHERE `table`.`col` = ?), ?, ?, ?)',
      );
      expect(insert.args, <dynamic>['val', 1, 2, 3]);
    });

    test('condition with no args is added', () {
      final Insert insert = Insert(
        'table',
        _map,
        rowIdConstraint: Where(col: 'col', not: true),
      );

      expect(
        insert.sql,
        'INSERT INTO `table` (`rowid`, `val1`, `val2`, `val3`) VALUES ('
        '(SELECT `rowid` FROM `table` WHERE `col` IS NOT NULL), ?, ?, ?)',
      );
      expect(insert.args, <dynamic>[1, 2, 3]);
    });

    test('does not add empty constraint', () {
      final Insert insert = Insert(
        'table',
        _map,
        rowIdConstraint: Where(),
      );

      expect(
        insert.sql,
        'INSERT INTO `table` (`val1`, `val2`, `val3`) VALUES (?, ?, ?)',
      );
      expect(insert.args, <dynamic>[1, 2, 3]);
    });

    test('condition is added if map is empty', () {
      final Insert insert = Insert(
        'table',
        <String, dynamic>{},
        rowIdConstraint: Where(
          col: 'col',
          val: 'val',
        ),
      );

      expect(
        insert.sql,
        'INSERT INTO `table` (`rowid`) VALUES ('
        '(SELECT `rowid` FROM `table` WHERE `col` = ?))',
      );
      expect(insert.args, <dynamic>['val']);
    });

    test('escaping names can be disabled', () {
      final Insert insert = Insert(
        'table',
        _map,
        rowIdConstraint: Where(
          col: 'col',
          val: 'val',
          escapeNames: false,
        ),
        escapeNames: false,
      );

      expect(
        insert.sql,
        'INSERT INTO table (rowid, val1, val2, val3) VALUES ('
        '(SELECT rowid FROM table WHERE col = ?), ?, ?, ?)',
      );
      expect(insert.args, <dynamic>['val', 1, 2, 3]);
    });
  });

  group('upsert', () {
    test('error if both conflictAlgorithm and upsertConflictValue has values',
        () {
      expect(
        () {
          Insert(
            'table_name',
            _map,
            conflictAlgorithm: ConflictAlgorithm.replace,
            upsertConflictValues: <String>['col'],
          );
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    test('error if both conflictAlgorithm and upsertAction has values', () {
      expect(
        () {
          Insert(
            'table_name',
            _map,
            conflictAlgorithm: ConflictAlgorithm.replace,
            upsertAction: Update.forUpsert(_map),
          );
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    test('argumentError is thrown if upsertConflictValue is null', () {
      expect(
        () {
          Insert(
            'table_name',
            _map,
            upsertConflictValues: null,
            upsertAction: Update.forUpsert(_map),
          );
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    test('argumentError is thrown if upsertAction is null', () {
      expect(
        () {
          Insert(
            'table_name',
            _map,
            upsertConflictValues: <String>['col'],
            upsertAction: null,
          );
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    test('argumentError is thrown if forUpsert is false', () {
      expect(
        () {
          Insert(
            'table_name',
            _map,
            conflictAlgorithm: ConflictAlgorithm.replace,
            upsertAction: Update('table_name', _map),
          );
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    test('upsert statement is created', () {
      final Update update = Update.forUpsert(_map);
      final Insert insert = Insert(
        'table_name',
        _map,
        upsertConflictValues: <String>['val1'],
        upsertAction: update,
      );

      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?) '
        'ON CONFLICT (`val1`) DO UPDATE SET '
        '`val1` = ?, `val2` = ?, `val3` = ?',
      );
      expect(insert.args, <dynamic>[1, 2, 3, 1, 2, 3]);
    });

    test('upsert statement is created with multiple upsertConflictValues', () {
      final Update update = Update.forUpsert(_map);
      final Insert insert = Insert(
        'table_name',
        _map,
        upsertConflictValues: <String>['val1', 'val2', 'val3'],
        upsertAction: update,
      );

      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?) '
        'ON CONFLICT (`val1`, `val2`, `val3`) '
        'DO UPDATE SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
      expect(insert.args, <dynamic>[1, 2, 3, 1, 2, 3]);
    });

    test('upsert statement is created with no upsertConflictValues', () {
      final Update update = Update.forUpsert(_map);
      final Insert insert = Insert(
        'table_name',
        _map,
        upsertConflictValues: <String>[],
        upsertAction: update,
      );

      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?) '
        'ON CONFLICT () DO UPDATE SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
      expect(insert.args, <dynamic>[1, 2, 3, 1, 2, 3]);
    });

    test('upsert statement is created with where on update', () {
      final Update update = Update.forUpsert(
        _map,
        where: Where(table: 'table', col: 'col', val: 'val'),
      );
      final Insert insert = Insert(
        'table_name',
        _map,
        upsertConflictValues: <String>['val1'],
        upsertAction: update,
      );

      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?) '
        'ON CONFLICT (`val1`) DO UPDATE SET '
        '`val1` = ?, `val2` = ?, `val3` = ? '
        'WHERE `table`.`col` = ?',
      );
      expect(insert.args, <dynamic>[1, 2, 3, 1, 2, 3, 'val']);
    });

    test('upsert statement is created with conflict algorithm on update', () {
      final Update update = Update.forUpsert(
        _map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final Insert insert = Insert(
        'table_name',
        _map,
        upsertConflictValues: <String>['val1'],
        upsertAction: update,
      );

      expect(
        insert.sql,
        'INSERT INTO `table_name` (`val1`, `val2`, `val3`) VALUES (?, ?, ?) '
        'ON CONFLICT (`val1`) DO UPDATE OR REPLACE '
        'SET `val1` = ?, `val2` = ?, `val3` = ?',
      );
      expect(insert.args, <dynamic>[1, 2, 3, 1, 2, 3]);
    });

    test('escaping names can be disabled', () {
      final Update update = Update.forUpsert(_map, escapeNames: false);
      final Insert insert = Insert(
        'table_name',
        _map,
        upsertConflictValues: <String>['val1'],
        upsertAction: update,
        escapeNames: false,
      );

      expect(
        insert.sql,
        'INSERT INTO table_name (val1, val2, val3) VALUES (?, ?, ?) '
        'ON CONFLICT (val1) DO UPDATE SET '
        'val1 = ?, val2 = ?, val3 = ?',
      );
    });
  });
}
