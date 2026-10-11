import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_stories/main.dart';

void main() {
  testWidgets('App initializes successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InstagramStoriesApp());
    expect(find.byType(InstagramStoriesApp), findsOneWidget);
  });
}
