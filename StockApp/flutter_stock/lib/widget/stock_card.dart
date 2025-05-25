import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final String stockTopic;

  const StockCard({
    super.key, 
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.stockTopic,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = change >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPositive 
              ? Colors.green.withAlpha(120) 
              : Colors.red.withAlpha(120),   
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // Stock name, change, and price
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$symbol - $name',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${change.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                stockTopic,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
