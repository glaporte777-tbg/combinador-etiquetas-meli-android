import 'package:flutter_test/flutter_test.dart';
import 'package:combinador_etiquetas_meli/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CombinadorApp());
    expect(find.text('Combinar Etiquetas'), findsOneWidget);
  });
}
