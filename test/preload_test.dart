import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  late List<String> _parentColumns;

  setUp(() async {
    _parentColumns = <String>[
      'parent_column1',
      'parent_column2',
      'parent_column3',
    ];
  });

  group('constructor', () {
    test('numberOfPreloadsIsInitiallyZero', () {
      final Preload preload = Preload();
      expect(preload.numberOfPreLoads, 0);
    });

    test('columns are initially empty list', () {
      final Preload preload = Preload();
      expect(preload.columns, <String>[]);
    });

    test('columns string is initially empty string', () {
      final Preload preload = Preload();
      expect(preload.getColumnString(), '');
    });

    test('parentTableName is asserted not null', () {
      expect(() {
        Preload(
          parentFKey: 'parent_fkey',
          childTable: 'child_table_name',
          childKey: 'child_pkey',
          parentColumns: _parentColumns,
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('parentFKey is asserted not null', () {
      expect(() {
        Preload(
          parentTable: 'parent_table_name',
          childTable: 'child_table_name',
          childKey: 'child_pkey',
          parentColumns: _parentColumns,
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('childTableName is asserted not null', () {
      expect(() {
        Preload(
          parentTable: 'parent_table_name',
          parentFKey: 'parent_fkey',
          childKey: 'child_pkey',
          parentColumns: _parentColumns,
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('childFKey is asserted not null', () {
      expect(() {
        Preload(
          parentTable: 'parent_table_name',
          parentFKey: 'parent_fkey',
          childTable: 'child_table_name',
          parentColumns: _parentColumns,
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('parentColumns is asserted not null', () {
      expect(() {
        Preload(
          parentTable: 'parent_table_name',
          parentFKey: 'parent_fkey',
          childTable: 'child_table_name',
          childKey: 'child_pkey',
        );
      }, throwsA(isA<AssertionError>()));
    });

    test('adding preload increments number of preloads', () {
      final Preload preload = Preload(
        parentTable: 'parent_table_name',
        parentFKey: 'parent_fkey',
        childTable: 'child_table_name',
        childKey: 'child_pkey',
        parentColumns: _parentColumns,
      );

      expect(preload.numberOfPreLoads, 1);
    });

    test('hasClause returns false initially', () {
      final Preload preload = Preload();

      expect(preload.hasClause(), false);
    });

    test('hasClause returns true if has preload', () {
      final Preload preload = Preload(
        parentTable: 'parent_table_name',
        parentFKey: 'parent_fkey',
        childTable: 'child_table_name',
        childKey: 'child_pkey',
        parentColumns: _parentColumns,
      );

      expect(preload.hasClause(), true);
    });
  });

  group('add', () {
    test('addingPreloadIncrementsNumberOfPreloads', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );
      expect(preload.numberOfPreLoads, 1);
    });

    test('addingPreloadsIncrementsNumberOfPreloads', () {
      final Preload preload = Preload();

      preload.add(
        'parent_table_name1',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );
      preload.add(
        'parent_table_name2',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );
      preload.add(
        'parent_table_name3',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );

      expect(preload.numberOfPreLoads, 3);
    });

    test('adding preload adds columns to list', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );

      expect(preload.columns, <String>[
        '`parent_table_name`.`parent_column1` AS `_parent_table_name_parent_column1`',
        '`parent_table_name`.`parent_column2` AS `_parent_table_name_parent_column2`',
        '`parent_table_name`.`parent_column3` AS `_parent_table_name_parent_column3`',
      ]);
    });

    test('escaping names can be disabled when adding columns to list', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
        escapeNames: false,
      );

      expect(preload.columns, <String>[
        'parent_table_name.parent_column1 AS _parent_table_name_parent_column1',
        'parent_table_name.parent_column2 AS _parent_table_name_parent_column2',
        'parent_table_name.parent_column3 AS _parent_table_name_parent_column3',
      ]);
    });

    test('adding preload adds columns to string', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );

      expect(
        preload.getColumnString(),
        '`parent_table_name`.`parent_column1` AS '
        '`_parent_table_name_parent_column1`, '
        '`parent_table_name`.`parent_column2` AS '
        '`_parent_table_name_parent_column2`, '
        '`parent_table_name`.`parent_column3` AS '
        '`_parent_table_name_parent_column3`',
      );
    });

    test('escaping names can be disabled when adding columns to string', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
        escapeNames: false,
      );

      expect(
        preload.getColumnString(),
        'parent_table_name.parent_column1 AS '
        '_parent_table_name_parent_column1, '
        'parent_table_name.parent_column2 AS '
        '_parent_table_name_parent_column2, '
        'parent_table_name.parent_column3 AS '
        '_parent_table_name_parent_column3',
      );
    });

    test('adding multiple preload adds columns to string', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name1',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );
      preload.add(
        'parent_table_name2',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );
      preload.add(
        'parent_table_name3',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );

      expect(preload.columns, <String>[
        '`parent_table_name1`.`parent_column1` AS `_parent_table_name1_parent_column1`',
        '`parent_table_name1`.`parent_column2` AS `_parent_table_name1_parent_column2`',
        '`parent_table_name1`.`parent_column3` AS `_parent_table_name1_parent_column3`',
        '`parent_table_name2`.`parent_column1` AS `_parent_table_name2_parent_column1`',
        '`parent_table_name2`.`parent_column2` AS `_parent_table_name2_parent_column2`',
        '`parent_table_name2`.`parent_column3` AS `_parent_table_name2_parent_column3`',
        '`parent_table_name3`.`parent_column1` AS `_parent_table_name3_parent_column1`',
        '`parent_table_name3`.`parent_column2` AS `_parent_table_name3_parent_column2`',
        '`parent_table_name3`.`parent_column3` AS `_parent_table_name3_parent_column3`'
      ]);
    });

    test('adding preload adds left join', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
      );

      expect(
          preload.join.statement,
          'LEFT JOIN `parent_table_name` '
          'ON `parent_table_name`.`parent_fkey` = '
          '`child_table_name`.`child_pkey`');
    });

    test('adding multiple preloads adds multiple left joins', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name1',
        'parent_fkey',
        'child_table_name1',
        'child_pkey',
        _parentColumns,
      );
      preload.add(
        'parent_table_name2',
        'parent_fkey',
        'child_table_name2',
        'child_pkey',
        _parentColumns,
      );
      preload.add(
        'parent_table_name3',
        'parent_fkey',
        'child_table_name3',
        'child_pkey',
        _parentColumns,
      );

      expect(
        preload.join.statement,
        'LEFT JOIN `parent_table_name1` '
        'ON `parent_table_name1`.`parent_fkey` = '
        '`child_table_name1`.`child_pkey` '
        'LEFT JOIN `parent_table_name2` '
        'ON `parent_table_name2`.`parent_fkey` = '
        '`child_table_name2`.`child_pkey` '
        'LEFT JOIN `parent_table_name3` '
        'ON `parent_table_name3`.`parent_fkey` = '
        '`child_table_name3`.`child_pkey`',
      );
    });

    test('escaping names can be disabled in added left join', () {
      final Preload preload = Preload();
      preload.add(
        'parent_table_name',
        'parent_fkey',
        'child_table_name',
        'child_pkey',
        _parentColumns,
        escapeNames: false,
      );

      expect(
        preload.join.statement,
        'LEFT JOIN parent_table_name '
        'ON parent_table_name.parent_fkey = '
        'child_table_name.child_pkey',
      );
    });
  });

  group('extract preloaded map', () {
    test('extracts preloaded value', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col': 1,
        '_table_col': 2
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table', map);

      expect(extracted, <String, dynamic>{'col': 2});
    });

    test('extracts multiple preloaded values', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col1': 1,
        'col2': 2,
        'col3': 3,
        '_table_col1': 4,
        '_table_col2': 5,
        '_table_col3': 6,
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table', map);

      expect(extracted, <String, dynamic>{'col1': 4, 'col2': 5, 'col3': 6});
    });

    test('original map is not changed', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col1': 1,
        'col2': 2,
        'col3': 3,
        '_table_col1': 4,
        '_table_col2': 5,
        '_table_col3': 6,
      };

      Preload.extractPreLoadedMap('table', map);

      expect(map, <String, dynamic>{
        'col1': 1,
        'col2': 2,
        'col3': 3,
        '_table_col1': 4,
        '_table_col2': 5,
        '_table_col3': 6,
      });
    });

    test('returns null if map is empty', () {
      final Map<String, dynamic> map = <String, dynamic>{};

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table', map);

      expect(extracted, null);
    });

    test('returns null if no preloaded values', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col1': 1,
        'col2': 2,
        'col3': 3,
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table', map);

      expect(extracted, null);
    });

    test('extracts only from correct table', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col1': 1,
        'col2': 2,
        'col3': 3,
        '_table1_col1': 4,
        '_table2_col2': 5,
        '_table3_col3': 6,
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table2', map);

      expect(extracted, <String, dynamic>{'col2': 5});
    });

    test('expects underline before and after table name', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col1': 1,
        'col2': 2,
        'col3': 3,
        '_tablecol1': 4,
        'table_col2': 5,
        '_table_col3': 6,
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table', map);

      expect(extracted, <String, dynamic>{'col3': 6});
    });

    test('extracts correct columns', () {
      final Map<String, dynamic> map = <String, dynamic>{
        '': 0,
        'a': 1,
        'aa': 2,
        'aaa': 3,
        'aaaa': 4,
        'aaaaa': 5,
        'aaaaaa': 6,
        'aaaaaaa': 7,
        'aaaaaaaa': 8,
        'aaaaaaaaa': 9,
        'aaaaaaaaaa': 10,
        '_t__col1': 11,
        't_col2': 12,
        '__t_col3': 13,
        '_t_col4': 14,
        '_t1_col5': 15,
        '_t_col6': null,
        '17': null,
        '_t_': 18,
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('t', map);

      expect(extracted, <String, dynamic>{'_col1': 11, 'col4': 14});
    });

    test('extracts preloaded value when names are escaped', () {
      final Map<String, dynamic> map = <String, dynamic>{
        '`col`': 1,
        '`_table_col`': 2
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('table', map);

      expect(extracted, <String, dynamic>{'col': 2});
    });

    test('extracts preloaded value when table name is escaped', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'col': 1,
        '_table_col': 2
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('`table`', map);

      expect(extracted, <String, dynamic>{'col': 2});
    });

    test('extracts preloaded value when table and names are escaped', () {
      final Map<String, dynamic> map = <String, dynamic>{
        '`col`': 1,
        '`_table_col`': 2
      };

      final Map<String, dynamic>? extracted =
          Preload.extractPreLoadedMap('`table`', map);

      expect(extracted, <String, dynamic>{'col': 2});
    });
  });
}
