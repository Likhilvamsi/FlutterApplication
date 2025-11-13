import 'package:flutter/material.dart';
import 'edit_menu_popup.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.cut, color: Color(0xFF2dbd6e)),
        title: Text(menu["service_name"]),
        subtitle: Text(menu["description"]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EDIT ICON
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditMenuPopup(
                    menu: menu,
                    ownerId: ownerId,      // FIXED
                    onUpdated: onUpdated,  // FIXED
                  ),
                );
              },
            ),

            // PRICE + DURATION
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹${menu["price"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${menu["duration_minutes"]} min",
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
