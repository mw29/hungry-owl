import 'package:flutter/material.dart';

class RiskScoreBar extends StatelessWidget {
  final int score;

  const RiskScoreBar({
    super.key,
    required this.score,
  });

  Color _getScoreColor(int score) {
    // going to have to rethink this if positive outcomes are used in the future
    if (score <= 3) {
      return Colors.green;
    } else if (score <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fillPercentage = score.clamp(1, 10) / 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fillPercentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getScoreColor(score.clamp(1, 10)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lower Risk',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Higher Risk',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
