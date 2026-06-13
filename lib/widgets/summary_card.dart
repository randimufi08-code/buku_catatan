import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';

class SummaryCard extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String amount;

  const SummaryCard({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

