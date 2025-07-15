import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CalendarStampType { day, yearMonth }

class CustomCalendarStamp extends StatelessWidget {
  final CalendarStampType type;

  const CustomCalendarStamp({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String topText;
    String bottomText;

    switch (type) {
      case CalendarStampType.day:
        topText = DateFormat('MMM').format(now).toUpperCase(); 
        bottomText = DateFormat('dd').format(now); 
        break;
      case CalendarStampType.yearMonth:
        topText = DateFormat('MMM').format(now).toUpperCase(); 
        bottomText = DateFormat('yyyy').format(now);
        break;
    }

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 0),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                topText,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'ArchiveBlack',
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              bottomText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'KumarOne',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
