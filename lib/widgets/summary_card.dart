import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.isMain = false,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = amount < 0
        ? "-৳${AppConstants.formatAmount(amount.abs())}"
        : "৳${AppConstants.formatAmount(amount)}";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMain ? 20 : 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isMain ? null : Border.all(color: AppColors.border),
        boxShadow: isMain
            ? [
                BoxShadow(
                  color: AppColors.balanceCard.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isMain
                      ? Colors.white.withValues(alpha: 0.13)
                      : color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: isMain ? Colors.white : color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMain
                        ? Colors.white.withValues(alpha: 0.78)
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formattedAmount,
              maxLines: 1,
              style: TextStyle(
                color: isMain ? Colors.white : AppColors.textPrimary,
                fontSize: isMain ? 27 : 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
