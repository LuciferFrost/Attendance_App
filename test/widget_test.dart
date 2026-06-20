import 'package:demo4/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme exposes CraftEdge cobalt as primary color', () {
    final theme = AppTheme.light();

    expect(theme.colorScheme.primary, const Color(0xFF3B5BDB));
  });
}
