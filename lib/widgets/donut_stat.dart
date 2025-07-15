import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const Color pastelMint    = Color.fromARGB(255, 89, 192, 77); 
const Color pastelApricot = Color.fromARGB(255, 239, 220, 162); 
const double _radius      = 25;                

class DonutStat extends StatelessWidget {
  final int accomplished;
  final int ignored;

  const DonutStat({
    super.key,
    required this.accomplished,
    required this.ignored,
  });

  @override
  Widget build(BuildContext context) {
    final int total      = accomplished + ignored;
    final double percent = total == 0 ? 0 : accomplished * 100 / total;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              centerSpaceRadius: 38,
              sectionsSpace: 0,
              sections: [
                PieChartSectionData(
                  value: accomplished.toDouble(),   
                  color: pastelMint,
                  radius: _radius,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: ignored.toDouble(),
                  color: pastelApricot,
                  radius: _radius,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        Text(
          '${percent.round()} %',
          style: const TextStyle(
            fontFamily: 'ArchiveBlack',
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}