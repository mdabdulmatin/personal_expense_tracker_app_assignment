import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app_assignment/models/expense_transaction.dart';

void main() {
  group('ExpenseTransaction', () {
    test('converts a transaction to and from a database map', () {
      final transaction = ExpenseTransaction(
        id: 7,
        title: 'Monthly salary',
        amount: 25000,
        category: 'Salary',
        type: TransactionType.income,
        date: DateTime(2026, 11, 5),
      );

      final restored = ExpenseTransaction.fromMap(transaction.toMap());

      expect(restored.id, 7);
      expect(restored.title, 'Monthly salary');
      expect(restored.amount, 25000.0);
      expect(restored.category, 'Salary');
      expect(restored.type, TransactionType.income);
      expect(restored.date, DateTime(2026, 11, 5));
    });

    test('normalizes the saved date to a calendar date', () {
      final transaction = ExpenseTransaction(
        title: 'Lunch',
        amount: 180,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2026, 11, 5, 18, 30),
      );

      expect(transaction.toMap()['date'], '2026-11-05');
    });
  });
}
