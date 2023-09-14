part of '../../sqflite_wrapper.dart';

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
    String? alias,
    bool escapeNames = true,
  }) {
    _join = Join();

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
        alias: alias,
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
    String? alias,
    bool escapeNames = true,
  }) {
    _join.addLeftJoin(
      parentTable,
      parentFKey,
      childTable,
      childKey,
      alias: alias,
      escapeNames: escapeNames,
    );
    columns.addAll(
      _aliasColumns(
        parentColumns,
        alias: alias ?? parentTable,
        escapeNames: escapeNames,
      ),
    );

    _numberOfPreLoads++;
  }

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
    String? alias,
  }) {
    final List<String> aliasedColumns = <String>[];

    for (final String column in columns) {
      final StringBuffer buffer = StringBuffer();

      if (escapeNames) {
        if (alias != null) buffer.write('`$alias`.');
        buffer.write('`$column` AS `');
        if (alias != null) buffer.write('_$alias');
        buffer.write('_$column`');
      } else {
        if (alias != null) buffer.write('$alias.');
        buffer.write('$column AS ');
        if (alias != null) buffer.write('_$alias');
        buffer.write('_$column');
      }

      aliasedColumns.add(buffer.toString());
    }

    return aliasedColumns;
  }
}
