import 'package:flutter/material.dart';
import '/services/api_service.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<dynamic> shops = [];
  bool isLoading = true;
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    userId = args?['userId'];
    fetchShops();
  }

  Future<void> fetchShops() async {
    setState(() => isLoading = true);
    final data = await ApiService.getShops();
    setState(() {
      shops = data ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Discover Shops 💈",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        centerTitle: true,
        elevation: 6,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : RefreshIndicator(
              onRefresh: fetchShops,
              color: const Color(0xFF1E88E5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      "Welcome, Customer 🛍️",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your User ID: $userId",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Shop Grid
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 1;
                          if (constraints.maxWidth > 1200) {
                            crossAxisCount = 3;
                          } else if (constraints.maxWidth > 800) {
                            crossAxisCount = 2;
                          }

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.25,
                            ),
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              final shop = shops[index];
                              return ShopCard(shop: shop);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// 🌿 SHOP CARD WIDGET
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
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHovered
                ? [const Color(0xFF42A5F5), const Color(0xFF90CAF9)]
                : [Colors.white, Colors.white],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0xFF64B5F6).withOpacity(0.6)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.storefront,
                      color: Color(0xFF1E88E5), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    shop['shop_name'] ?? 'Unnamed Shop',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
                Icon(
                  shop['is_open'] ? Icons.check_circle : Icons.cancel,
                  color: shop['is_open'] ? Colors.green : Colors.redAccent,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Shop Details
            Text(
              "📍 ${shop['address']}, ${shop['city']}, ${shop['state']}",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              "🕒 ${shop['open_time']} - ${shop['close_time']}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const Spacer(),

            // Visit Button
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/shopDetails', // ✅ Navigate to Shop Details Page
                    arguments: {
                      'shopId': shop['shop_id'],
                      'shopName': shop['shop_name'],
                    },
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: const Text("Visit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
