
import 'package:flutter_test/flutter_test.dart';
import 'package:agrismart/main.dart';

void main() {
  test('AgriSmartApp est correctement créée', () {
    const app = AgriSmartApp();

    expect(app, isA<AgriSmartApp>());
  });
}
