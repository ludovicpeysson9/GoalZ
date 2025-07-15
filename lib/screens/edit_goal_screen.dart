import 'package:flutter/material.dart';
import 'package:goalz/l10n/app_localizations.dart';
import '../utils/context_extension.dart';

class EditGoalScreen extends StatefulWidget {
  final Map<String, dynamic> goal;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onDelete;

  const EditGoalScreen({
    super.key,
    required this.goal,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  late TextEditingController _title;
  late TextEditingController _info;
  late int _timesPerDay;
  late bool _autoRepeat;

  @override
  void initState() {
    _title = TextEditingController(text: widget.goal['title']);
    _info = TextEditingController(text: widget.goal['info'] ?? '');
    _timesPerDay = widget.goal['timesPerDay'] ?? 1;
    _autoRepeat = widget.goal['autoRepeat'] ?? false;
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _info.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = {
      'title': _title.text.trim(),
      'info': _info.text.trim(),
      'timesPerDay': _timesPerDay,
      'checks': List.filled(_timesPerDay, false),
      'autoRepeat': _autoRepeat,
    };
    widget.onSave(updated);
    Navigator.pop(context);
  }

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.loc.t(L10nKey.deleteTheGoal)),
        content: Text(context.loc.t(L10nKey.warningDelete)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.loc.t(L10nKey.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.loc.t(L10nKey.delete), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.onDelete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.t(L10nKey.editGoalTitle)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: context.loc.t(L10nKey.goalTitle)),
            ),
            TextFormField(
              controller: _info,
              decoration: InputDecoration(labelText: context.loc.t(L10nKey.moreInfos)),
            ),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _timesPerDay,
                    items: List.generate(31, (i) {
                      final v = i + 1;
                      return DropdownMenuItem(
                        value: v,
                        child: Text('$v'),
                      );
                    }),
                    onChanged: (v) => setState(() => _timesPerDay = v ?? 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CheckboxListTile(
                    value: _autoRepeat,
                    onChanged: (v) => setState(() => _autoRepeat = v ?? false),
                    title: Text(context.loc.t(L10nKey.renew)),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(context.loc.t(L10nKey.save)),
            ),
          ],
        ),
      ),
    );
  }
}
