import 'package:flutter/material.dart';

import '../models/expense_transaction.dart';
import 'add_transaction_screen.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final ExpenseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return AddTransactionScreen(transaction: transaction);
  }
}
