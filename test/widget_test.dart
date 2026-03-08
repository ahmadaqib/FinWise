import 'package:finwise/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FinWiseApp()));

    // Verify that the Beranda screen's title exists
    expect(find.text('Beranda'), findsWidgets);
  });
}
