part of '../../sqflite_wrapper.dart';

class Join {
  final List<String> _joinTypes = <String>[
    'INNER JOIN',
    'LEFT JOIN',
    'CROSS JOIN',
  ];

  int _numberOfJoins = 0;
  String _statement = '';

  Join({
    String? tableName,
    String? fKey,
    String? refTableName,
    String? refKey,
    JoinType? type,
    String? alias,
    bool escapeNames = true,
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
        addLeftJoin(
          tableName!,
          fKey!,
          refTableName!,
          refKey!,
          alias: alias,
          escapeNames: escapeNames,
        );
      } else if (type == JoinType.innerJoin) {
        addInnerJoin(
          tableName!,
          fKey!,
          refTableName!,
          refKey!,
          alias: alias,
          escapeNames: escapeNames,
        );
      } else if (type == JoinType.crossJoin) {
        addCrossJoin(
          tableName!,
          fKey!,
          refTableName!,
          refKey!,
          alias: alias,
          escapeNames: escapeNames,
        );
      } else {
        addLeftJoin(
          tableName!,
          fKey!,
          refTableName!,
          refKey!,
          alias: alias,
          escapeNames: escapeNames,
        );
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
    String tableName,
    String fKey,
    String refTableName,
    String refKey, {
    String? alias,
    bool escapeNames = true,
  }) {
    _addJoin(
      tableName,
      fKey,
      refTableName,
      refKey,
      JoinType.innerJoin,
      alias,
      escapeNames,
    );
  }

  void addLeftJoin(
    String tableName,
    String fKey,
    String refTableName,
    String refKey, {
    String? alias,
    bool escapeNames = true,
  }) {
    _addJoin(
      tableName,
      fKey,
      refTableName,
      refKey,
      JoinType.leftJoin,
      alias,
      escapeNames,
    );
  }

  void addCrossJoin(
    String tableName,
    String fKey,
    String refTableName,
    String refKey, {
    String? alias,
    bool escapeNames = true,
  }) {
    _addJoin(
      tableName,
      fKey,
      refTableName,
      refKey,
      JoinType.crossJoin,
      alias,
      escapeNames,
    );
  }

  void _addJoin(
    String tableName,
    String fKeyCol,
    String refTable,
    String refCol,
    JoinType joinType,
    String? alias,
    bool escapeNames,
  ) {
    final StringBuffer buffer = StringBuffer();

    buffer.write(_statement);
    if (numberOfJoins > 0) buffer.write(' ');

    if (escapeNames) {
      buffer.write('${_joinTypes[joinType.index]} `$tableName` ');

      if (alias != null) {
        buffer.write('AS `$alias` ');
      }

      buffer.write(
        'ON `${alias ?? tableName}`.`$fKeyCol` = `$refTable`.`$refCol`',
      );
    } else {
      buffer.write('${_joinTypes[joinType.index]} $tableName ');

      if (alias != null) {
        buffer.write('AS $alias ');
      }

      buffer.write('ON ${alias ?? tableName}.$fKeyCol = $refTable.$refCol');
    }

    _statement = buffer.toString();
    _numberOfJoins++;
  }
}

enum JoinType { innerJoin, leftJoin, crossJoin }
