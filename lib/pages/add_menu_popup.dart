import 'package:flutter/material.dart';
import '/services/api_service.dart';

class AddMenuPopup extends StatefulWidget {
  final int shopId;
  final int ownerId;
  final VoidCallback onMenuAdded;

  const AddMenuPopup({
    super.key,
    required this.shopId,
    required this.ownerId,
    required this.onMenuAdded,
  });

  @override
  State<AddMenuPopup> createState() => _AddMenuPopupState();
}

class _AddMenuPopupState extends State<AddMenuPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  bool isActive = true;
  bool isSubmitting = false;

  Future<void> addMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final payload = {
      "service_name": serviceNameController.text.trim(),
      "description": descriptionController.text.trim(),
      "price": int.tryParse(priceController.text.trim()) ?? 0,
      "duration_minutes": int.tryParse(durationController.text.trim()) ?? 0,
      "is_active": isActive,
      "shop_id": widget.shopId,
      "owner_id": widget.ownerId,
    };

    final success = await ApiService.addMenuItem(payload);

    setState(() => isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      widget.onMenuAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Menu item added successfully ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add menu item ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Add New Menu Item"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: serviceNameController,
                decoration: const InputDecoration(labelText: "Service Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter service name" : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter description" : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter price";
                  if (int.tryParse(value) == null) return "Enter valid number";
                  return null;
                },
              ),
              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Duration (minutes)"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter duration";
                  if (int.tryParse(value) == null) return "Enter valid number";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) {
                      setState(() => isActive = value ?? true);
                    },
                  ),
                  const Text("Active Service"),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : addMenu,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2dbd6e),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Add"),
        ),
      ],
    );
  }
}
