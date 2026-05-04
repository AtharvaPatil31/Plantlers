import 'package:flutter_test/flutter_test.dart';
import 'package:plantlers/app.dart';
import 'package:plantlers/core/di/injection_container.dart';

void main() {
  setUpAll(() async {
    await initDependencies();
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    // App should render — onboarding or login depending on state
    expect(find.byType(App), findsOneWidget);
  });
}
