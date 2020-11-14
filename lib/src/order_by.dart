part of sqflite_wrapper;

class OrderBy {
  final List<String> _orderTypes = <String>['ASC', 'DESC'];

  int _numberOfOrderings = 0;
  String _sql = '';

  OrderBy(
      {String table,
      String col,
      OrderType orderType,
      bool invertNullOrder = false}) {
    if (table != null || col != null || orderType != null) {
      assert(col != null);
      assert(orderType != null);

      orderBy(col, orderType, table: table, invertNullOrder: invertNullOrder);
    }
  }

  String get sql {
    return _sql;
  }

  int get numberOfOrderings {
    return _numberOfOrderings;
  }

  bool hasClause() {
    return _numberOfOrderings > 0;
  }

  void orderBy(String col, OrderType orderType,
      {String table, bool invertNullOrder = false}) {
    assert(orderType != null);

    final StringBuffer buffer = StringBuffer();
    buffer.write(_sql);
    if (hasClause()) buffer.write(', ');
    if (table != null) buffer.write('$table.');
    if (col == null) {
      buffer.write('NULL');
    } else {
      buffer.write(col);
    }
    buffer.write(' ${_orderTypes[orderType.index]}');

    if (invertNullOrder) {
      switch (orderType) {
        case OrderType.asc:
          buffer.write(' NULLS LAST');
          break;
        case OrderType.desc:
          buffer.write(' NULLS FIRST');
          break;
      }
    }
    _numberOfOrderings++;
    _sql = buffer.toString();
  }

  void customOrderBy(String ordering, OrderType orderType,
      {bool invertNullOrder = false}) {
    assert(orderType != null);

    final StringBuffer buffer = StringBuffer();
    buffer.write(_sql);
    if (hasClause()) buffer.write(', ');
    if (ordering == null) {
      buffer.write('NULL');
    } else {
      buffer.write(ordering);
    }
    buffer.write(' ${_orderTypes[orderType.index]}');

    if (invertNullOrder) {
      switch (orderType) {
        case OrderType.asc:
          buffer.write(' NULLS LAST');
          break;
        case OrderType.desc:
          buffer.write(' NULLS FIRST');
          break;
      }
    }
    _numberOfOrderings++;
    _sql = buffer.toString();
  }
}

enum OrderType { asc, desc }
