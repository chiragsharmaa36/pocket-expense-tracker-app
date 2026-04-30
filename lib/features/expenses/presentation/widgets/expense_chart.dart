import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> data;
  final double maxY;

  const ExpenseChart({
    super.key,
    required this.data,
  }) : maxY = 0; // We'll calculate it in the build method

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data for this period',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
      );
    }

    final maxVal = data.values.isEmpty
        ? 0.0
        : data.values.reduce((a, b) => a > b ? a : b);
    final effectiveMaxY = maxVal == 0 ? 1.0 : maxVal;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Spent',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\u{20B9}${data.values.fold(0.0, (sum, val) => sum + val).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.entries.map((entry) {
                return _Bar(
                  label: entry.key,
                  value: entry.value,
                  maxY: effectiveMaxY,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final double maxY;

  const _Bar({
    required this.label,
    required this.value,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxY == 0 ? 0.0 : value / maxY;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: FractionallySizedBox(
              heightFactor: fraction,
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBF5AF2), // Apple Dark Mode Purple
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.systemGrey2,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
