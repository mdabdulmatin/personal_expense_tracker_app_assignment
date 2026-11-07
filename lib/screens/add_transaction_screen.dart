import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/expense_transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});

  final ExpenseTransaction? transaction;

  bool get isEditing => transaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _type;
  String? _category;
  bool _showTypeError = false;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  List<String> get _availableCategories {
    if (_type == TransactionType.income) return AppConstants.incomeCategories;
    if (_type == TransactionType.expense) return AppConstants.expenseCategories;
    return const [];
  }

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _type = transaction.type;
      _category = transaction.category;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 20),
      helpText: 'Choose transaction date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _saveTransaction() async {
    FocusScope.of(context).unfocus();
    final formIsValid = _formKey.currentState!.validate();
    final typeIsSelected = _type != null;

    if (!typeIsSelected) {
      setState(() => _showTypeError = true);
    }
    if (!formIsValid || !typeIsSelected) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        _category == null) {
      return;
    }

    setState(() => _isSaving = true);

    final transaction = ExpenseTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      category: _category!,
      type: _type!,
      date: _selectedDate,
    );

    try {
      final provider = context.read<TransactionProvider>();
      if (widget.isEditing) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? "Transaction updated successfully."
                : "Transaction added successfully.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not save the transaction. Please try again."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      debugPrint('Saving transaction failed: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Transaction" : "Add Transaction"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                "Transaction details",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Enter the details below to keep your records up to date.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Transaction type'),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _TypeChoice(
                      title: "Income",
                      icon: Icons.south_west_rounded,
                      selected: _type == TransactionType.income,
                      color: AppColors.income,
                      onTap: () {
                        setState(() {
                          _type = TransactionType.income;
                          _showTypeError = false;
                          if (!_availableCategories.contains(_category)) {
                            _category = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeChoice(
                      title: "Expense",
                      icon: Icons.north_east_rounded,
                      selected: _type == TransactionType.expense,
                      color: AppColors.expense,
                      onTap: () {
                        setState(() {
                          _type = TransactionType.expense;
                          _showTypeError = false;
                          if (!_availableCategories.contains(_category)) {
                            _category = null;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_showTypeError)
                const Padding(
                  padding: EdgeInsets.only(top: 7, left: 4),
                  child: Text(
                    "Please select Income or Expense.",
                    style: TextStyle(color: AppColors.expense, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              const _FieldLabel('Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  hintText: "Example: Monthly salary or Grocery shopping",
                  counterText: '',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a transaction title.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const _FieldLabel("Amount"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final isValid = RegExp(r'^\d*\.?\d{0,2}$')
                        .hasMatch(newValue.text);
                    return isValid ? newValue : oldValue;
                  }),
                ],
                decoration: const InputDecoration(
                  hintText: "0.00",
                  prefixText: "৳  ",
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return "Enter a valid amount greater than zero.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const _FieldLabel("Category"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_type),
                initialValue: _category,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_outlined),
                  hintText: _type == null
                      ? "Select a transaction type first"
                      : "Select a category",
                ),
                items: _availableCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: _type == null
                    ? null
                    : (value) => setState(() => _category = value),
                validator: (value) {
                  if (_type == null) return null;
                  if (value == null || !_availableCategories.contains(value)) {
                    return "Please select a category.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const _FieldLabel("Date"),
              const SizedBox(height: 8),
              InkWell(
                onTap: _chooseDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppConstants.formatDate(_selectedDate),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? "Update Transaction" : "Save Transaction",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TypeChoice extends StatelessWidget {
  const _TypeChoice({
    required this.title,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.09) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
