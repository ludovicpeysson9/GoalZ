import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final String? info;
  final int timesPerDay;
  final List<bool> checks;
  final void Function(int index, bool value) onCheckChanged;
  final VoidCallback? onEdit; 

  const GoalCard({
    super.key,
    required this.title,
    this.info,
    required this.timesPerDay,
    required this.checks,
    required this.onCheckChanged,
    this.onEdit, 
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = checks.every((c) => c);

    return Card(
      elevation: 1,
      color: isComplete
          ? const Color.fromRGBO(49, 233, 129, 0.4)
          : const Color.fromRGBO(255, 255, 255, 0.4),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 45), 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  padding: const EdgeInsets.only(left: 30.0),
                  constraints: const BoxConstraints(),
                  onPressed: onEdit,
                ),
              ],
            ),
            if (info != null && info!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  info!,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6.0, left: 30.0),
                child: Wrap(
                  spacing: 2,
                  children: List.generate(timesPerDay, (index) {
                    return Checkbox(
                      value: checks[index],
                      onChanged: (val) => onCheckChanged(index, val ?? false),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
