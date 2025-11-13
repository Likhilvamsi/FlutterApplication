import 'package:flutter/material.dart';
import '/services/api_service.dart';

class AddShopPopup extends StatefulWidget {
  final int ownerId;
  final VoidCallback onShopAdded;

  const AddShopPopup({
    super.key,
    required this.ownerId,
    required this.onShopAdded,
  });

  @override
  State<AddShopPopup> createState() => _AddShopPopupState();
}

class _AddShopPopupState extends State<AddShopPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  bool isSubmitting = false;

  Future<void> handleAddShop() async {
    if (!_formKey.currentState!.validate() || openTime == null || closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly.")),
      );
      return;
    }

    final shopData = {
      "shop_name": shopNameController.text.trim(),
      "address": addressController.text.trim(),
      "city": cityController.text.trim(),
      "state": stateController.text.trim(),
      "open_time":
          "${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}:00",
      "close_time":
          "${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}:00",
    };

    setState(() => isSubmitting = true);
    final success = await ApiService.createShop(shopData, widget.ownerId);
    setState(() => isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      widget.onShopAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop added successfully ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create shop ❌")),
      );
    }
  }

  Future<void> pickTime(bool isOpenTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: isOpenTime ? "Select Opening Time" : "Select Closing Time",
    );
    if (pickedTime != null) {
      setState(() {
        if (isOpenTime) {
          openTime = pickedTime;
        } else {
          closeTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌿 Gradient Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2dbd6e), Color(0xFFa6f77b)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: const Center(
                    child: Text(
                      "Add New Shop",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(shopNameController, "Shop Name", Icons.storefront),
                _buildTextField(addressController, "Address", Icons.location_on_outlined),
                _buildTextField(cityController, "City", Icons.location_city),
                _buildTextField(stateController, "State", Icons.map_outlined),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeButton(
                        label: openTime == null
                            ? "Select Open Time"
                            : "Open: ${openTime!.format(context)}",
                        icon: Icons.access_time,
                        onPressed: () => pickTime(true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTimeButton(
                        label: closeTime == null
                            ? "Select Close Time"
                            : "Close: ${closeTime!.format(context)}",
                        icon: Icons.timer_off,
                        onPressed: () => pickTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : handleAddShop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2dbd6e),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Add Shop",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🌿 Beautiful input field
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF2dbd6e)),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.grey[100],
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2dbd6e), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  // 🌿 Gradient button for picking time
  Widget _buildTimeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2dbd6e),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
