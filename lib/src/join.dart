part of sqflite_wrapper;

class Join {
  final List<String> _joinTypes = ['INNER JOIN', 'LEFT JOIN', 'CROSS JOIN'];

  int _numberOfJoins = 0;
  String _statement = '';

  Join({
    String tableName,
    String fKey,
    String refTableName,
    String refKey,
    JoinType type,
  }) {
    if (tableName != null ||
        fKey != null ||
        refTableName != null ||
        refKey != null) {
      assert(tableName != null);
      assert(fKey != null);
      assert(refTableName != null);
      assert(refKey != null);

      if (type == null) {
        addLeftJoin(tableName, fKey, refTableName, refKey);
      } else if (type == JoinType.innerJoin) {
        addInnerJoin(tableName, fKey, refTableName, refKey);
      } else if (type == JoinType.crossJoin) {
        addCrossJoin(tableName, fKey, refTableName, refKey);
      } else {
        addLeftJoin(tableName, fKey, refTableName, refKey);
      }
    }
  }

  String get statement {
    return _statement;
  }

  int get numberOfJoins {
    return _numberOfJoins;
  }

  bool hasClause() {
    return _numberOfJoins > 0;
  }

  void addInnerJoin(
      String tableName, String fKey, String refTableName, String refKey) {
    _addJoin(tableName, fKey, refTableName, refKey, JoinType.innerJoin);
  }

  void addLeftJoin(
      String tableName, String fKey, String refTableName, String refKey) {
    _addJoin(tableName, fKey, refTableName, refKey, JoinType.leftJoin);
  }

  void addCrossJoin(
      String tableName, String fKey, String refTableName, String refKey) {
    _addJoin(tableName, fKey, refTableName, refKey, JoinType.crossJoin);
  }

  void _addJoin(String tableName, String fKeyCol, String refTable,
      String refCol, JoinType joinType) {
    final StringBuffer buffer = StringBuffer();

    buffer.write(_statement);
    if (numberOfJoins > 0) buffer.write(' ');
    buffer.write('${_joinTypes[joinType.index]} $tableName '
        'ON $tableName.$fKeyCol = $refTable.$refCol');

    _statement = buffer.toString();
    _numberOfJoins++;
  }
}

enum JoinType { innerJoin, leftJoin, crossJoin }
