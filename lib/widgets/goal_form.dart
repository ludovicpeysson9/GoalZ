import 'package:flutter/material.dart';
import 'package:goalz/l10n/app_localizations.dart';
import '../utils/context_extension.dart';

class GoalForm extends StatefulWidget {
  final void Function(
    String title,
    String? info,
    int timesPerDay,
    bool autoRepeat,
  )
  onSubmit;
  final void Function(bool)? onFocusChange;

  const GoalForm({super.key, required this.onSubmit, this.onFocusChange});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  int _timesPerDay = 1;
  bool _autoRepeat = false;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text.trim(),
        _infoController.text.trim().isEmpty
            ? null
            : _infoController.text.trim(),
        _timesPerDay,
        _autoRepeat
      );
      _titleController.clear();
      _infoController.clear();
      widget.onFocusChange?.call(false);
      setState(() {
        _timesPerDay = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.loc.t(L10nKey.goalTitle),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? context.loc.t(L10nKey.titleRequired) : null,
            ),
            TextFormField(
              controller: _infoController,
              decoration: InputDecoration(
                labelText: context.loc.t(L10nKey.moreInfos),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _timesPerDay,
                    items: List.generate(31, (i) {
                      final value = i + 1;
                      return DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
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

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: Text(context.loc.t(L10nKey.addTheGoal)),
            ),
          ],
        ),
      ),
    );
  }
}
