part of sqflite_wrapper;

class SqfColumn {
  String _name;
  final SqfType? _type;
  final List<SqfColumnProperty>? _indexes;
  final SqfReferences? _references;
  final dynamic _defaultValue;

  SqfColumn({
    required String name,
    SqfType? type,
    SqfReferences? references,
    List<SqfColumnProperty>? properties,
    dynamic defaultValue,
  })  : _name = name,
        _type = type,
        _indexes = properties,
        _references = references,
        _defaultValue = defaultValue;

  String get name {
    return _name;
  }

  SqfType? get type {
    return _type;
  }

  List<SqfColumnProperty>? get indexes {
    if (_indexes == null) return null;
    return List<SqfColumnProperty>.from(_indexes!);
  }

  SqfReferences? get references {
    return _references;
  }

  dynamic get defaultValue {
    return _defaultValue;
  }

  String get sql {
    final StringBuffer sql = StringBuffer();

    sql.write(_name);

    if (_type != null) {
      sql.write(' ${sqfTypes[_type!.index]}');
    }

    if (_indexes != null) {
      if (_indexes!.contains(SqfColumnProperty.primaryKey)) {
        sql.write(' ${sqfIndexes[SqfColumnProperty.primaryKey.index]}');
      } else {
        if (_indexes!.contains(SqfColumnProperty.notNull)) {
          sql.write(' ${sqfIndexes[SqfColumnProperty.notNull.index]}');
        }
        if (_indexes!.contains(SqfColumnProperty.unique)) {
          sql.write(' ${sqfIndexes[SqfColumnProperty.unique.index]}');
        }
      }
    }

    if (_defaultValue != null) {
      sql.write(' DEFAULT ');

      if (_defaultValue is SqfColumnValue) {
        sql.write(sqfColumnValues[_defaultValue.index]);
      } else if (_defaultValue is SqfFunction) {
        sql.write('(${_defaultValue.sql})');
      } else if (_type == null) {
        if (_defaultValue is num) {
          sql.write(_defaultValue.toString());
        } else if (_defaultValue is String) {
          sql.write('"${_defaultValue.toString()}"');
        } else {
          sql.write('(${_defaultValue.toString()})');
        }
      } else {
        switch (_type!) {
          case SqfType.integer:
            sql.write(_defaultValue.toString());
            break;
          case SqfType.text:
            sql.write('"${_defaultValue.toString()}"');
            break;
          case SqfType.blob:
            sql.write('(${_defaultValue.toString()})');
            break;
          case SqfType.real:
            sql.write(_defaultValue.toString());
            break;
          case SqfType.numeric:
            sql.write(_defaultValue.toString());
            break;
        }
      }
    }

    if (_references != null) {
      sql.write(' ${_references!.sql(columnName: _name)}');
    }

    return sql.toString();
  }

  String drop(String tableName) {
    if (_indexes != null) {
      assert(!_indexes!.contains(SqfColumnProperty.primaryKey),
          "Dropped column can't be primary key");
      assert(!_indexes!.contains(SqfColumnProperty.unique),
          "Dropped column can't be unique");
    }

    return 'ALTER TABLE $tableName DROP COLUMN $_name;';
  }

  String rename(String tableName, String newName) {
    final String sql =
        'ALTER TABLE $tableName RENAME COLUMN $_name TO $newName;';
    _name = newName;
    return sql;
  }
}

List<String> sqfTypes = <String>['INTEGER', 'TEXT', 'BLOB', 'REAL', 'NUMERIC'];
List<String> sqfIndexes = <String>['PRIMARY KEY', 'NOT NULL', 'UNIQUE'];
List<String> sqfColumnValues = <String>[
  'CURRENT_TIME',
  'CURRENT_DATE',
  'CURRENT_TIMESTAMP',
  'NULL',
];

enum SqfType {
  integer,
  text,
  blob,
  real,
  numeric,
}

enum SqfColumnProperty {
  primaryKey,
  notNull,
  unique,
}

enum SqfColumnValue {
  currentTime,
  currentDate,
  currentTimestamp,
  nullValue,
}
