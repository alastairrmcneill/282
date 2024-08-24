import 'package:flutter/material.dart';

class DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;

  const DurationPickerDialog({super.key, this.initialDuration = Duration.zero});

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  int _hours = 0;
  int _minutes = 0;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumberPicker('Hours', _hours, (value) {
                setState(() {
                  if (value != null) _hours = value;
                });
              }),
              _buildNumberPicker('Minutes', _minutes, (value) {
                setState(() {
                  if (value != null) _minutes = value;
                });
              }),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final duration = Duration(
              hours: _hours,
              minutes: _minutes,
            );
            Navigator.of(context).pop(duration);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildNumberPicker(String label, int currentValue, ValueChanged<int?> onChanged) {
    return Column(
      children: [
        Text(label),
        DropdownButton<int>(
          value: currentValue,
          onChanged: onChanged,
          items: List.generate(60, (index) => index).map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString().padLeft(2, '0')),
            );
          }).toList(),
        ),
      ],
    );
  }
}
