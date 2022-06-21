import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('mutable members are cloned', () {
      final List<String> unique = <String>['col1'];

      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'id',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
        ],
        unique: unique,
      );

      unique.add('col2');

      expect(table.unique, <String>['col1']);
    });
  });

  group('create table', () {
    test('table is created with required parameters', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'id',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
        ],
      );

      final String actual = table.create;
      const String expected =
          'CREATE TABLE `table_name` (`id` INTEGER PRIMARY KEY);';

      expect(actual, expected);
    });

    test('table is created with multiple columns', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'col1',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
          SqfColumn(
            name: 'col2',
            type: SqfType.text,
            properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
          ),
          SqfColumn(
            name: 'col3',
            type: SqfType.blob,
            properties: <SqfColumnProperty>[SqfColumnProperty.unique],
          ),
          SqfColumn(
            name: 'col4',
            type: SqfType.real,
          ),
          SqfColumn(
            name: 'col5',
            type: SqfType.integer,
            references: SqfReferences(
              foreignTableName: 'f_table',
              foreignColumnName: 'f_col',
              onUpdate: SqfAction.setNull,
              onDelete: SqfAction.restrict,
            ),
          ),
        ],
      );

      final String actual = table.create;
      const String expected =
          'CREATE TABLE `table_name` (`col1` INTEGER PRIMARY KEY, '
          '`col2` TEXT NOT NULL, '
          '`col3` BLOB UNIQUE, '
          '`col4` REAL, '
          '`col5` INTEGER REFERENCES `f_table`(`f_col`) '
          'ON UPDATE SET NULL ON DELETE RESTRICT);';

      expect(actual, expected);
    });

    test('at least one column is required', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(
        () {
          table.create;
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('unique constraint is added', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'col1',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
          SqfColumn(
            name: 'col2',
            type: SqfType.integer,
          ),
          SqfColumn(
            name: 'col3',
            type: SqfType.integer,
          ),
          SqfColumn(
            name: 'col4',
            type: SqfType.integer,
          ),
        ],
        unique: <String>['col2'],
      );

      final String actual = table.create;
      const String expected =
          'CREATE TABLE `table_name` (`col1` INTEGER PRIMARY KEY, '
          '`col2` INTEGER, '
          '`col3` INTEGER, '
          '`col4` INTEGER, '
          'UNIQUE(`col2`)'
          ');';

      expect(actual, expected);
    });

    test('unique constraint is added on multiple columns', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'col1',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
          SqfColumn(
            name: 'col2',
            type: SqfType.integer,
          ),
          SqfColumn(
            name: 'col3',
            type: SqfType.integer,
          ),
          SqfColumn(
            name: 'col4',
            type: SqfType.integer,
          ),
        ],
        unique: <String>['col2, col3, col4'],
      );

      final String actual = table.create;
      const String expected =
          'CREATE TABLE `table_name` (`col1` INTEGER PRIMARY KEY, '
          '`col2` INTEGER, '
          '`col3` INTEGER, '
          '`col4` INTEGER, '
          'UNIQUE(`col2, col3, col4`)'
          ');';

      expect(actual, expected);
    });
  });

  group('drop table', () {
    test('drop statement is returned', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'id',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
        ],
      );

      final String actual = table.drop;
      const String expected = 'DROP TABLE `table_name`;';

      expect(actual, expected);
    });
  });

  group('rename table', () {
    test('returns rename statement', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'id',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
        ],
      );

      final String actual = table.rename('new_table_name');
      const String expected =
          'ALTER TABLE `table_name` RENAME TO `new_table_name`;';

      expect(actual, expected);
    });

    test('rename table changes table name', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'id',
            type: SqfType.integer,
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
        ],
      );

      table.rename('new_table_name');

      expect(table.name, 'new_table_name');
    });
  });

  group('rename column', () {
    test('returns rename statement', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      final String actual = table.renameColumn('col2', 'new_col');
      const String expected =
          'ALTER TABLE `table_name` RENAME COLUMN `col2` TO `new_col`;';

      expect(actual, expected);
    });

    test('rename column changes column name', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      table.renameColumn('col2', 'new_col');
      final String actual = table.create;
      const String expected =
          'CREATE TABLE `table_name` (`col1`, `new_col`, `col3`);';

      expect(actual, expected);
    });
  });

  group('add column', () {
    test('add column returns statement', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      final String actual = table.addColumn(SqfColumn(name: 'col4'));
      const String expected = 'ALTER TABLE `table_name` ADD COLUMN `col4`;';

      expect(actual, expected);
    });

    test('add column adds column to table', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      table.addColumn(SqfColumn(name: 'col4'));
      final String actual = table.create;
      const String expected =
          'CREATE TABLE `table_name` (`col1`, `col2`, `col3`, `col4`);';

      expect(actual, expected);
    });

    test('asserts column name not duplicate', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      expect(
        () {
          table.addColumn(SqfColumn(name: 'col2'));
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts index not primary key', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(
        () {
          table.addColumn(
            SqfColumn(
              name: 'col2',
              properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
            ),
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts index not unique', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(
        () {
          table.addColumn(
            SqfColumn(
              name: 'col2',
              properties: <SqfColumnProperty>[SqfColumnProperty.unique],
            ),
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts not null default value if constraint is NOT NULL', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(
        () {
          table.addColumn(
            SqfColumn(
              name: 'col2',
              properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
            ),
          );
        },
        throwsA(isA<AssertionError>()),
      );

      expect(
        () {
          table.addColumn(
            SqfColumn(
              name: 'col2',
              defaultValue: SqfColumnValue.nullValue,
              properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
            ),
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts invalid default value', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(
        () {
          table.addColumn(
            SqfColumn(
              name: 'col2',
              defaultValue: SqfColumnValue.currentTimestamp,
            ),
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts default value not an expression', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(
        () {
          table.addColumn(
            SqfColumn(
              name: 'col2',
              defaultValue: SqfFunction.max('1'),
            ),
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('drop columns', () {
    test('dropping one column returns statements', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      final List<String> actual = table.dropColumns(<String>['col2']);
      const List<String> expected = <String>[
        'CREATE TABLE `_new_table_name` (`col1`, `col3`);',
        'INSERT INTO `_new_table_name` SELECT `col1`, `col3` FROM `table_name`;',
        'DROP TABLE `table_name`;',
        'ALTER TABLE `_new_table_name` RENAME TO `table_name`;',
      ];

      expect(actual, expected);
    });

    test('dropping one column removes column from table', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      table.dropColumns(<String>['col2']);
      final String actual = table.create;
      const String expected = 'CREATE TABLE `table_name` (`col1`, `col3`);';

      expect(actual, expected);
    });

    test('dropping multiple columns returns statements', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
          SqfColumn(name: 'col4'),
          SqfColumn(name: 'col5'),
          SqfColumn(name: 'col6'),
        ],
      );

      final List<String> actual =
          table.dropColumns(<String>['col1', 'col3', 'col5', 'col6']);
      const List<String> expected = <String>[
        'CREATE TABLE `_new_table_name` (`col2`, `col4`);',
        'INSERT INTO `_new_table_name` SELECT `col2`, `col4` FROM `table_name`;',
        'DROP TABLE `table_name`;',
        'ALTER TABLE `_new_table_name` RENAME TO `table_name`;',
      ];

      expect(actual, expected);
    });

    test('dropping one column removes column from table', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
          SqfColumn(name: 'col4'),
          SqfColumn(name: 'col5'),
          SqfColumn(name: 'col6'),
        ],
      );

      table.dropColumns(<String>['col1', 'col3', 'col5', 'col6']);
      final String actual = table.create;
      const String expected = 'CREATE TABLE `table_name` (`col2`, `col4`);';

      expect(actual, expected);
    });

    test('asserts index not primary key', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'column_name',
            properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
          ),
        ],
      );

      expect(
        () {
          table.dropColumns(<String>['column_name']);
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts index not unique', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'column_name',
            properties: <SqfColumnProperty>[SqfColumnProperty.unique],
          ),
        ],
      );

      expect(
        () {
          table.dropColumns(<String>['column_name']);
        },
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('copyWith', () {
    test('creates a new instance', () {
      final SqfColumn column = SqfColumn(
        name: 'name',
        type: SqfType.integer,
        references: SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.noAction,
          onDelete: SqfAction.noAction,
        ),
        properties: <SqfColumnProperty>[SqfColumnProperty.unique],
        defaultValue: 0,
      );

      final SqfColumn cloned = column.copyWith();

      expect(column == cloned, false);
    });

    test('creates a clone', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'name',
            type: SqfType.integer,
            references: SqfReferences(
              foreignTableName: 'foreign_table_name',
              foreignColumnName: 'foreign_column_name',
              onUpdate: SqfAction.noAction,
              onDelete: SqfAction.noAction,
            ),
            properties: <SqfColumnProperty>[SqfColumnProperty.unique],
            defaultValue: 0,
          ),
        ],
        unique: <String>['col1, col2'],
      );

      final SqfTable cloned = table.copyWith();

      expect(table.name, cloned.name);
      expect(table.unique, cloned.unique);
      expect(table.columns[0].name, cloned.columns[0].name);
      expect(table.columns[0].type, cloned.columns[0].type);
      expect(table.columns[0].properties, cloned.columns[0].properties);
      expect(table.columns[0].defaultValue, cloned.columns[0].defaultValue);
      expect(
        table.columns[0].references?.foreignTableName,
        cloned.columns[0].references?.foreignTableName,
      );
      expect(
        table.columns[0].references?.foreignColumnName,
        cloned.columns[0].references?.foreignColumnName,
      );
      expect(
        table.columns[0].references?.onUpdate,
        cloned.columns[0].references?.onUpdate,
      );
      expect(
        table.columns[0].references?.onDelete,
        cloned.columns[0].references?.onDelete,
      );
    });

    test('replaces given attributes', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'name',
            type: SqfType.integer,
            references: SqfReferences(
              foreignTableName: 'foreign_table_name',
              foreignColumnName: 'foreign_column_name',
              onUpdate: SqfAction.noAction,
              onDelete: SqfAction.noAction,
            ),
            properties: <SqfColumnProperty>[SqfColumnProperty.unique],
            defaultValue: 0,
          ),
        ],
        unique: <String>['col1, col2'],
      );

      final SqfTable cloned = table.copyWith(
        name: 'test',
        columns: <SqfColumn>[
          SqfColumn(
            name: 'test',
            type: SqfType.text,
            references: SqfReferences(
              foreignTableName: 'test',
              foreignColumnName: 'test',
              onUpdate: SqfAction.cascade,
              onDelete: SqfAction.cascade,
            ),
            properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
            defaultValue: 1,
          ),
        ],
        unique: <String>['test'],
      );

      expect(cloned.name, 'test');
      expect(cloned.unique, <String>['test']);
      expect(cloned.columns[0].name, 'test');
      expect(cloned.columns[0].type, SqfType.text);
      expect(
        cloned.columns[0].properties,
        <SqfColumnProperty>[SqfColumnProperty.notNull],
      );
      expect(cloned.columns[0].defaultValue, 1);
      expect(cloned.columns[0].references?.foreignTableName, 'test');
      expect(cloned.columns[0].references?.foreignColumnName, 'test');
      expect(cloned.columns[0].references?.onUpdate, SqfAction.cascade);
      expect(cloned.columns[0].references?.onDelete, SqfAction.cascade);
    });

    test('clones mutable members', () {
      final List<String> unique = <String>['col1'];

      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
        unique: unique,
      );

      final SqfTable cloned = table.copyWith();
      unique.add('col2');

      expect(cloned.unique, <String>['col1']);
    });
  });
}
