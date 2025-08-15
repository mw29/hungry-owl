import 'package:flutter/material.dart';
import 'package:hungryowl/services/utils.dart';
import 'package:hungryowl/types/internal_types.dart';
import 'package:hungryowl/widgets/food_data/risk_score_bar.dart';

class SymptomRiskCard extends StatefulWidget {
  final SymptomInfo symptom;

  const SymptomRiskCard({
    super.key,
    required this.symptom,
  });

  @override
  State<SymptomRiskCard> createState() => _SymptomRiskCardState();
}

class _SymptomRiskCardState extends State<SymptomRiskCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            capitalizedTitle(widget.symptom.symptomName),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          RiskScoreBar(score: widget.symptom.symptomRiskScore),
          const SizedBox(height: 5),
          if (_showDetails)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (widget.symptom.information)
                    .map((info) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Expanded(
                                child: Text(
                                  info,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
              child: Text(
                _showDetails ? 'Show Less' : 'Learn More',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
