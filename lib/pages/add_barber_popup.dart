import 'package:flutter/material.dart';
import '/services/api_service.dart';

class AddBarberPopup extends StatefulWidget {
  final int shopId;
  final VoidCallback onBarberAdded;

  const AddBarberPopup({
    super.key,
    required this.shopId,
    required this.onBarberAdded,
  });

  @override
  State<AddBarberPopup> createState() => _AddBarberPopupState();
}

class _AddBarberPopupState extends State<AddBarberPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController barberNameController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isAvailable = true;
  bool everyday = false;
  bool isSubmitting = false;

  Future<void> handleAddBarber() async {
    if (!_formKey.currentState!.validate() || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly.")),
      );
      return;
    }

    final barberData = {
      "barber_name": barberNameController.text.trim(),
      "start_time":
          "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00",
      "end_time":
          "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00",
      "is_available": isAvailable,
      "everyday": everyday,
    };

    setState(() => isSubmitting = true);
    final success = await ApiService.addBarber(barberData, widget.shopId);
    setState(() => isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      widget.onBarberAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barber added successfully ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add barber ❌")),
      );
    }
  }

  Future<void> pickTime(bool isStartTime) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
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
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      "Add Barber",
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

                // Barber Name
                _buildTextField(barberNameController, "Barber Name", Icons.person),

                const SizedBox(height: 10),

                // Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeButton(
                        label: startTime == null
                            ? "Select Start Time"
                            : "Start: ${startTime!.format(context)}",
                        icon: Icons.access_time,
                        onPressed: () => pickTime(true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTimeButton(
                        label: endTime == null
                            ? "Select End Time"
                            : "End: ${endTime!.format(context)}",
                        icon: Icons.timer_off,
                        onPressed: () => pickTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Switch Toggles
                _buildSwitchTile(
                  title: "Available",
                  value: isAvailable,
                  onChanged: (val) => setState(() => isAvailable = val),
                ),
                _buildSwitchTile(
                  title: "Everyday",
                  value: everyday,
                  onChanged: (val) => setState(() => everyday = val),
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
                      onPressed: isSubmitting ? null : handleAddBarber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2dbd6e),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Add Barber",
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

  // 🌿 Input Field
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF2dbd6e)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.grey[100],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF2dbd6e), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? "Enter $label" : null,
    );
  }

  // 🌿 Time Button
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

  // 🌿 Custom Switch Tile
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      value: value,
      activeColor: const Color(0xFF2dbd6e),
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
