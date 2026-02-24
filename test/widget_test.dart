import 'package:flutter_test/flutter_test.dart';
import 'package:food_budget_app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodBudgetApp());
    expect(find.text('Havi Étkezési Költségvetés'), findsOneWidget);
  });
}
