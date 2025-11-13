import 'package:flutter/material.dart';
import '/services/api_service.dart';

class EditMenuPopup extends StatefulWidget {
  final Map<String, dynamic> menu;
  final int ownerId;
  final VoidCallback onUpdated;

  const EditMenuPopup({
    super.key,
    required this.menu,
    required this.ownerId,
    required this.onUpdated,
  });

  @override
  State<EditMenuPopup> createState() => _EditMenuPopupState();
}

class _EditMenuPopupState extends State<EditMenuPopup> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController durationCtrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.menu["service_name"]);
    descCtrl = TextEditingController(text: widget.menu["description"]);
    priceCtrl = TextEditingController(text: widget.menu["price"].toString());
    durationCtrl = TextEditingController(text: widget.menu["duration_minutes"].toString());
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final msg = await ApiService.updateMenu(
      menuId: widget.menu["menu_id"],
      ownerId: widget.ownerId,
      serviceName: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: int.parse(priceCtrl.text.trim()),
      duration: int.parse(durationCtrl.text.trim()),
    );

    setState(() => isLoading = false);

    Navigator.of(context, rootNavigator: true).pop(); // close popup

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );

    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Menu Item"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Service Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Duration (minutes)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: isLoading ? null : submit,
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Update"),
        ),
      ],
    );
  }
}
