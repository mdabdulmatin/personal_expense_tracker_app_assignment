import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_item.dart';
import 'transaction_details_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Transactions")),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.expense,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: provider.loadTransactions,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Try again"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.transactions.isEmpty) {
            return const Center(
              child: EmptyState(
                title: "No transactions found",
                message: "Transactions you add will appear here.",
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadTransactions,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: TransactionItem(
                    transaction: transaction,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TransactionDetailsScreen(
                            transaction: transaction,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
