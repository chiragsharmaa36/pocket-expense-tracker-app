import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/expense.dart';

class CustomDetailHeader extends StatelessWidget {
  final Expense expense;

  const CustomDetailHeader({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            expense.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\u{20B9}${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Category', expense.category),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Date', 
            expense.timestamp.toLocal().toString().split('.')[0],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                expense.isSynced ? Icons.cloud_done : Icons.cloud_off,
                color: expense.isSynced ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                expense.isSynced ? "Synced securely" : "Pending sync...",
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
