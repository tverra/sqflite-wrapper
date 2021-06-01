import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
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
          'CREATE TABLE table_name (id INTEGER PRIMARY KEY);';

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
          'CREATE TABLE table_name (col1 INTEGER PRIMARY KEY, '
          'col2 TEXT NOT NULL, '
          'col3 BLOB UNIQUE, '
          'col4 REAL, '
          'col5 INTEGER REFERENCES f_table(f_col) '
          'ON UPDATE SET NULL ON DELETE RESTRICT);';

      expect(actual, expected);
    });

    test('at least one column is required', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(() {
        table.create;
      }, throwsA(isA<AssertionError>()));
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
      const String expected = 'DROP TABLE table_name;';

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
          'ALTER TABLE table_name RENAME TO new_table_name;';

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
          'ALTER TABLE table_name RENAME COLUMN col2 TO new_col;';

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
      const String expected = 'CREATE TABLE table_name (col1, new_col, col3);';

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
      const String expected = 'ALTER TABLE table_name ADD COLUMN col4;';

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
          'CREATE TABLE table_name (col1, col2, col3, col4);';

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

      expect(() {
        table.addColumn(SqfColumn(name: 'col2'));
      }, throwsA(isA<AssertionError>()));
    });

    test('asserts index not primary key', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(() {
        table.addColumn(SqfColumn(
          name: 'col2',
          properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
        ));
      }, throwsA(isA<AssertionError>()));
    });

    test('asserts index not unique', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(() {
        table.addColumn(SqfColumn(
          name: 'col2',
          properties: <SqfColumnProperty>[SqfColumnProperty.unique],
        ));
      }, throwsA(isA<AssertionError>()));
    });

    test('asserts not null default value if constraint is NOT NULL', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(() {
        table.addColumn(SqfColumn(
          name: 'col2',
          properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
        ));
      }, throwsA(isA<AssertionError>()));

      expect(() {
        table.addColumn(SqfColumn(
          name: 'col2',
          defaultValue: SqfColumnValue.nullValue,
          properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
        ));
      }, throwsA(isA<AssertionError>()));
    });

    test('asserts invalid default value', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(() {
        table.addColumn(SqfColumn(
          name: 'col2',
          defaultValue: SqfColumnValue.currentTimestamp,
        ));
      }, throwsA(isA<AssertionError>()));
    });

    test('asserts default value not an expression', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[],
      );

      expect(() {
        table.addColumn(SqfColumn(
          name: 'col2',
          defaultValue: SqfFunction.max("1"),
        ));
      }, throwsA(isA<AssertionError>()));
    });
  });

  group('drop column', () {
    test('drop column returns statement', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      final String actual = table.dropColumn('col2');
      const String expected = 'ALTER TABLE table_name DROP COLUMN col2;';

      expect(actual, expected);
    });

    test('drop column removes column from table', () {
      final SqfTable table = SqfTable(
        name: 'table_name',
        columns: <SqfColumn>[
          SqfColumn(name: 'col1'),
          SqfColumn(name: 'col2'),
          SqfColumn(name: 'col3'),
        ],
      );

      table.dropColumn('col2');
      final String actual = table.create;
      const String expected = 'CREATE TABLE table_name (col1, col3);';

      expect(actual, expected);
    });
  });
}
