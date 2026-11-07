import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static const List<String> incomeCategories = [
    "Salary",
    "Business",
    "Freelancing",
    "Gift",
    "Investment",
    "Other",
  ];

  static const List<String> expenseCategories = [
    "Food",
    "Shopping",
    "Transport",
    "Education",
    "Health",
    "Entertainment",
    "Bills",
    "Other",
  ];

  static String formatAmount(double amount) {
    return NumberFormat('#,##,##0.##', 'en_IN').format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static IconData iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case "salary":
        return Icons.account_balance_wallet_outlined;
      case "business":
        return Icons.storefront_outlined;
      case "freelancing":
        return Icons.laptop_mac_outlined;
      case "gift":
        return Icons.card_giftcard_outlined;
      case "investment":
        return Icons.trending_up_rounded;
      case "food":
        return Icons.restaurant_outlined;
      case "shopping":
        return Icons.shopping_bag_outlined;
      case "transport":
        return Icons.directions_bus_outlined;
      case "education":
        return Icons.menu_book_outlined;
      case "health":
        return Icons.medical_services_outlined;
      case "entertainment":
        return Icons.movie_outlined;
      case "bills":
        return Icons.receipt_long_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  const AppConstants._();
}
