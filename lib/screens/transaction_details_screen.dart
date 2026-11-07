import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.transaction});

  final ExpenseTransaction transaction;

  Future<void> _editTransaction(
    BuildContext context,
    ExpenseTransaction current,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditTransactionScreen(transaction: current),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    ExpenseTransaction current,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete transaction?"),
        content: const Text(
          "Are you sure you want to delete this transaction? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete != true || current.id == null) return;

    try {
      if (!context.mounted) return;
      await context.read<TransactionProvider>().deleteTransaction(current.id!);
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Transaction deleted."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not delete the transaction. Please try again."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      debugPrint('Deleting transaction failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final current = provider.transactions.firstWhere(
          (item) => item.id == transaction.id,
          orElse: () => transaction,
        );
        final color = current.isIncome ? AppColors.income : AppColors.expense;

        return Scaffold(
          appBar: AppBar(title: const Text("Transaction Details")),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 27,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppConstants.iconForCategory(current.category),
                            color: color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          current.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${current.isIncome ? '+' : '−'}৳${AppConstants.formatAmount(current.amount)}',
                              style: TextStyle(
                                color: color,
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            current.isIncome ? 'Income' : 'Expense',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: "Transaction ID",
                          value: current.id?.toString() ?? "—",
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _DetailRow(label: "Category", value: current.category),
                        const Divider(height: 1, color: AppColors.border),
                        _DetailRow(
                          label: "Transaction type",
                          value: current.isIncome ? "Income" : "Expense",
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _DetailRow(
                          label: "Date",
                          value: AppConstants.formatDate(current.date),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editTransaction(context, current),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text("Edit"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteTransaction(context, current),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text("Delete"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: AppColors.expense,
                            side: const BorderSide(color: AppColors.expense),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
