import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/expense_transaction.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;
  List<ExpenseTransaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseTransaction> get transactions =>
      List<ExpenseTransaction>.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalIncome => _transactions
      .where((transaction) => transaction.isIncome)
      .fold(0.0, (total, transaction) => total + transaction.amount);

  double get totalExpense => _transactions
      .where((transaction) => !transaction.isIncome)
      .fold(0.0, (total, transaction) => total + transaction.amount);

  double get currentBalance => totalIncome - totalExpense;

  List<ExpenseTransaction> get recentTransactions =>
      _transactions.take(5).toList(growable: false);

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _databaseHelper.getTransactions();
    } catch (error) {
      _errorMessage = 'Could not load transactions. Please try again.';
      debugPrint('Loading transactions failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    await _databaseHelper.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await _databaseHelper.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _databaseHelper.deleteTransaction(id);
    await loadTransactions();
  }
}
