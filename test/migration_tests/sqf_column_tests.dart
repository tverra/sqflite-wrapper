import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('column is created with required parameters', () {
      final SqfColumn column = SqfColumn(name: 'column_name');

      final String actual = column.sql;
      const String expected = 'column_name';

      expect(actual, expected);
    });

    test('column is created with type', () {
      final SqfColumn column =
          SqfColumn(name: 'column_name', type: SqfType.integer);

      final String actual = column.sql;
      const String expected = 'column_name INTEGER';

      expect(actual, expected);
    });

    test('column is created with index', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER PRIMARY KEY';

      expect(actual, expected);
    });

    test('column is created with default value', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        defaultValue: 42,
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER DEFAULT 42';

      expect(actual, expected);
    });

    test('column is created with references', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        references: SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.noAction,
          onDelete: SqfAction.cascade,
        ),
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER REFERENCES '
          'foreign_table_name(foreign_column_name) '
          'ON UPDATE NO ACTION ON DELETE CASCADE';
      expect(actual, expected);
    });

    test('column is created with indexes, default value and references', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[
          SqfColumnProperty.notNull,
          SqfColumnProperty.unique
        ],
        defaultValue: 0,
        references: SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.noAction,
          onDelete: SqfAction.cascade,
        ),
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER NOT NULL UNIQUE DEFAULT 0 '
          'REFERENCES foreign_table_name(foreign_column_name) '
          'ON UPDATE NO ACTION ON DELETE CASCADE';
      expect(actual, expected);
    });
  });

  group('sqfTypes', () {
    test('column is created with INTEGER type', () {
      final SqfColumn column =
          SqfColumn(name: 'column_name', type: SqfType.integer);

      final String actual = column.sql;
      const String expected = 'column_name INTEGER';

      expect(actual, expected);
    });

    test('column is created with TEXT type', () {
      final SqfColumn column =
          SqfColumn(name: 'column_name', type: SqfType.text);

      final String actual = column.sql;
      const String expected = 'column_name TEXT';

      expect(actual, expected);
    });

    test('column is created with BLOB type', () {
      final SqfColumn column =
          SqfColumn(name: 'column_name', type: SqfType.blob);

      final String actual = column.sql;
      const String expected = 'column_name BLOB';

      expect(actual, expected);
    });

    test('column is created with REAL type', () {
      final SqfColumn column =
          SqfColumn(name: 'column_name', type: SqfType.real);

      final String actual = column.sql;
      const String expected = 'column_name REAL';

      expect(actual, expected);
    });
  });

  group('indexes', () {
    test('column is created with PRIMARY KEY index', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER PRIMARY KEY';

      expect(actual, expected);
    });

    test('column is created with only PRIMARY KEY index', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[
          SqfColumnProperty.primaryKey,
          SqfColumnProperty.notNull,
          SqfColumnProperty.unique,
        ],
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER PRIMARY KEY';

      expect(actual, expected);
    });

    test('column is created with only PRIMARY KEY index even if out of order',
        () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[
          SqfColumnProperty.unique,
          SqfColumnProperty.notNull,
          SqfColumnProperty.primaryKey,
        ],
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER PRIMARY KEY';

      expect(actual, expected);
    });

    test('column is created with NOT NULL index', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[SqfColumnProperty.notNull],
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER NOT NULL';

      expect(actual, expected);
    });

    test('column is created with UNIQUE index', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        properties: <SqfColumnProperty>[SqfColumnProperty.unique],
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER UNIQUE';

      expect(actual, expected);
    });
  });

  test('column is created with NOT NULL and UNIQUE indexes', () {
    final SqfColumn column = SqfColumn(
      name: 'column_name',
      type: SqfType.integer,
      properties: <SqfColumnProperty>[
        SqfColumnProperty.notNull,
        SqfColumnProperty.unique
      ],
    );

    final String actual = column.sql;
    const String expected = 'column_name INTEGER NOT NULL UNIQUE';

    expect(actual, expected);
  });

  test('column is created with indexes in the correct order', () {
    final SqfColumn column = SqfColumn(
      name: 'column_name',
      type: SqfType.integer,
      properties: <SqfColumnProperty>[
        SqfColumnProperty.unique,
        SqfColumnProperty.notNull
      ],
    );

    final String actual = column.sql;
    const String expected = 'column_name INTEGER NOT NULL UNIQUE';

    expect(actual, expected);
  });

  group('default value', () {
    test('default value is correct for INTEGER', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.integer,
        defaultValue: "1",
      );

      final String actual = column.sql;
      const String expected = 'column_name INTEGER DEFAULT 1';

      expect(actual, expected);
    });

    test('default value is correct for TEXT', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.text,
        defaultValue: 1,
      );

      final String actual = column.sql;
      const String expected = 'column_name TEXT DEFAULT "1"';

      expect(actual, expected);
    });

    test('default value is correct for BLOB', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.blob,
        defaultValue: 1,
      );

      final String actual = column.sql;
      const String expected = 'column_name BLOB DEFAULT (1)';

      expect(actual, expected);
    });

    test('default value is correct for REAL', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.real,
        defaultValue: "1",
      );

      final String actual = column.sql;
      const String expected = 'column_name REAL DEFAULT 1';

      expect(actual, expected);
    });

    test('default value is correct for NUMERIC', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        type: SqfType.numeric,
        defaultValue: "1",
      );

      final String actual = column.sql;
      const String expected = 'column_name NUMERIC DEFAULT 1';

      expect(actual, expected);
    });

    test('default value is correct for int', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        defaultValue: 1,
      );

      final String actual = column.sql;
      const String expected = 'column_name DEFAULT 1';

      expect(actual, expected);
    });

    test('default value is correct for String', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        defaultValue: "1",
      );

      final String actual = column.sql;
      const String expected = 'column_name DEFAULT "1"';

      expect(actual, expected);
    });

    test('default value is correct for double', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        defaultValue: 1.0,
      );

      final String actual = column.sql;
      const String expected = 'column_name DEFAULT 1.0';

      expect(actual, expected);
    });

    test('default value is treated as a blob for any other type', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        defaultValue: SqfColumn(name: 'test'),
      );

      final String actual = column.sql;
      const String expected = "column_name DEFAULT (Instance of 'SqfColumn')";

      expect(actual, expected);
    });

    test('default value is correct for SqfColumnValue', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        defaultValue: SqfColumnValue.currentDate,
      );

      final String actual = column.sql;
      const String expected = "column_name DEFAULT CURRENT_DATE";

      expect(actual, expected);
    });

    test('default value is correct for function', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        defaultValue: SqfFunction.abs("-42"),
      );

      final String actual = column.sql;
      const String expected = "column_name DEFAULT (ABS(-42))";

      expect(actual, expected);
    });
  });

  group('drop', () {
    test('drop column returns statement', () {
      final SqfColumn column = SqfColumn(name: 'column_name');

      final String actual = column.drop('table_name');
      const String expected = 'ALTER TABLE table_name DROP COLUMN column_name;';

      expect(actual, expected);
    });

    test('asserts index not primary key', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
      );

      expect(() {
        column.drop('table_name');
      }, throwsA(isA<AssertionError>()));
    });

    test('asserts index not unique', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        properties: <SqfColumnProperty>[SqfColumnProperty.unique],
      );

      expect(() {
        column.drop('table_name');
      }, throwsA(isA<AssertionError>()));
    });
  });

  group('rename', () {
    test('rename column returns statement', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
      );

      final String actual = column.rename('table_name', 'new_col_name');
      const String expected =
          'ALTER TABLE table_name RENAME COLUMN column_name TO new_col_name;';

      expect(actual, expected);
    });

    test('renaming column changes column name', () {
      final SqfColumn column = SqfColumn(
        name: 'column_name',
        properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
      );

      column.rename('table_name', 'new_col_name');

      expect(column.name, 'new_col_name');
    });
  });
}
