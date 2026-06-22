import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'OPENWEATHER_API_KEY=test_key');
  });

  testWidgets('App loads and shows initial text', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WeatherApp()));
    await tester.pump();

    expect(find.text('Zahra Weather'), findsOneWidget);
    expect(find.text('Search your city...'), findsOneWidget);
  });
}
