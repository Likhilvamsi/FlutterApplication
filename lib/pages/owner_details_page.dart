import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'add_barber_popup.dart';
import 'add_menu_popup.dart';
import 'edit_barber_popup.dart';
import 'edit_menu_popup.dart';

class OwnerDetailsPage extends StatefulWidget {
  const OwnerDetailsPage({super.key});

  @override
  State<OwnerDetailsPage> createState() => _OwnerDetailsPageState();
}

class _OwnerDetailsPageState extends State<OwnerDetailsPage> {
  List<dynamic> barbers = [];
  List<dynamic> menuItems = [];

  bool isLoading = true;
  bool isMenuLoading = true;

  int? shopId;
  int? ownerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    shopId = args?['shopId'];
    ownerId = args?['ownerId'];

    if (shopId != null) {
      fetchBarbers(shopId!);
      fetchMenu(shopId!);
    }
  }

  // ---------------------------- APIs ----------------------------
  Future<void> fetchBarbers(int shopId) async {
    setState(() => isLoading = true);
    final data = await ApiService.getAvailableBarbers(shopId);
    setState(() {
      barbers = data ?? [];
      isLoading = false;
    });
  }

  Future<void> fetchMenu(int shopId) async {
    setState(() => isMenuLoading = true);
    final data = await ApiService.getMenuByShop(shopId);
    setState(() {
      menuItems = data ?? [];
      isMenuLoading = false;
    });
  }

  // ---------------------------- UI ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2dbd6e), Color(0xFFa6f77b)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Shop Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // ================= BODY =================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= MENU SECTION =================
                      Row(
                        children: [
                          const Text(
                            "Shop Menu",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Menu"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF2dbd6e),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddMenuPopup(
                                  shopId: shopId!,
                                  ownerId: ownerId!,
                                  onMenuAdded: () => fetchMenu(shopId!),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      isMenuLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Column(
                              children: menuItems
                                  .map(
                                    (menu) => MenuCard(
                                      menu: menu,
                                      ownerId: ownerId!,
                                      onUpdated: () => fetchMenu(shopId!),
                                    ),
                                  )
                                  .toList(),
                            ),

                      const SizedBox(height: 30),

                      // ================= BARBER SECTION =================
                      Row(
                        children: [
                          const Text(
                            "Shop Barbers",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text("Add Barber"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF2dbd6e),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddBarberPopup(
                                  shopId: shopId!,
                                  onBarberAdded: () => fetchBarbers(shopId!),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= RESPONSIVE BARBER GRID =================
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double width = constraints.maxWidth;

                          int crossAxisCount = 4;
                          double aspect = 1.6;

                          if (width < 600) {
                            crossAxisCount = 2; // Mobile
                            aspect = 1.0;
                          } else if (width < 900) {
                            crossAxisCount = 3; // Tablet
                            aspect = 1.3;
                          }

                          return isLoading
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: aspect,
                                  ),
                                  itemCount: barbers.length,
                                  itemBuilder: (_, index) {
                                    return BarberCard(
                                      barber: barbers[index],
                                      ownerId: ownerId!,
                                      onUpdated: () => fetchBarbers(shopId!),
                                    );
                                  },
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ===================================================================
//                      BARBER CARD
// ===================================================================
//

class BarberCard extends StatelessWidget {
  final Map<String, dynamic> barber;
  final int ownerId;
  final VoidCallback onUpdated;

  const BarberCard({
    super.key,
    required this.barber,
    required this.ownerId,
    required this.onUpdated,
  });

  Future<void> deleteBarber(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Barber"),
        content: const Text("Are you sure you want to delete this barber?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx, rootNavigator: true).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogCtx, rootNavigator: true).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dynamic msg = await ApiService.deleteBarber(barber["barber_id"], ownerId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg?.toString() ?? "Deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      onUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete barber: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2dbd6e);

    final name = barber["barber_name"]?.toString() ?? "Unknown";
    final startTime = barber["start_time"]?.toString() ?? "-";
    final endTime = barber["end_time"]?.toString() ?? "-";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primary.withOpacity(0.15),
              child: const Icon(Icons.person, color: primary, size: 28),
            ),
            const SizedBox(height: 6),

            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),

            Text(
              "$startTime - $endTime",
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditBarberPopup(
                        barber: barber,
                        ownerId: ownerId,
                        onUpdated: onUpdated,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  onPressed: () => deleteBarber(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//
// ===================================================================
//                      MENU CARD
// ===================================================================
//

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> menu;
  final int ownerId;
  final VoidCallback onUpdated;

  const MenuCard({
    super.key,
    required this.menu,
    required this.ownerId,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final serviceName = menu["service_name"]?.toString() ?? "Service";
    final description = menu["description"]?.toString() ?? "";
    final price = menu["price"]?.toString() ?? "0";
    final duration = menu["duration_minutes"]?.toString() ?? "-";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.cut, color: Color(0xFF2dbd6e)),
        title: Text(serviceName),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditMenuPopup(
                    menu: menu,
                    ownerId: ownerId,
                    onUpdated: onUpdated,
                  ),
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹$price", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$duration min", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => EditMenuPopup(
              menu: menu,
              ownerId: ownerId,
              onUpdated: onUpdated,
            ),
          );
        },
      ),
    );
  }
}
