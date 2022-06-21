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
        _unique = unique != null ? List<String>.from(unique).toList() : null;

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

  List<SqfColumn> get columns {
    return _columns;
  }

  List<String>? get unique {
    final List<String>? thisUnique = _unique;

    if (thisUnique == null) return null;

    return List<String>.from(thisUnique).toList();
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

  List<String> dropColumns(List<String> columns) {
    final List<SqfColumn> matches =
        _columns.where((SqfColumn c) => columns.contains(c.name)).toList();

    for (final SqfColumn column in matches) {
      assert(
        column.properties?.contains(SqfColumnProperty.primaryKey) != true,
        "Dropped column can't be primary key",
      );
      assert(
        column.properties?.contains(SqfColumnProperty.unique) != true,
        "Dropped column can't be unique",
      );

      _columns.remove(column);
    }

    final SqfTable newTable = SqfTable(
      name: '_new_$_name',
      columns: _columns,
      unique: _unique,
    );

    return <String>[
      newTable.create,
      'INSERT INTO `${newTable.name}` SELECT ${newTable.columns.toCommaSeparated()} FROM `$_name`;',
      'DROP TABLE `$_name`;',
      'ALTER TABLE `${newTable.name}` RENAME TO `$_name`;',
    ];
  }

  SqfTable copyWith({
    String? name,
    List<SqfColumn>? columns,
    List<String>? unique,
  }) {
    final List<String>? thisUnique = _unique;

    return SqfTable(
      name: name ?? _name,
      columns: columns ?? _columns.map((SqfColumn c) => c.copyWith()).toList(),
      unique: unique ??
          (thisUnique != null ? List<String>.from(thisUnique).toList() : null),
    );
  }
}
