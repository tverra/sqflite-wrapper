part of sqflite_wrapper;

class SqfFunction {
  String _sql;

  SqfFunction(String function, {String alias}) {
    final StringBuffer buffer = StringBuffer();

    if (function == null) {
      buffer.write('NULL');
    } else {
      buffer.write(function);
    }
    if (alias != null) buffer.write(' AS $alias');

    _sql = buffer.toString();
  }

  SqfFunction.abs(String param, {String alias}) {
    _buildSql('ABS', [param], alias);
  }

  SqfFunction.avg(String param, {String alias}) {
    _buildSql('AVG', [param], alias);
  }

  SqfFunction.count(String param, {String alias}) {
    _buildSql('COUNT', [param], alias);
  }

  SqfFunction.max(String param, {String alias}) {
    _buildSql('MAX', [param], alias);
  }

  SqfFunction.min(String param, {String alias}) {
    _buildSql('MIN', [param], alias);
  }

  SqfFunction.random({String alias}) {
    _buildSql('RANDOM', [], alias);
  }

  SqfFunction.round(String param, {int decimalPlaces, String alias}) {
    final List<String> params = [param];
    if (decimalPlaces != null) params.add(decimalPlaces.toString());

    _buildSql('ROUND', params, alias);
  }

  SqfFunction.sum(String param, {String alias}) {
    _buildSql('SUM', [param], alias);
  }

  SqfFunction.coalesce(List<String> params, {String alias}) {
    if (params == null) params = <String>[];
    _buildSql('COALESCE', params, alias);
  }

  String get sql {
    return _sql;
  }

  void _buildSql(String function, List<String> params, String alias) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('$function(');

    for (int i = 0; i < params.length; i++) {
      if (i > 0) buffer.write(', ');
      if (params[i] == null) {
        buffer.write('NULL');
      } else {
        buffer.write(params[i]);
      }
    }
    buffer.write(')');
    if (alias != null) buffer.write(' AS $alias');

    _sql = buffer.toString();
  }
}