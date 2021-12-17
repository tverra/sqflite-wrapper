import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('args is initially empty list', () {
      final Query query = Query('');
      expect(query.args, <dynamic>[]);
    });
  });

  group('table', () {
    test('table is given table value', () {
      final Query query = Query('table_name');
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('table name can be empty string', () {
      final Query query = Query('');
      expect(query.sql, 'SELECT ``.* FROM ``');
    });

    test('escaping names can be disabled', () {
      final Query query = Query('table_name', escapeNames: false);
      expect(query.sql, 'SELECT table_name.* FROM table_name');
    });
  });

  group('distinct', () {
    test('distinct is added if true', () {
      final Query query = Query('table_name', distinct: true);
      expect(query.sql, 'SELECT DISTINCT `table_name`.* FROM `table_name`');
    });

    test('distinct is not added if false', () {
      final Query query = Query('table_name', distinct: false);
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('escaping names can be disabled', () {
      final Query query =
          Query('table_name', distinct: true, escapeNames: false);
      expect(query.sql, 'SELECT DISTINCT table_name.* FROM table_name');
    });
  });

  group('columns', () {
    test('all columns are selected if not given', () {
      final Query query = Query('table_name');
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('no columns are selected if columns is empty list', () {
      final Query query = Query('table_name', columns: <String>[]);
      expect(query.sql, 'SELECT FROM `table_name`');
    });

    test('single column is selected if given', () {
      final Query query = Query('table_name', columns: <String>['col']);
      expect(query.sql, 'SELECT `table_name`.`col` FROM `table_name`');
    });

    test('multiple columns are selected if given', () {
      final Query query =
          Query('table_name', columns: <String>['col1', 'col2', 'col3']);
      expect(
        query.sql,
        'SELECT `table_name`.`col1`, `table_name`.`col2`, `table_name`.`col3` '
        'FROM `table_name`',
      );
    });

    test('escaping names can be disabled', () {
      final Query query = Query(
        'table_name',
        columns: <String>['col1', 'col2', 'col3'],
        escapeNames: false,
      );
      expect(
        query.sql,
        'SELECT table_name.col1, table_name.col2, table_name.col3 '
        'FROM table_name',
      );
    });
  });

  group('functions', () {
    test('no functions are added if functions is empty list', () {
      final Query query = Query('table_name', functions: <SqfFunction>[]);
      expect(query.sql, 'SELECT FROM `table_name`');
    });

    test('single function is added if given', () {
      final Query query =
          Query('table_name', functions: <SqfFunction>[SqfFunction.min('col')]);
      expect(query.sql, 'SELECT MIN(`col`) FROM `table_name`');
    });

    test('multiple columns are selected if given', () {
      final Query query = Query(
        'table_name',
        functions: <SqfFunction>[
          SqfFunction.min('col1'),
          SqfFunction.max('col2'),
        ],
      );
      expect(query.sql, 'SELECT MIN(`col1`), MAX(`col2`) FROM `table_name`');
    });

    test('both columns and functions are added', () {
      final Query query = Query(
        'table_name',
        columns: <String>['col1', 'col2', 'col3'],
        functions: <SqfFunction>[
          SqfFunction.min('col1', alias: 'val1'),
          SqfFunction.max('col2', alias: 'val2'),
        ],
      );
      expect(
        query.sql,
        'SELECT MIN(`col1`) AS `val1`, MAX(`col2`) AS `val2`, '
        '`table_name`.`col1`, `table_name`.`col2`, `table_name`.`col3` '
        'FROM `table_name`',
      );
    });
  });

  group('where', () {
    test('is added to query', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      final Query query = Query('table_name', where: where);

      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'WHERE `table_name`.`col` = ?',
      );
      expect(query.args, <dynamic>['val']);
    });

    test('multiple where conditions is added to query', () {
      final Where where = Where(table: 'table_name', col: 'col1', val: 'val1');
      where.addIs('col2', 'val2', combinator: WhereCombinator.or);
      final Query query = Query('table_name', where: where);

      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'WHERE `table_name`.`col1` = ? OR `col2` IS ?',
      );
      expect(query.args, <dynamic>['val1', 'val2']);
    });

    test('without args is added to query', () {
      final Where where = Where(
        table: 'table_name',
        col: 'col',
        val: null,
        type: WhereType.sqfIs,
      );
      final Query query = Query('table_name', where: where);

      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'WHERE `table_name`.`col` IS NULL',
      );
      expect(query.args, <dynamic>[]);
    });

    test('multiple columns can be added', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      final Query query =
          Query('table_name', columns: <String>['col1', 'col2'], where: where);

      expect(
        query.sql,
        'SELECT `table_name`.`col1`, `table_name`.`col2` FROM `table_name` '
        'WHERE `table_name`.`col` = ?',
      );
      expect(query.args, <dynamic>['val']);
    });

    test('empty where is not added', () {
      final Where where = Where();
      final Query query = Query('table_name', where: where);

      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
      expect(query.args, <dynamic>[]);
    });
  });

  group('preload', () {
    test('is added to query', () {
      final Preload preload = Preload(
        parentTable: 'parent',
        parentFKey: 'pfkey',
        childTable: 'child',
        childKey: 'ckey',
        parentColumns: <String>['col1', 'col2', 'col3'],
      );
      final Query query = Query('child', preload: preload);

      expect(
        query.sql,
        'SELECT `child`.*, '
        '`parent`.`col1` AS `_parent_col1`, '
        '`parent`.`col2` AS `_parent_col2`, '
        '`parent`.`col3` AS `_parent_col3` '
        'FROM `child` LEFT JOIN `parent` ON `parent`.`pfkey` = `child`.`ckey`',
      );
    });

    test('multiple preloads are added to query', () {
      final Preload preload = Preload(
        parentTable: 'parent1',
        parentFKey: 'pfkey',
        childTable: 'child',
        childKey: 'ckey',
        parentColumns: <String>['col'],
      );
      preload.add('parent2', 'pfkey', 'child', 'ckey', <String>['col']);
      final Query query = Query('child', preload: preload);

      expect(
        query.sql,
        'SELECT `child`.*, '
        '`parent1`.`col` AS `_parent1_col`, '
        '`parent2`.`col` AS `_parent2_col` '
        'FROM `child` '
        'LEFT JOIN `parent1` ON `parent1`.`pfkey` = `child`.`ckey` '
        'LEFT JOIN `parent2` ON `parent2`.`pfkey` = `child`.`ckey`',
      );
    });

    test('empty preload is not added', () {
      final Preload preload = Preload();
      final Query query = Query('child', preload: preload);

      expect(query.sql, 'SELECT `child`.* FROM `child`');
    });

    test('multiple columns can be added', () {
      final Preload preload = Preload(
        parentTable: 'parent',
        parentFKey: 'pfkey',
        childTable: 'child',
        childKey: 'ckey',
        parentColumns: <String>['col1', 'col2', 'col3'],
      );
      final Query query =
          Query('child', columns: <String>['col1', 'col2'], preload: preload);

      expect(
        query.sql,
        'SELECT `child`.`col1`, `child`.`col2`, '
        '`parent`.`col1` AS `_parent_col1`, '
        '`parent`.`col2` AS `_parent_col2`, '
        '`parent`.`col3` AS `_parent_col3` '
        'FROM `child` LEFT JOIN `parent` ON `parent`.`pfkey` = `child`.`ckey`',
      );
    });

    test('where can be added after preload', () {
      final Preload preload = Preload(
        parentTable: 'parent',
        parentFKey: 'pfkey',
        childTable: 'child',
        childKey: 'ckey',
        parentColumns: <String>['col1'],
      );
      final Where where = Where(table: 'child', col: 'ckey', val: 'val');
      final Query query = Query('child', where: where, preload: preload);

      expect(
        query.sql,
        'SELECT `child`.*, '
        '`parent`.`col1` AS `_parent_col1` '
        'FROM `child` LEFT JOIN `parent` ON `parent`.`pfkey` = `child`.`ckey` '
        'WHERE `child`.`ckey` = ?',
      );
      expect(query.args, <String>['val']);
    });
  });

  group('join', () {
    test('is added to query', () {
      final Join join = Join(
        tableName: 'parent',
        fKey: 'pfkey',
        refTableName: 'child',
        refKey: 'ckey',
      );
      final Query query = Query('child', join: join);

      expect(
        query.sql,
        'SELECT `child`.* FROM `child` '
        'LEFT JOIN `parent` ON `parent`.`pfkey` = `child`.`ckey`',
      );
    });

    test('multiple joins are added to query', () {
      final Join join = Join(
        tableName: 'parent1',
        fKey: 'pfkey',
        refTableName: 'child',
        refKey: 'ckey',
      );
      join.addCrossJoin('parent2', 'pfkey', 'child', 'ckey');

      final Query query = Query('child', join: join);

      expect(
        query.sql,
        'SELECT `child`.* FROM `child` '
        'LEFT JOIN `parent1` ON `parent1`.`pfkey` = `child`.`ckey` '
        'CROSS JOIN `parent2` ON `parent2`.`pfkey` = `child`.`ckey`',
      );
    });

    test('empty join is not added', () {
      final Join join = Join();
      final Query query = Query('child', join: join);

      expect(query.sql, 'SELECT `child`.* FROM `child`');
    });

    test('preloads and joins can be added', () {
      final Preload preload = Preload(
        parentTable: 'parent1',
        parentFKey: 'pfkey',
        childTable: 'child',
        childKey: 'ckey',
        parentColumns: <String>['col1', 'col2', 'col3'],
      );
      final Join join = Join(
        tableName: 'parent2',
        fKey: 'pfkey',
        refTableName: 'child',
        refKey: 'ckey',
        type: JoinType.innerJoin,
      );
      final Query query = Query('child', preload: preload, join: join);

      expect(
        query.sql,
        'SELECT `child`.*, '
        '`parent1`.`col1` AS `_parent1_col1`, '
        '`parent1`.`col2` AS `_parent1_col2`, '
        '`parent1`.`col3` AS `_parent1_col3` '
        'FROM `child` '
        'LEFT JOIN `parent1` ON `parent1`.`pfkey` = `child`.`ckey` '
        'INNER JOIN `parent2` ON `parent2`.`pfkey` = `child`.`ckey`',
      );
    });

    test('where can be added after join', () {
      final Join join = Join(
        tableName: 'parent',
        fKey: 'pfkey',
        refTableName: 'child',
        refKey: 'ckey',
      );
      final Where where = Where(table: 'child', col: 'ckey', val: 'val');
      final Query query = Query('child', where: where, join: join);

      expect(
        query.sql,
        'SELECT `child`.* FROM `child` '
        'LEFT JOIN `parent` ON `parent`.`pfkey` = `child`.`ckey` '
        'WHERE `child`.`ckey` = ?',
      );
      expect(query.args, <String>['val']);
    });
  });

  group('groupBy', () {
    test('is added to query', () {
      final Query query = Query('table_name', groupBy: <String>['col']);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` GROUP BY `col`',
      );
    });

    test('multiple columns is added to query', () {
      final Query query =
          Query('table_name', groupBy: <String>['col1', 'col2', 'col3']);
      expect(
        query.sql,
        'SELECT `table_name`.* '
        'FROM `table_name` GROUP BY `col1`, `col2`, `col3`',
      );
    });

    test('is not added if null', () {
      final Query query = Query('table_name', groupBy: null);
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('is not added if empty list', () {
      final Query query = Query('table_name', groupBy: <String>[]);
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('can be added after where', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      final Query query =
          Query('table_name', where: where, groupBy: <String>['col']);

      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'WHERE `table_name`.`col` = ? '
        'GROUP BY `col`',
      );
      expect(query.args, <String>['val']);
    });

    test('escaping names can be disabled', () {
      final Query query = Query(
        'table_name',
        groupBy: <String>['col1', 'col2'],
        escapeNames: false,
      );
      expect(
        query.sql,
        'SELECT table_name.* FROM table_name GROUP BY col1, col2',
      );
    });
  });

  group('having', () {
    test('throws argument error if groupBy is null', () {
      expect(
        () {
          Query('table_name', having: 'COUNT(`table_name`.`col`) > val');
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    test('is added to query', () {
      final Query query = Query(
        'table_name',
        groupBy: <String>['col'],
        having: 'COUNT(`table_name`.`col`) > `val`',
      );
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'GROUP BY `col` '
        'HAVING COUNT(`table_name`.`col`) > `val`',
      );
    });

    test('can be empty string', () {
      final Query query =
          Query('table_name', groupBy: <String>['col'], having: '');
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'GROUP BY `col` '
        'HAVING ',
      );
    });

    test('is not added if null', () {
      final Query query = Query(
        'table_name',
        groupBy: <String>['col'],
        having: null,
      );
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` GROUP BY `col`',
      );
    });
  });

  group('orderBy', () {
    test('is added to query', () {
      final OrderBy orderBy =
          OrderBy(table: 'table_name', col: 'col', orderType: OrderType.asc);
      final Query query = Query('table_name', orderBy: orderBy);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'ORDER BY `table_name`.`col` ASC',
      );
    });

    test('multiple orderings is added to query', () {
      final OrderBy orderBy =
          OrderBy(table: 'table_name', col: 'col1', orderType: OrderType.asc);
      orderBy.orderBy('col2', OrderType.desc);

      final Query query = Query('table_name', orderBy: orderBy);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'ORDER BY `table_name`.`col1` ASC, `col2` DESC',
      );
    });

    test('is not added if null', () {
      final Query query = Query('table_name', orderBy: null);
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('is not added if empty', () {
      final OrderBy orderBy = OrderBy();
      final Query query = Query('table_name', orderBy: orderBy);
      expect(query.sql, 'SELECT `table_name`.* FROM `table_name`');
    });

    test('can be added after having', () {
      final OrderBy orderBy =
          OrderBy(table: 'table_name', col: 'col', orderType: OrderType.asc);

      final Query query = Query(
        'table_name',
        groupBy: <String>['col'],
        having: 'COUNT(`table_name`.`col`) > `val`',
        orderBy: orderBy,
      );
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'GROUP BY `col` '
        'HAVING COUNT(`table_name`.`col`) > `val` '
        'ORDER BY `table_name`.`col` ASC',
      );
    });
  });

  group('limit', () {
    test('is added to query', () {
      final Query query = Query('table_name', limit: 40);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` LIMIT 40',
      );
    });

    test('is not added if null', () {
      final Query query = Query('table_name', limit: null);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name`',
      );
    });

    test('can be added after order by', () {
      final OrderBy orderBy =
          OrderBy(table: 'table_name', col: 'col', orderType: OrderType.asc);

      final Query query = Query('table_name', orderBy: orderBy, limit: 0);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` '
        'ORDER BY `table_name`.`col` ASC LIMIT 0',
      );
    });
  });

  group('offset', () {
    test('is added to query', () {
      final Query query = Query('table_name', offset: 40);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` OFFSET 40',
      );
    });

    test('is not added if null', () {
      final Query query = Query('table_name', offset: null);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name`',
      );
    });

    test('can be added after limit', () {
      final Query query = Query('table_name', limit: -1, offset: 0);
      expect(
        query.sql,
        'SELECT `table_name`.* FROM `table_name` LIMIT -1 OFFSET 0',
      );
    });
  });

  group('query', () {
    test('all parameters can be set', () {
      final Query query = Query(
        'table',
        distinct: true,
        columns: <String>['col1', 'col2', 'col3'],
        where: Where(
          table: 'table',
          col: 'col1',
          val: 1,
        ),
        preload: Preload(
          parentTable: 'parent1',
          parentFKey: 'pfkey',
          childTable: 'table',
          childKey: 'ckey',
          parentColumns: <String>['pcol1', 'pcol2', 'pcol3'],
        ),
        join: Join(
          tableName: 'table',
          fKey: 'fkey',
          refTableName: 'parent2',
          refKey: 'pfkey',
        ),
        groupBy: <String>['col1'],
        having: 'COUNT(`table_name`.`col`) > 10',
        orderBy: OrderBy(
          table: 'table',
          col: 'col1',
          orderType: OrderType.desc,
        ),
        limit: 10,
        offset: 5,
      );

      expect(
        query.sql,
        'SELECT DISTINCT `table`.`col1`, `table`.`col2`, `table`.`col3`, '
        '`parent1`.`pcol1` AS `_parent1_pcol1`, '
        '`parent1`.`pcol2` AS `_parent1_pcol2`, '
        '`parent1`.`pcol3` AS `_parent1_pcol3` '
        'FROM `table` '
        'LEFT JOIN `parent1` ON `parent1`.`pfkey` = `table`.`ckey` '
        'LEFT JOIN `table` ON `table`.`fkey` = `parent2`.`pfkey` '
        'WHERE `table`.`col1` = ? '
        'GROUP BY `col1` '
        'HAVING COUNT(`table_name`.`col`) > 10 '
        'ORDER BY `table`.`col1` DESC '
        'LIMIT 10 '
        'OFFSET 5',
      );
      expect(query.args, <dynamic>[1]);
    });
  });
}
