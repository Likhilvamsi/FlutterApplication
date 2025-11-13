import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/api_service.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  int? shopId;
  String? shopName;
  int? userId;

  List<DateTime> weekDates = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  List<dynamic> slots = [];

  List<Map<String, dynamic>> selectedSlots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    shopId = args?['shopId'];
    shopName = args?['shopName'];
    userId = args?['userId'];
    generateWeekDates();
    fetchSlots(selectedDate);
  }

  void generateWeekDates() {
    final now = DateTime.now();
    weekDates = List.generate(7, (index) => now.add(Duration(days: index)));
  }

  Future<void> fetchSlots(DateTime date) async {
    if (shopId == null) return;
    setState(() => isLoading = true);

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final data = await ApiService.getShopSlots(shopId!, formattedDate);

    setState(() {
      slots = data ?? [];
      isLoading = false;
    });
  }

  void toggleSlotSelection(Map<String, dynamic> slot) {
    final existing = selectedSlots.indexWhere((s) => s['slot_id'] == slot['slot_id']);
    if (existing >= 0) {
      selectedSlots.removeAt(existing);
    } else {
      selectedSlots.add({
        'slot_id': slot['slot_id'],
        'slot_time': slot['slot_time'],
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'barber_id': slot['barber_id'],
      });
    }
    setState(() {});
  }

  bool isSlotSelected(int slotId) {
    return selectedSlots.any((s) => s['slot_id'] == slotId);
  }

  void openSelectedSlotsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => BookingSummarySheet(
        selectedSlots: selectedSlots,
        onRemove: (slotId) {
          setState(() {
            selectedSlots.removeWhere((s) => s['slot_id'] == slotId);
          });
        },
        onBook: () async {
          final slotIds = selectedSlots.map((s) => s['slot_id']).toList();
          if (slotIds.isEmpty) return;

          final payload = {
            "user_id": userId ?? 1,
            "barber_id": selectedSlots.first['barber_id'] ?? 0,
            "shop_id": shopId!,
            "slot_ids": slotIds,
          };

          final success = await ApiService.bookSlots(payload);

          Navigator.pop(context);

          if (success) {
            setState(() => selectedSlots.clear());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("🎉 Booking confirmed!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Booking failed. Try again."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          shopName ?? "Shop Details",
          style: const TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E88E5)),
      ),
      floatingActionButton: selectedSlots.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: openSelectedSlotsPopup,
              backgroundColor: const Color(0xFF1E88E5),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text("Book (${selectedSlots.length})"),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌿 Shop Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.storefront, color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          shopName ?? "Shop",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Select your preferred time slot below to book an appointment.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🌿 Horizontal Date Picker
                  const Text(
                    "Select a Date",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weekDates.length,
                      itemBuilder: (context, index) {
                        final date = weekDates[index];
                        final isSelected = date.day == selectedDate.day &&
                            date.month == selectedDate.month;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedDate = date);
                            fetchSlots(date);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 12),
                            width: 85,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1E88E5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.blue.withOpacity(0.4)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM').format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🌿 Slots Section
                  const Text(
                    "Available Slots",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(height: 12),

                  slots.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              "No slots available 😕",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 3 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3.0,
                          ),
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final slot = slots[index];
                            final isBooked =
                                slot['status']?.toLowerCase() == 'booked';
                            final isSelected =
                                isSlotSelected(slot['slot_id']);
                            return GestureDetector(
                              onTap: isBooked
                                  ? null
                                  : () => toggleSlotSelection(slot),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isBooked
                                      ? Colors.red[100]
                                      : isSelected
                                          ? const Color(0xFF42A5F5)
                                          : Colors.white,
                                  border: Border.all(
                                    color: isBooked
                                        ? Colors.redAccent
                                        : isSelected
                                            ? const Color(0xFF42A5F5)
                                            : Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.4)
                                          : Colors.grey.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              slot['slot_time'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              slot['barber_name'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? Colors.white70
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (isBooked)
                                      const Icon(Icons.lock,
                                          color: Colors.redAccent)
                                    else if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: Colors.white)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

// 🌿 Booking Summary Sheet
class BookingSummarySheet extends StatelessWidget {
  final List<Map<String, dynamic>> selectedSlots;
  final Function(int slotId) onRemove;
  final VoidCallback onBook;

  const BookingSummarySheet({
    super.key,
    required this.selectedSlots,
    required this.onRemove,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Booking Summary",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: selectedSlots.isEmpty
                  ? const Center(child: Text("No slots selected."))
                  : ListView.builder(
                      itemCount: selectedSlots.length,
                      itemBuilder: (context, index) {
                        final slot = selectedSlots[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              slot['slot_time'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("📅 ${slot['date']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => onRemove(slot['slot_id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedSlots.isEmpty ? null : onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Booking",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
