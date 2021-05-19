part of sqflite_wrapper;

class SqfTable {
  String _name;
  final List<SqfColumn> _columns;

  SqfTable({
    required String name,
    required List<SqfColumn> columns,
  })  : _name = name,
        _columns = columns;

  String get create {
    final StringBuffer sql = StringBuffer();

    sql.write('CREATE TABLE $_name (');

    for (int i = 0; i < _columns.length; i++) {
      sql.write(_columns[i].sql);

      if (i < _columns.length - 1) {
        sql.write(', ');
      }
    }

    sql.write(');');

    return sql.toString();
  }

  String get drop {
    return 'DROP TABLE $_name;';
  }

  String get name {
    return _name;
  }

  String rename(String newName) {
    final String sql = 'ALTER TABLE $_name RENAME TO $newName;';
    _name = newName;
    return sql;
  }

  String renameColumn(String currentName, String newName) {
    final SqfColumn column =
        _columns.where((SqfColumn c) => c.name == currentName).single;

    return column.rename(_name, newName);
  }

  String addColumn(SqfColumn newColumn) {
    assert(_columns.where((SqfColumn c) => c.name == newColumn.name).isEmpty,
        'Duplicate column name');
    if (newColumn.indexes != null) {
      assert(!newColumn.indexes!.contains(SqfColumnProperty.primaryKey),
          "Added column can't be primary key");
      assert(!newColumn.indexes!.contains(SqfColumnProperty.unique),
          "Added column can't be unique");
      assert(
          !newColumn.indexes!.contains(SqfColumnProperty.notNull) &&
              (newColumn.defaultValue == null ||
                  newColumn.defaultValue == SqfColumnValue.nullValue),
          'Added column with NOT NULL constraint must have a default value '
          'other than NULL');
    }
    if (newColumn.defaultValue != null) {
      assert(
          newColumn.defaultValue is! SqfColumnValue ||
              newColumn.defaultValue == SqfColumnValue.nullValue,
          "Added column can't have ${newColumn.defaultValue} as default value");
      assert(newColumn.defaultValue is! SqfFunction,
          "Added column can't have an expression as default value");
    }

    _columns.add(newColumn);

    return 'ALTER TABLE $_name ADD COLUMN ${newColumn.sql};';
  }

  String dropColumn(String columnName) {
    final SqfColumn column =
        _columns.where((SqfColumn c) => c.name == columnName).single;

    _columns.remove(column);

    return column.drop(_name);
  }
}
