import 'package:flutter/material.dart';
import '/services/api_service.dart';

class EditBarberPopup extends StatefulWidget {
  final Map<String, dynamic> barber;
  final int ownerId;
  final VoidCallback onUpdated;

  const EditBarberPopup({
    super.key,
    required this.barber,
    required this.ownerId,
    required this.onUpdated,
  });

  @override
  State<EditBarberPopup> createState() => _EditBarberPopupState();
}

class _EditBarberPopupState extends State<EditBarberPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;
  bool isAvailable = true;
  bool everyday = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.barber['barber_name']);
    startCtrl = TextEditingController(text: widget.barber['start_time']);
    endCtrl = TextEditingController(text: widget.barber['end_time']);
    isAvailable = widget.barber['is_available'] ?? true;
    everyday = widget.barber['everyday'] ?? true;
  }

  Future<void> updateBarber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final body = {
      "barber_name": nameCtrl.text.trim(),
      "start_time": startCtrl.text.trim(),
      "end_time": endCtrl.text.trim(),
      "is_available": isAvailable,
      "everyday": everyday,
    };

    final barberId = widget.barber['barber_id'];

    final success = await ApiService.updateBarber(barberId, widget.ownerId, body);

    if (success) {
      widget.onUpdated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update barber")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Barber"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Barber Name"),
                validator: (v) => v!.isEmpty ? "Enter barber name" : null,
              ),
              TextFormField(
                controller: startCtrl,
                decoration: const InputDecoration(labelText: "Start Time (HH:MM)"),
                validator: (v) => v!.isEmpty ? "Enter start time" : null,
              ),
              TextFormField(
                controller: endCtrl,
                decoration: const InputDecoration(labelText: "End Time (HH:MM)"),
                validator: (v) => v!.isEmpty ? "Enter end time" : null,
              ),
              SwitchListTile(
                value: isAvailable,
                title: const Text("Is Available"),
                onChanged: (val) => setState(() => isAvailable = val),
              ),
              SwitchListTile(
                value: everyday,
                title: const Text("Everyday"),
                onChanged: (val) => setState(() => everyday = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading ? null : updateBarber,
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Update"),
        ),
      ],
    );
  }
}
