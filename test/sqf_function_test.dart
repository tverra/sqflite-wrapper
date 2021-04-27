import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('constructor', () {
    test('custom function can be set in constructor', () {
      final SqfFunction function = SqfFunction('WHATEVER(param)');
      expect(function.sql, 'WHATEVER(param)');
    });

    test('alias can be added in constructor', () {
      final SqfFunction function = SqfFunction('FUNC(*)', alias: 'alias');
      expect(function.sql, 'FUNC(*) AS alias');
    });
  });

  group('abs', () {
    test('abs function is created', () {
      final SqfFunction function = SqfFunction.abs('parameter');
      expect(function.sql, 'ABS(parameter)');
    });

    test('abs function is created with alias', () {
      final SqfFunction function = SqfFunction.abs('parameter', alias: 'alias');
      expect(function.sql, 'ABS(parameter) AS alias');
    });
  });

  group('avg', () {
    test('avg function is created', () {
      final SqfFunction function = SqfFunction.avg('parameter');
      expect(function.sql, 'AVG(parameter)');
    });

    test('avg function is created with alias', () {
      final SqfFunction function = SqfFunction.avg('parameter', alias: 'alias');
      expect(function.sql, 'AVG(parameter) AS alias');
    });
  });

  group('count', () {
    test('count function is created', () {
      final SqfFunction function = SqfFunction.count('parameter');
      expect(function.sql, 'COUNT(parameter)');
    });

    test('count function is created with alias', () {
      final SqfFunction function =
          SqfFunction.count('parameter', alias: 'alias');
      expect(function.sql, 'COUNT(parameter) AS alias');
    });
  });

  group('max', () {
    test('max function is created', () {
      final SqfFunction function = SqfFunction.max('parameter');
      expect(function.sql, 'MAX(parameter)');
    });

    test('max function is created with alias', () {
      final SqfFunction function = SqfFunction.max('parameter', alias: 'alias');
      expect(function.sql, 'MAX(parameter) AS alias');
    });
  });

  group('min', () {
    test('min function is created', () {
      final SqfFunction function = SqfFunction.min('parameter');
      expect(function.sql, 'MIN(parameter)');
    });

    test('min function is created with alias', () {
      final SqfFunction function = SqfFunction.min('parameter', alias: 'alias');
      expect(function.sql, 'MIN(parameter) AS alias');
    });
  });

  group('random', () {
    test('random function is created', () {
      final SqfFunction function = SqfFunction.random();
      expect(function.sql, 'RANDOM()');
    });

    test('random function is created with alias', () {
      final SqfFunction function = SqfFunction.random(alias: 'alias');
      expect(function.sql, 'RANDOM() AS alias');
    });
  });

  group('round', () {
    test('round function is created', () {
      final SqfFunction function = SqfFunction.round('parameter');
      expect(function.sql, 'ROUND(parameter)');
    });

    test('round function is created with optional parameter', () {
      final SqfFunction function =
          SqfFunction.round('parameter', decimalPlaces: 4);
      expect(function.sql, 'ROUND(parameter, 4)');
    });

    test('round function is created with alias', () {
      final SqfFunction function =
          SqfFunction.round('parameter', alias: 'alias');
      expect(function.sql, 'ROUND(parameter) AS alias');
    });
  });

  group('sum', () {
    test('sum function is created', () {
      final SqfFunction function = SqfFunction.sum('parameter');
      expect(function.sql, 'SUM(parameter)');
    });

    test('sum function is created with alias', () {
      final SqfFunction function = SqfFunction.sum('parameter', alias: 'alias');
      expect(function.sql, 'SUM(parameter) AS alias');
    });
  });

  group('coalesce', () {
    test('coalesce function is created', () {
      final SqfFunction function =
          SqfFunction.coalesce(<String>['param1', 'param2']);
      expect(function.sql, 'COALESCE(param1, param2)');
    });

    test('coalesce function is created with one parameter', () {
      final SqfFunction function = SqfFunction.coalesce(<String>['param1']);
      expect(function.sql, 'COALESCE(param1)');
    });

    test('coalesce function is created with no parameters', () {
      final SqfFunction function = SqfFunction.coalesce(<String>[]);
      expect(function.sql, 'COALESCE()');
    });

    test('coalesce function is created with alias', () {
      final SqfFunction function =
          SqfFunction.coalesce(<String>['param1', 'param2'], alias: 'alias');
      expect(function.sql, 'COALESCE(param1, param2) AS alias');
    });
  });
}
