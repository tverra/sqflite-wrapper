part of '../../sqflite_wrapper.dart';

class SqfFunction {
  late final String sql;

  SqfFunction(String function, {String? alias, bool escapeNames = true}) {
    final StringBuffer buffer = StringBuffer();

    buffer.write(function);

    if (escapeNames) {
      if (alias != null) buffer.write(' AS `$alias`');
    } else {
      if (alias != null) buffer.write(' AS $alias');
    }

    sql = buffer.toString();
  }

  SqfFunction.abs(String param, {String? alias, bool escapeNames = true}) {
    _buildSql('ABS', <String>[param], alias, escapeNames);
  }

  SqfFunction.avg(String param, {String? alias, bool escapeNames = true}) {
    _buildSql('AVG', <String>[param], alias, escapeNames);
  }

  SqfFunction.count(String param, {String? alias, bool escapeNames = true}) {
    _buildSql('COUNT', <String>[param], alias, escapeNames);
  }

  SqfFunction.max(String param, {String? alias, bool escapeNames = true}) {
    _buildSql('MAX', <String>[param], alias, escapeNames);
  }

  SqfFunction.min(String param, {String? alias, bool escapeNames = true}) {
    _buildSql('MIN', <String>[param], alias, escapeNames);
  }

  SqfFunction.random({String? alias, bool escapeNames = true}) {
    _buildSql('RANDOM', <String>[], alias, escapeNames);
  }

  SqfFunction.round(
    String param, {
    int? decimalPlaces,
    String? alias,
    bool escapeNames = true,
  }) {
    final List<String> params = <String>[
      if (escapeNames) '`$param`' else param,
    ];

    alias = alias == null ? null : (escapeNames ? '`$alias`' : alias);

    if (decimalPlaces != null) params.add(decimalPlaces.toString());

    _buildSql('ROUND', params, alias, false);
  }

  SqfFunction.sum(String param, {String? alias, bool escapeNames = true}) {
    _buildSql('SUM', <String>[param], alias, escapeNames);
  }

  SqfFunction.coalesce(
    List<String> params, {
    String? alias,
    bool escapeNames = true,
  }) {
    _buildSql('COALESCE', params, alias, escapeNames);
  }

  void _buildSql(
    String function,
    List<String> params, [
    String? alias,
    bool escapeNames = true,
  ]) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('$function(');

    for (int i = 0; i < params.length; i++) {
      if (i > 0) buffer.write(', ');
      if (escapeNames) {
        buffer.write('`${params[i]}`');
      } else {
        buffer.write(params[i]);
      }
    }
    buffer.write(')');
    if (alias != null) {
      if (escapeNames) {
        buffer.write(' AS `$alias`');
      } else {
        buffer.write(' AS $alias');
      }
    }

    sql = buffer.toString();
  }
}
