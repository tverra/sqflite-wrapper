part of sqflite_wrapper;

class SqfTable {
  String _name;
  final List<SqfColumn> _columns;
  final List<String>? _unique;

  SqfTable({
    required String name,
    required List<SqfColumn> columns,
    List<String>? unique,
  })  : _name = name,
        _columns = columns,
        _unique = unique;

  String get create {
    assert(_columns.isNotEmpty, 'At least one column is required');
    final List<String>? unique = _unique;

    final StringBuffer buffer = StringBuffer();

    buffer.write('CREATE TABLE `$_name` (');

    for (int i = 0; i < _columns.length; i++) {
      buffer.write(_columns[i].sql);

      if (i < _columns.length - 1) {
        buffer.write(', ');
      }
    }

    if (unique != null && unique.isNotEmpty) {
      buffer.write(', UNIQUE(');

      for (int i = 0; i < unique.length; i++) {
        buffer.write('`${unique[i]}`');

        if (i < unique.length - 1) {
          buffer.write(', ');
        }
      }
      buffer.write(')');
    }

    buffer.write(');');

    return buffer.toString();
  }

  String get drop {
    return 'DROP TABLE `$_name`;';
  }

  String get name {
    return _name;
  }

  String rename(String newName) {
    final String sql = 'ALTER TABLE `$_name` RENAME TO `$newName`;';
    _name = newName;
    return sql;
  }

  String renameColumn(String currentName, String newName) {
    final SqfColumn column =
        _columns.where((SqfColumn c) => c.name == currentName).single;

    return column.rename(_name, newName);
  }

  String addColumn(SqfColumn newColumn) {
    assert(
      _columns.where((SqfColumn c) => c.name == newColumn.name).isEmpty,
      'Duplicate column name',
    );
    if (newColumn.properties != null) {
      assert(
        !newColumn.properties!.contains(SqfColumnProperty.primaryKey),
        "Added column can't be primary key",
      );
      assert(
        !newColumn.properties!.contains(SqfColumnProperty.unique),
        "Added column can't be unique",
      );
      assert(
        !newColumn.properties!.contains(SqfColumnProperty.notNull) &&
            (newColumn.defaultValue == null ||
                newColumn.defaultValue == SqfColumnValue.nullValue),
        'Added column with NOT NULL constraint must have a default value '
        'other than NULL',
      );
    }
    if (newColumn.defaultValue != null) {
      assert(
        newColumn.defaultValue is! SqfColumnValue ||
            newColumn.defaultValue == SqfColumnValue.nullValue,
        "Added column can't have ${newColumn.defaultValue} as default value",
      );
      assert(
        newColumn.defaultValue is! SqfFunction,
        "Added column can't have an expression as default value",
      );
    }

    _columns.add(newColumn);

    return 'ALTER TABLE `$_name` ADD COLUMN ${newColumn.sql};';
  }

  String dropColumn(String columnName) {
    final SqfColumn column =
        _columns.where((SqfColumn c) => c.name == columnName).single;

    _columns.remove(column);

    return column.drop(_name);
  }
}
