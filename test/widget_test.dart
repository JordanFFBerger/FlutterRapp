import 'package:flutter_test/flutter_test.dart';
import 'package:morning_message/main.dart';

void main() {
  testWidgets('shows one button that can be tapped', (tester) async {
    await tester.pumpWidget(const SingleButtonApp());

    expect(find.text('Button'), findsOneWidget);
    expect(find.byType(SingleButtonPage), findsOneWidget);

    await tester.tap(find.text('Button'));
    await tester.pump();

    expect(find.text('Button'), findsOneWidget);
  });
}
