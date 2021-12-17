part of sqflite_wrapper;

class Preload {
  final List<String> columns = <String>[];
  late final Join _join;
  int _numberOfPreLoads = 0;

  Preload({
    String? parentTable,
    String? parentFKey,
    String? childTable,
    String? childKey,
    List<String>? parentColumns,
    bool escapeNames = true,
  }) {
    _join = Join(escapeNames: escapeNames);

    if (parentTable != null ||
        parentFKey != null ||
        childTable != null ||
        childKey != null ||
        parentColumns != null) {
      assert(parentFKey != null);
      assert(parentTable != null);
      assert(childKey != null);
      assert(childTable != null);
      assert(parentColumns != null);

      add(
        parentTable!,
        parentFKey!,
        childTable!,
        childKey!,
        parentColumns!,
        escapeNames: escapeNames,
      );
    }
  }

  Join get join {
    return _join;
  }

  int get numberOfPreLoads {
    return _numberOfPreLoads;
  }

  bool hasClause() {
    return _numberOfPreLoads > 0;
  }

  void add(
    String parentTable,
    String parentFKey,
    String childTable,
    String childKey,
    List<String> parentColumns, {
    bool escapeNames = true,
  }) {
    _join.addLeftJoin(
      parentTable,
      parentFKey,
      childTable,
      childKey,
      escapeNames: escapeNames,
    );
    columns.addAll(
      _aliasColumns(
        parentColumns,
        prefix: parentTable,
        escapeNames: escapeNames,
      ),
    );

    _numberOfPreLoads++;
  }

/*
  void addFromOtherTable(String parentTableName, String parentFKey,
      String childTableName, String childKey, List<String> parentColumns) {
    _join.addLeftJoin(parentTableName, parentFKey, childTableName, childKey);
    _columns.addAll(_aliasColumns(parentColumns, parentTableName));

    _numberOfPreLoads++;
  }*/

  String getColumnString() {
    final StringBuffer buffer = StringBuffer();
    final int n = columns.length;

    for (int i = 0; i < n; i++) {
      final String column = columns[i];

      if (i > 0) buffer.write(', ');
      buffer.write(column);
    }
    return buffer.toString();
  }

  static Map<String, dynamic>? extractPreLoadedMap(
    String table,
    Map<String, dynamic> map,
  ) {
    final Map<String, dynamic> extracted = <String, dynamic>{};

    for (final String key in map.keys) {
      final String strippedKey = key.replaceAll('`', '');
      final String strippedTable = table.replaceAll('`', '');

      if (key.length > table.length + 2 &&
          map[key] != null &&
          strippedKey.substring(0, strippedTable.length + 2) ==
              '_${strippedTable}_') {
        extracted.putIfAbsent(
          strippedKey.substring(strippedTable.length + 2, strippedKey.length),
          () => map[key],
        );
      }
    }
    return extracted.isNotEmpty ? extracted : null;
  }

  List<String> _aliasColumns(
    List<String> columns, {
    required bool escapeNames,
    String? prefix,
  }) {
    final List<String> aliasedColumns = <String>[];

    for (final String column in columns) {
      final StringBuffer buffer = StringBuffer();

      if (escapeNames) {
        if (prefix != null) buffer.write('`$prefix`.');
        buffer.write('`$column` AS `');
        if (prefix != null) buffer.write('_$prefix');
        buffer.write('_$column`');
      } else {
        if (prefix != null) buffer.write('$prefix.');
        buffer.write('$column AS ');
        if (prefix != null) buffer.write('_$prefix');
        buffer.write('_$column');
      }

      aliasedColumns.add(buffer.toString());
    }

    return aliasedColumns;
  }
}
