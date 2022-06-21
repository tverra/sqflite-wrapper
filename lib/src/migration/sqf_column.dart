part of sqflite_wrapper;

class SqfColumn {
  String _name;
  final SqfType? _type;
  final List<SqfColumnProperty>? _properties;
  final SqfReferences? _references;
  final Object? _defaultValue;

  SqfColumn({
    required String name,
    SqfType? type,
    SqfReferences? references,
    List<SqfColumnProperty>? properties,
    dynamic defaultValue,
  })  : _name = name,
        _type = type,
        _properties = properties != null
            ? List<SqfColumnProperty>.from(properties)
            : null,
        _references = references,
        _defaultValue = defaultValue;

  String get name {
    return _name;
  }

  SqfType? get type {
    return _type;
  }

  List<SqfColumnProperty>? get properties {
    final List<SqfColumnProperty>? thisProperties = _properties;

    if (thisProperties == null) return null;
    return List<SqfColumnProperty>.from(thisProperties);
  }

  SqfReferences? get references {
    return _references;
  }

  dynamic get defaultValue {
    return _defaultValue;
  }

  String get sql {
    final StringBuffer buffer = StringBuffer();
    final Object? defaultValue = _defaultValue;

    buffer.write('`$_name`');

    if (_type != null) {
      buffer.write(' ${sqfTypes[_type!.index]}');
    }

    if (_properties != null) {
      if (_properties!.contains(SqfColumnProperty.primaryKey)) {
        buffer.write(' ${sqfIndexes[SqfColumnProperty.primaryKey.index]}');
      } else {
        if (_properties!.contains(SqfColumnProperty.notNull)) {
          buffer.write(' ${sqfIndexes[SqfColumnProperty.notNull.index]}');
        }
        if (_properties!.contains(SqfColumnProperty.unique)) {
          buffer.write(' ${sqfIndexes[SqfColumnProperty.unique.index]}');
        }
      }
    }

    if (defaultValue != null) {
      buffer.write(' DEFAULT ');

      if (defaultValue is SqfColumnValue) {
        buffer.write(sqfColumnValues[defaultValue.index]);
      } else if (defaultValue is SqfFunction) {
        buffer.write('(${defaultValue.sql})');
      } else if (_type == null) {
        if (defaultValue is num) {
          buffer.write(defaultValue.toString());
        } else if (defaultValue is String) {
          buffer.write('"$defaultValue"');
        } else {
          buffer.write('(${defaultValue.toString()})');
        }
      } else {
        switch (_type!) {
          case SqfType.integer:
            buffer.write(defaultValue.toString());
            break;
          case SqfType.text:
            buffer.write('"${defaultValue.toString()}"');
            break;
          case SqfType.blob:
            buffer.write('(${defaultValue.toString()})');
            break;
          case SqfType.real:
            buffer.write(defaultValue.toString());
            break;
          case SqfType.numeric:
            buffer.write(defaultValue.toString());
            break;
        }
      }
    }

    if (_references != null) {
      buffer.write(' ${_references!.sql(columnName: _name)}');
    }

    return buffer.toString();
  }

  String rename(String tableName, String newName) {
    final String sql =
        'ALTER TABLE `$tableName` RENAME COLUMN `$_name` TO `$newName`;';
    _name = newName;
    return sql;
  }

  SqfColumn copyWith({
    String? name,
    SqfType? type,
    SqfReferences? references,
    List<SqfColumnProperty>? properties,
    dynamic defaultValue,
  }) {
    final List<SqfColumnProperty>? thisProperties = _properties;

    return SqfColumn(
      name: name ?? _name,
      type: type ?? _type,
      references: references ?? _references?.copyWith(),
      properties: properties ??
          (thisProperties != null
              ? List<SqfColumnProperty>.from(thisProperties)
              : null),
      defaultValue: defaultValue ?? _defaultValue,
    );
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
