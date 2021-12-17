import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('numberOfConditions is initially zero', () {
      final Where where = Where();
      expect(where.numberOfConditions, 0);
    });

    test('increments the number of conditions', () {
      final Where where = Where(col: 'col', val: 'val');

      expect(where.numberOfConditions, 1);
    });

    test('statement and args are initially empty string and list', () {
      final Where where = Where();

      expect(where.statement, '');
      expect(where.args, <dynamic>[]);
    });

    test('args is empty list if null value is added to statement', () {
      final Where where = Where();
      where.addIs('column', null);

      expect(where.args, <dynamic>[]);
    });

    test('addEquals is default in constructor if type is null', () {
      final Where where = Where(col: 'col', val: 'val', type: null);
      expect(where.statement, '`col` = ?');
      expect(where.args, <dynamic>['val']);
    });

    test('addIs is default in constructor if opts is null and value is null',
        () {
      final Where where = Where(col: 'col', val: null);
      expect(where.statement, '`col` IS NULL');
      expect(where.args, <dynamic>[]);
    });

    test('table name can be added in constructor', () {
      final Where where = Where(table: 'table_name', col: 'col', val: 'val');
      expect(where.statement, '`table_name`.`col` = ?');
      expect(where.args, <dynamic>['val']);
    });

    test('col is asserted not null', () {
      expect(() {
        Where(col: null, val: 1);
      }, throwsA(isA<AssertionError>()));
    });

    test('escaping names can be disabled', () {
      final Where where = Where(
        table: 'table_name',
        col: 'col',
        val: 'val',
        escapeNames: false,
      );
      expect(where.statement, 'table_name.col = ?');
      expect(where.args, <dynamic>['val']);
    });
  });

  group('addEquals', () {
    test('adds "equals"-condition', () {
      final Where where = Where();
      where.addEquals('column', 'value');
      expect(where.statement, '`column` = ?');
      expect(where.args, <dynamic>['value']);
    });

    test('adds "not equals"-condition when not is true', () {
      final Where where = Where();
      where.addEquals('column', 'value', not: true);
      expect(where.statement, '`column` != ?');
      expect(where.args, <dynamic>['value']);
    });

    test('with "OR"-option adds "OR"-condition', () {
      final Where where = Where();
      where.addEquals('column', 'value1');
      where.addEquals('column', 'value2', combinator: WhereCombinator.or);
      expect(where.statement, '`column` = ? OR `column` = ?');
      expect(where.args, <dynamic>['value1', 'value2']);
    });

    test('add multiple equals options', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        where.addEquals('col$i', i);
      }

      expect(where.statement,
          '`col1` = ? AND `col2` = ? AND `col3` = ? AND `col4` = ?');
      expect(where.args, <dynamic>[1, 2, 3, 4]);
    });

    test('equals condition can be added in constructor', () {
      final Where where = Where(col: 'column', val: 'value');
      expect(where.statement, '`column` = ?');
      expect(where.args, <dynamic>['value']);
    });

    test('addEquals with null value returns "correct" null syntax', () {
      final Where where = Where();
      where.addEquals('column', null);

      expect(where.statement, '`column` = NULL');
      expect(where.args, <dynamic>[]);
    });

    test('increments the number of conditions', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        where.addEquals('col$i', <dynamic>[i]);
      }
      expect(where.numberOfConditions, 4);
    });

    test('table name can be added in constructor', () {
      final Where where = Where();
      where.addEquals('col', 'val', table: 'table_name');
      expect(where.statement, '`table_name`.`col` = ?');
      expect(where.args, <dynamic>['val']);
    });

    test('escaping names can be disabled', () {
      final Where where = Where();
      where.addEquals('col', 'val', table: 'table_name', escapeNames: false);
      expect(where.statement, 'table_name.col = ?');
      expect(where.args, <dynamic>['val']);
    });
  });

  group('addIn', () {
    test('adds "IN"-condition', () {
      final Where where = Where();
      where.addIn('column', <dynamic>['value']);
      expect(where.statement, '`column` IN (?)');
      expect(where.args, <dynamic>['value']);
    });

    test('adds "NOT IN"-condition if not is true', () {
      final Where where = Where();
      where.addIn('column', <dynamic>['value'], not: true);
      expect(where.statement, '`column` NOT IN (?)');
      expect(where.args, <dynamic>['value']);
    });

    test('with "OR"-option adds "OR"-condition', () {
      final Where where = Where();
      where.addIn('column', <String>['value1']);
      where.addIn('column', <String>['value2'], combinator: WhereCombinator.or);
      expect(where.statement, '`column` IN (?) OR `column` IN (?)');
      expect(where.args, <dynamic>['value1', 'value2']);
    });

    test('with null value returns valid null syntax', () {
      final Where where = Where();
      where.addIn('column', <dynamic>[null]);

      expect(where.statement, '`column` IN (NULL)');
      expect(where.args, <dynamic>[]);
    });

    test('add multiple "IN"-options', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        where.addIn('col$i', <dynamic>[i]);
      }

      expect(
          where.statement,
          '`col1` IN (?) AND `col2` IN (?) '
          'AND `col3` IN (?) AND `col4` IN (?)');
      expect(where.args, <dynamic>[1, 2, 3, 4]);
    });

    test('adding list of values in "IN"-options', () {
      final Where where = Where();
      where.addIn('column', <dynamic>[1, 2, 3, 4, 5]);

      expect(where.statement, '`column` IN (?, ?, ?, ?, ?)');
      expect(where.args, <dynamic>[1, 2, 3, 4, 5]);
    });

    test('increments the number of conditions', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        where.addIn('col$i', <dynamic>[i]);
      }
      expect(where.numberOfConditions, 4);
    });

    test('"IN"-condition can be added in constructor', () {
      final Where where =
          Where(col: 'column', val: <dynamic>['value'], type: WhereType.sqfIn);
      expect(where.statement, '`column` IN (?)');
      expect(where.args, <dynamic>['value']);
    });

    test('table name can be added in constructor', () {
      final Where where = Where();
      where.addIn('col', <dynamic>['val'], table: 'table_name');
      expect(where.statement, '`table_name`.`col` IN (?)');
      expect(where.args, <dynamic>['val']);
    });

    test('escaping names can be disabled', () {
      final Where where = Where();
      where.addIn(
        'col',
        <dynamic>['val'],
        table: 'table_name',
        escapeNames: false,
      );
      expect(where.statement, 'table_name.col IN (?)');
      expect(where.args, <dynamic>['val']);
    });
  });

  group('addSubQuery', () {
    test('adds "IN"-condition with subquery', () {
      final Where where = Where();
      final Query query = Query('table', where: Where(col: 'value', val: 1));
      where.addSubQuery('column', query);
      expect(where.statement,
          '`column` IN (SELECT `table`.* FROM `table` WHERE `value` = ?)');
      expect(where.args, <dynamic>[1]);
    });

    test('adds "NOT IN"-condition if not is true', () {
      final Where where = Where();
      final Query query = Query('table', where: Where(col: 'value', val: '1'));
      where.addSubQuery('column', query, not: true);
      expect(where.statement,
          '`column` NOT IN (SELECT `table`.* FROM `table` WHERE `value` = ?)');
      expect(where.args, <dynamic>['1']);
    });

    test('with "OR"-option adds "OR"-condition', () {
      final Where where = Where();
      where.addSubQuery(
          'column1', Query('table', where: Where(col: 'value', val: 1)));
      where.addSubQuery(
          'column2', Query('table', where: Where(col: 'value', val: 2)),
          combinator: WhereCombinator.or);
      expect(
          where.statement,
          '`column1` IN (SELECT `table`.* FROM `table` WHERE `value` = ?) OR '
          '`column2` IN (SELECT `table`.* FROM `table` WHERE `value` = ?)');
      expect(where.args, <dynamic>[1, 2]);
    });

    test('add multiple "IN"-options with sub-queries', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        final Query query = Query('table$i', where: Where(col: 'id', val: i));
        where.addSubQuery('col$i', query);
      }

      expect(
          where.statement,
          '`col1` IN (SELECT `table1`.* FROM `table1` WHERE `id` = ?) AND '
          '`col2` IN (SELECT `table2`.* FROM `table2` WHERE `id` = ?) AND '
          '`col3` IN (SELECT `table3`.* FROM `table3` WHERE `id` = ?) AND '
          '`col4` IN (SELECT `table4`.* FROM `table4` WHERE `id` = ?)');
      expect(where.args, <dynamic>[1, 2, 3, 4]);
    });

    test('adding list of values in sub-query-args', () {
      final Where where = Where();
      final Where subWhere = Where();
      subWhere.addEquals('a', 1);
      subWhere.addEquals('b', 2);
      subWhere.addEquals('c', 3);
      subWhere.addEquals('d', 4);
      subWhere.addEquals('e', 5);

      final Query query = Query('table', where: subWhere);
      where.addSubQuery('column', query);

      expect(
          where.statement,
          '`column` IN (SELECT `table`.* FROM `table` '
          'WHERE `a` = ? AND `b` = ? AND `c` = ? AND `d` = ? AND `e` = ?)');
      expect(where.args, <dynamic>[1, 2, 3, 4, 5]);
    });

    test('increments the number of conditions', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        final Query query =
            Query('table$i', where: Where(col: 'value', val: i));
        where.addSubQuery('col$i', query);
      }
      expect(where.numberOfConditions, 4);
    });

    test('table name can be added in constructor', () {
      final Where where = Where();
      final Query query = Query('table',
          where: Where(col: 'col', val: 'val', table: 'table_name'));
      where.addSubQuery('column', query);

      expect(
          where.statement,
          '`column` IN (SELECT `table`.* FROM `table` '
          'WHERE `table_name`.`col` = ?)');
      expect(where.args, <dynamic>['val']);
    });

    test('escaping names can be disabled', () {
      final Where where = Where();
      final Query query = Query(
        'table',
        escapeNames: false,
        where: Where(
          col: 'col',
          val: 'val',
          table: 'table_name',
          escapeNames: false,
        ),
      );
      where.addSubQuery('column', query, escapeNames: false);

      expect(
          where.statement,
          'column IN (SELECT table.* FROM table '
          'WHERE table_name.col = ?)');
      expect(where.args, <dynamic>['val']);
    });
  });

  group('addIs', () {
    test('adds "IS"-condition', () {
      final Where where = Where();
      where.addIs('column', 'value');
      expect(where.statement, '`column` IS ?');
      expect(where.args, <dynamic>['value']);
    });

    test('adds "NOT IS"-condition if not is true', () {
      final Where where = Where();
      where.addIs('column', 'value', not: true);
      expect(where.statement, '`column` IS NOT ?');
      expect(where.args, <dynamic>['value']);
    });

    test('with "OR"-option adds "OR"-condition', () {
      final Where where = Where();
      where.addIs('column', 'value1');
      where.addIs('column', 'value2', combinator: WhereCombinator.or);
      expect(where.statement, '`column` IS ? OR `column` IS ?');
      expect(where.args, <dynamic>['value1', 'value2']);
    });

    test('add multiple "IS"-options', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        where.addIs('col$i', i);
      }

      expect(where.statement,
          '`col1` IS ? AND `col2` IS ? AND `col3` IS ? AND `col4` IS ?');
      expect(where.args, <dynamic>[1, 2, 3, 4]);
    });

    test('increments the number of conditions', () {
      final Where where = Where();

      for (int i = 1; i <= 4; i++) {
        where.addIs('col$i', i);
      }
      expect(where.numberOfConditions, 4);
    });

    test('"IS"-condition can be added in constructor', () {
      final Where where =
          Where(col: 'column', val: 'value', type: WhereType.sqfIs);
      expect(where.statement, '`column` IS ?');
      expect(where.args, <dynamic>['value']);
    });

    test('value in constructor can be null', () {
      final Where where = Where(col: 'column', val: null);

      expect(where.statement, '`column` IS NULL');
      expect(where.args, <dynamic>[]);
    });

    test('table name can be added in constructor', () {
      final Where where = Where();
      where.addIs('col', 'val', table: 'table_name');
      expect(where.statement, '`table_name`.`col` IS ?');
      expect(where.args, <dynamic>['val']);
    });

    test('escaping names can be disabled', () {
      final Where where = Where();
      where.addIs('col', 'val', table: 'table_name', escapeNames: false);
      expect(where.statement, 'table_name.col IS ?');
      expect(where.args, <dynamic>['val']);
    });
  });

  group('combine', () {
    test('two where statements are combined', () {
      final Where firstWhere = Where(table: 'table1', col: 'col', val: 1);
      final Where secondWhere = Where(table: 'table2', col: 'col', val: 2);
      firstWhere.combine(secondWhere);

      expect(firstWhere.statement, '`table1`.`col` = ? AND `table2`.`col` = ?');
      expect(firstWhere.args, <dynamic>[1, 2]);
    });

    test('three where statements are combined', () {
      final Where firstWhere = Where(table: 'table1', col: 'col', val: 1);
      final Where secondWhere = Where(table: 'table2', col: 'col', val: 2);
      final Where thirdWhere = Where(table: 'table3', col: 'col', val: 3);
      firstWhere.combine(secondWhere);
      firstWhere.combine(thirdWhere);

      expect(firstWhere.statement,
          '`table1`.`col` = ? AND `table2`.`col` = ? AND `table3`.`col` = ?');
      expect(firstWhere.args, <dynamic>[1, 2, 3]);
    });

    test('combined statement is unchanged if second statement is empty', () {
      final Where firstWhere = Where(table: 'table1', col: 'col', val: 1);
      final Where secondWhere = Where();
      firstWhere.combine(secondWhere);

      expect(firstWhere.statement, '`table1`.`col` = ?');
      expect(firstWhere.args, <dynamic>[1]);
    });

    test('explicit combined AND statements', () {
      final Where firstWhere = Where(table: 'table1', col: 'col', val: 1);
      final Where secondWhere = Where(table: 'table2', col: 'col', val: 2);
      firstWhere.combine(secondWhere, combinator: WhereCombinator.and);

      expect(firstWhere.statement, '`table1`.`col` = ? AND `table2`.`col` = ?');
      expect(firstWhere.args, <dynamic>[1, 2]);
    });

    test('combined OR statements', () {
      final Where firstWhere = Where(table: 'table1', col: 'col', val: 1);
      final Where secondWhere = Where(table: 'table2', col: 'col', val: 2);
      firstWhere.combine(secondWhere, combinator: WhereCombinator.or);

      expect(firstWhere.statement, '`table1`.`col` = ? OR `table2`.`col` = ?');
      expect(firstWhere.args, <dynamic>[1, 2]);
    });

    test('statement can be combined into empty statement', () {
      final Where firstWhere = Where();
      final Where secondWhere = Where(table: 'table2', col: 'col', val: 2);
      firstWhere.combine(secondWhere, combinator: WhereCombinator.and);

      expect(firstWhere.statement, '`table2`.`col` = ?');
      expect(firstWhere.args, <dynamic>[2]);
    });

    test('statements with multiple clauses can be combined', () {
      final Where firstWhere = Where();
      firstWhere.addIn('col1', <dynamic>[1, 2, 3], table: 'table');
      firstWhere.addIs('col2', 4, table: 'table', not: true);
      final Where secondWhere = Where();
      secondWhere.addEquals('col3', 5, table: 'table');
      secondWhere.add('col4', '>', 6,
          table: 'table', combinator: WhereCombinator.or);

      firstWhere.combine(secondWhere, combinator: WhereCombinator.and);
      expect(
          firstWhere.statement,
          '`table`.`col1` IN (?, ?, ?) AND `table`.`col2` IS NOT ? '
          'AND `table`.`col3` = ? OR `table`.`col4` > ?');
      expect(firstWhere.args, <dynamic>[1, 2, 3, 4, 5, 6]);
    });

    test('second statement is unchanged', () {
      final Where firstWhere = Where(table: 'table1', col: 'col', val: 1);
      final Where secondWhere = Where(table: 'table2', col: 'col', val: 2);
      firstWhere.combine(secondWhere);

      expect(secondWhere.statement, '`table2`.`col` = ?');
      expect(secondWhere.args, <dynamic>[2]);
    });

    test('statements with no args can be combined', () {
      final Where firstWhere =
          Where(table: 'table1', col: 'col', val: null, type: WhereType.sqfIs);
      final Where secondWhere =
          Where(table: 'table2', col: 'col', val: null, type: WhereType.sqfIs);
      firstWhere.combine(secondWhere);

      expect(firstWhere.statement,
          '`table1`.`col` IS NULL AND `table2`.`col` IS NULL');
      expect(firstWhere.args, <dynamic>[]);
    });

    test('number of statements is correct in merged statement', () {
      final Where firstWhere = Where();
      firstWhere.addIn('col1', <dynamic>[1, 2, 3], table: 'table');
      firstWhere.addIs('col2', 4, table: 'table', not: true);
      final Where secondWhere = Where();
      secondWhere.addEquals('col3', 5, table: 'table');
      secondWhere.add('col4', '>', 6,
          table: 'table', combinator: WhereCombinator.or);

      firstWhere.combine(secondWhere, combinator: WhereCombinator.and);
      expect(firstWhere.numberOfConditions, 4);
    });
  });

  group('Where', () {
    test('multiple different types of conditions can be added', () {
      final Where where = Where(
          col: 'col1',
          val: <dynamic>[null, 1],
          type: WhereType.sqfIn,
          not: true);

      where.addEquals('col2', 0, combinator: WhereCombinator.or);
      where.addIs('col3', 2);

      expect(where.statement,
          '`col1` NOT IN (NULL, ?) OR `col2` = ? AND `col3` IS ?');
      expect(where.args, <dynamic>[1, 0, 2]);
      expect(where.numberOfConditions, 3);
    });
  });
}
