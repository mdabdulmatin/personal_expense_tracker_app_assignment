class ExpenseTransaction {
  const ExpenseTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type;
  final DateTime date;

  bool get isIncome => type == TransactionType.income;

  Map<String, Object?> toMap() {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return {
      "id": id,
      "title": title.trim(),
      "amount": amount,
      "category": category,
      "type": type,
      "date": _dateToDatabaseValue(normalizedDate),
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map["id"] as int?,
      title: map["title"] as String,
      amount: (map["amount"] as num).toDouble(),
      category: map["category"] as String,
      type: map["type"] as String,
      date: DateTime.parse(map["date"] as String),
    );
  }

  static String _dateToDatabaseValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "${date.year}-$month-$day";
  }
}

class TransactionType {
  static const income = "income";
  static const expense = "expense";

  const TransactionType._();
}
