import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'add_shop_popup.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  bool isLoading = true;
  List<dynamic> shops = [];
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    userId = args?['userId'];
    if (userId != null) fetchShops(userId!);
  }

  Future<void> fetchShops(int ownerId) async {
    setState(() => isLoading = true);
    final data = await ApiService.getShopsByOwner(ownerId);
    setState(() {
      shops = data ?? [];
      isLoading = false;
    });
  }

  void openAddShopDialog() {
    showDialog(
      context: context,
      builder: (_) => AddShopPopup(
        ownerId: userId!,
        onShopAdded: () => fetchShops(userId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌿 same gradient background as login page
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF2dbd6e), Color(0xFFa6f77b)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar Style Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.store_mall_directory, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      "My Shops",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: openAddShopDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2dbd6e),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.add_business),
                      label: const Text(
                        "Add Shop",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Body Section
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : shops.isEmpty
                        ? const Center(
                            child: Text(
                              "No shops found 😕",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // 🧱 Responsive grid
                                int crossAxisCount = 3;
                                if (constraints.maxWidth < 900) {
                                  crossAxisCount = 2;
                                }
                                if (constraints.maxWidth < 600) {
                                  crossAxisCount = 1;
                                }

                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.3,
                                  ),
                                  itemCount: shops.length,
                                  itemBuilder: (context, index) {
                                    final shop = shops[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/owner-details',
                                          arguments: {
                                            'shopId': shop['shop_id'],
                                            'ownerId': userId
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: ShopCard(shop: shop),
                                    );
                                  },
                                );
                              },
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

// -------------------- 🌿 SHOP CARD ----------------------

class ShopCard extends StatefulWidget {
  final Map<String, dynamic> shop;
  const ShopCard({super.key, required this.shop});

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0xFF24c64f).withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isHovered ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header row with icon + shop name
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2dbd6e).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.storefront, color: Color(0xFF2dbd6e), size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    shop['shop_name'] ?? 'Unnamed Shop',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2dbd6e),
                    ),
                  ),
                ),
              ],
            ),

            // Address and location
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${shop['address']}, ${shop['city']}, ${shop['state']}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),

            // Open/close time and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${shop['open_time']} - ${shop['close_time']}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: shop['is_open']
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shop['is_open'] ? "Open" : "Closed",
                    style: TextStyle(
                      color: shop['is_open']
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
