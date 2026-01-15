import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final String? initialVehicleId;
  const ReportDialog({super.key, this.initialVehicleId});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedIssue;
  late TextEditingController _vehicleIdController;

  @override
  void initState() {
    super.initState();
    _vehicleIdController = TextEditingController(
        text: widget.initialVehicleId ??
            "Bus-502"); // Use passed ID or demo default
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _issues = [
    {'id': 'FULL', 'label': 'Vehicle Full', 'icon': Icons.group_off},
    {'id': 'DELAYED', 'label': 'Delayed > 15m', 'icon': Icons.timer_off},
    {
      'id': 'BREAKDOWN',
      'label': 'Vehicle Breakdown',
      'icon': Icons.build_circle
    },
    {'id': 'AC_ISSUE', 'label': 'AC Not Working', 'icon': Icons.ac_unit},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Issue'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select the issue you are facing:"),
            const SizedBox(height: 16),
            ..._issues.map((issue) => RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(issue['icon'], size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(issue['label']),
                    ],
                  ),
                  value: issue['id'],
                  groupValue: _selectedIssue,
                  onChanged: (value) {
                    setState(() => _selectedIssue = value);
                  },
                  contentPadding: EdgeInsets.zero,
                )),
            const SizedBox(height: 16),
            TextField(
              controller: _vehicleIdController,
              enabled: widget.initialVehicleId == null, // Lock if pre-filled
              decoration: const InputDecoration(
                labelText: 'Vehicle ID (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedIssue == null
              ? null
              : () {
                  Navigator.pop(context, {
                    'type': _selectedIssue,
                    'vehicle_id': _vehicleIdController.text,
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit Report'),
        ),
      ],
    );
  }
}
