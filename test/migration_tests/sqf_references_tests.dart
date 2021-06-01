import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('sql', () {
    test('reference is created with all arguments', () {
      final SqfReferences references = SqfReferences(
        foreignTableName: 'foreign_table_name',
        foreignColumnName: 'foreign_column_name',
        onUpdate: SqfAction.noAction,
        onDelete: SqfAction.setDefault,
      );

      final String actual = references.sql(columnName: 'column_name');
      const String expected =
          'REFERENCES `foreign_table_name`(`foreign_column_name`) '
          'ON UPDATE NO ACTION ON DELETE SET DEFAULT';

      expect(actual, expected);
    });

    test('reference is created with only required arguments', () {
      final SqfReferences references = SqfReferences(
        foreignTableName: 'foreign_table_name',
        foreignColumnName: 'foreign_column_name',
      );

      final String actual = references.sql(columnName: 'column_name');
      const String expected =
          'REFERENCES `foreign_table_name`(`foreign_column_name`)';

      expect(actual, expected);
    });

    test('reference is created with only onUpdate', () {
      final SqfReferences references = SqfReferences(
        foreignTableName: 'foreign_table_name',
        foreignColumnName: 'foreign_column_name',
        onUpdate: SqfAction.restrict,
      );

      final String actual = references.sql(columnName: 'column_name');
      const String expected =
          'REFERENCES `foreign_table_name`(`foreign_column_name`) '
          'ON UPDATE RESTRICT';

      expect(actual, expected);
    });

    test('reference is created with only onDelete', () {
      final SqfReferences references = SqfReferences(
        foreignTableName: 'foreign_table_name',
        foreignColumnName: 'foreign_column_name',
        onDelete: SqfAction.setNull,
      );

      final String actual = references.sql(columnName: 'column_name');
      const String expected =
          'REFERENCES `foreign_table_name`(`foreign_column_name`) '
          'ON DELETE SET NULL';

      expect(actual, expected);
    });

    group('sqfActions', () {
      test('reference is created with NO ACTION', () {
        final SqfReferences references = SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.noAction,
          onDelete: SqfAction.noAction,
        );

        final String actual = references.sql(columnName: 'column_name');
        const String expected =
            'REFERENCES `foreign_table_name`(`foreign_column_name`) '
            'ON UPDATE NO ACTION ON DELETE NO ACTION';

        expect(actual, expected);
      });

      test('reference is created with RESTRICT', () {
        final SqfReferences references = SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.restrict,
          onDelete: SqfAction.restrict,
        );

        final String actual = references.sql(columnName: 'column_name');
        const String expected =
            'REFERENCES `foreign_table_name`(`foreign_column_name`) '
            'ON UPDATE RESTRICT ON DELETE RESTRICT';

        expect(actual, expected);
      });

      test('reference is created with SET NULL', () {
        final SqfReferences references = SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.setNull,
          onDelete: SqfAction.setNull,
        );

        final String actual = references.sql(columnName: 'column_name');
        const String expected =
            'REFERENCES `foreign_table_name`(`foreign_column_name`) '
            'ON UPDATE SET NULL ON DELETE SET NULL';

        expect(actual, expected);
      });

      test('reference is created with SET DEFAULT', () {
        final SqfReferences references = SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.setDefault,
          onDelete: SqfAction.setDefault,
        );

        final String actual = references.sql(columnName: 'column_name');
        const String expected =
            'REFERENCES `foreign_table_name`(`foreign_column_name`) '
            'ON UPDATE SET DEFAULT ON DELETE SET DEFAULT';

        expect(actual, expected);
      });

      test('reference is created with CASCADE', () {
        final SqfReferences references = SqfReferences(
          foreignTableName: 'foreign_table_name',
          foreignColumnName: 'foreign_column_name',
          onUpdate: SqfAction.cascade,
          onDelete: SqfAction.cascade,
        );

        final String actual = references.sql(columnName: 'column_name');
        const String expected =
            'REFERENCES `foreign_table_name`(`foreign_column_name`) '
            'ON UPDATE CASCADE ON DELETE CASCADE';

        expect(actual, expected);
      });
    });
  });
}
