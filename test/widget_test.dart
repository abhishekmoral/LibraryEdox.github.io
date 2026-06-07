import 'package:flutter_test/flutter_test.dart';
import 'package:edox_library/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('EdoxLibrary'), findsAny);
  });
}
