part of sqflite_wrapper;

class OrderBy {
  final List<String> _orderTypes = <String>['ASC', 'DESC'];
  String _sql = '';
  int _numberOfOrderings = 0;

  OrderBy(
      {String? table,
      String? col,
      OrderType? orderType,
      bool invertNullOrder = false}) {
    if (table != null || col != null || orderType != null) {
      assert(col != null);
      assert(orderType != null);

      orderBy(col!, orderType!, table: table, invertNullOrder: invertNullOrder);
    }
  }

  String get sql {
    return _sql;
  }

  int get numberOfOrderings {
    return _numberOfOrderings;
  }

  bool hasClause() {
    return numberOfOrderings > 0;
  }

  void orderBy(String col, OrderType orderType,
      {String? table, bool invertNullOrder = false}) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(sql);
    if (hasClause()) buffer.write(', ');
    if (table != null) buffer.write('$table.');

    buffer.write(col);
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
    final StringBuffer buffer = StringBuffer();
    buffer.write(_sql);
    if (hasClause()) buffer.write(', ');
    buffer.write(ordering);
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
