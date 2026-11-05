import 'package:flutter_test/flutter_test.dart';
import 'package:urban_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UrbanMobileApp(isLoggedIn: false));
    expect(find.text('PUROJAS'), findsOneWidget);
  });
}
