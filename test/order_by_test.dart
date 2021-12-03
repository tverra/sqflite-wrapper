import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('ordering is added', () {
      final OrderBy orderBy = OrderBy(col: 'col', orderType: OrderType.desc);
      expect(orderBy.sql, '`col` DESC');
    });

    test('sql is initially empty string', () {
      final OrderBy orderBy = OrderBy();
      expect(orderBy.sql, '');
    });

    test('number of orderings is initially zero', () {
      final OrderBy orderBy = OrderBy();
      expect(orderBy.numberOfOrderings, 0);
    });

    test('hasClause is initially false', () {
      final OrderBy orderBy = OrderBy();
      expect(orderBy.hasClause(), false);
    });

    test('number of orderings is incremented if ordering is added', () {
      final OrderBy orderBy =
          OrderBy(table: 'table', col: 'col', orderType: OrderType.asc);
      expect(orderBy.numberOfOrderings, 1);
    });

    test('hasClause is true if ordering is added', () {
      final OrderBy orderBy =
          OrderBy(table: 'table', col: 'col', orderType: OrderType.desc);
      expect(orderBy.hasClause(), true);
    });

    test('col is asserted not null', () {
      expect(() {
        OrderBy(table: 'table', orderType: OrderType.asc);
      }, throwsA(isA<AssertionError>()));
    });

    test('order type is asserted not null', () {
      expect(() {
        OrderBy(table: 'table', col: 'col');
      }, throwsA(isA<AssertionError>()));
    });

    test('table name is optional', () {
      final OrderBy orderBy =
          OrderBy(table: 'table', col: 'col', orderType: OrderType.desc);
      expect(orderBy.sql, '`table`.`col` DESC');
    });

    test('null order is inverted if order type is ascending', () {
      final OrderBy orderBy =
          OrderBy(col: 'col', orderType: OrderType.asc, invertNullOrder: true);
      expect(orderBy.sql, '`col` ASC NULLS LAST');
    });

    test('null order is inverted if order type is descending', () {
      final OrderBy orderBy =
          OrderBy(col: 'col', orderType: OrderType.desc, invertNullOrder: true);
      expect(orderBy.sql, '`col` DESC NULLS FIRST');
    });

    test('escaping names can be disabled', () {
      final OrderBy orderBy = OrderBy(
        col: 'col',
        orderType: OrderType.desc,
        escapeNames: false,
      );
      expect(orderBy.sql, 'col DESC');
    });
  });

  group('orderBy', () {
    test('ordering is added with ASC', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col', OrderType.asc);
      expect(orderBy.sql, '`col` ASC');
    });

    test('ordering is added with DESC', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col', OrderType.desc);
      expect(orderBy.sql, '`col` DESC');
    });

    test('table name can be added', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col', OrderType.desc, table: 'table');
      expect(orderBy.sql, '`table`.`col` DESC');
    });

    test('multiple orders can be added', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col1', OrderType.asc);
      orderBy.orderBy('col2', OrderType.desc);

      expect(orderBy.sql, '`col1` ASC, `col2` DESC');
    });

    test('col can be empty string', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('', OrderType.asc);

      expect(orderBy.sql, '`` ASC');
    });

    test('null order is inverted if order type is ascending', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col', OrderType.asc, invertNullOrder: true);

      expect(orderBy.sql, '`col` ASC NULLS LAST');
    });

    test('null order is inverted if order type is descending', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col', OrderType.desc, invertNullOrder: true);

      expect(orderBy.sql, '`col` DESC NULLS FIRST');
    });

    test('escaping names can be disabled', () {
      final OrderBy orderBy = OrderBy();
      orderBy.orderBy('col', OrderType.asc, escapeNames: false);
      expect(orderBy.sql, 'col ASC');
    });
  });

  group('customOrderBy', () {
    test('ordering is added with ASC', () {
      final OrderBy customOrderBy = OrderBy();
      customOrderBy.customOrderBy('COALESCE(`col`, 0)', OrderType.asc);
      expect(customOrderBy.sql, 'COALESCE(`col`, 0) ASC');
    });

    test('ordering is added with DESC', () {
      final OrderBy customOrderBy = OrderBy();
      customOrderBy.customOrderBy('COALESCE(`col`, 0)', OrderType.desc);
      expect(customOrderBy.sql, 'COALESCE(`col`, 0) DESC');
    });

    test('multiple orders can be added', () {
      final OrderBy customOrderBy = OrderBy();
      customOrderBy.customOrderBy('COALESCE(`col1`, 0)', OrderType.asc);
      customOrderBy.customOrderBy('MAX(COALESCE(`col2`, 0))', OrderType.desc);

      expect(customOrderBy.sql,
          'COALESCE(`col1`, 0) ASC, MAX(COALESCE(`col2`, 0)) DESC');
    });

    test('col can be empty string', () {
      final OrderBy customOrderBy = OrderBy();
      customOrderBy.customOrderBy('', OrderType.asc);

      expect(customOrderBy.sql, ' ASC');
    });

    test('null order is inverted if order type is ascending', () {
      final OrderBy orderBy = OrderBy();
      orderBy.customOrderBy('`col`', OrderType.asc, invertNullOrder: true);

      expect(orderBy.sql, '`col` ASC NULLS LAST');
    });

    test('null order is inverted if order type is descending', () {
      final OrderBy orderBy = OrderBy();
      orderBy.customOrderBy('`col`', OrderType.desc, invertNullOrder: true);

      expect(orderBy.sql, '`col` DESC NULLS FIRST');
    });
  });
}
