part of sqflite_wrapper;

class SqfIndex {
  final String tableName;
  final List<String> _columnNames;
  final bool unique;
  late final String name;

  SqfIndex({
    required this.tableName,
    required List<String> columnNames,
    this.unique = false,
    String? name,
  })  : _columnNames = List<String>.from(columnNames).toList(),
        assert(columnNames.isNotEmpty, "Column list can't be empty") {
    final StringBuffer indexName = StringBuffer('idx_$tableName');

    for (final String columnName in columnNames) {
      indexName.write('_$columnName');
    }
    this.name = name ?? indexName.toString();
  }

  String get sql {
    final StringBuffer buffer = StringBuffer('CREATE ');

    if (unique) buffer.write('UNIQUE ');

    buffer.write('INDEX `$name` ON `$tableName` (');

    for (int i = 0; i < _columnNames.length; i++) {
      buffer.write('`${_columnNames[i]}`');

      if (i < _columnNames.length - 1) {
        buffer.write(', ');
      }
    }
    buffer.write(');');

    return buffer.toString();
  }

  String get drop {
    return 'DROP INDEX `$name`;';
  }

  SqfIndex copyWith({
    String? tableName,
    List<String>? columnNames,
    bool? unique,
    String? name,
  }) {
    return SqfIndex(
      tableName: tableName ?? this.tableName,
      columnNames: columnNames ?? List<String>.from(_columnNames).toList(),
      unique: unique ?? this.unique,
      name: name ?? this.name,
    );
  }
}
