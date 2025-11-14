import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
static Future<dynamic> registerUser(Map data) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/register'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Login failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  static Future<List<dynamic>?> getShopsByOwner(int ownerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/owner/$ownerId'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch shops: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching shops: $e");
      return null;
    }
  }
  static Future<bool> createShop(Map<String, dynamic> shopData, int ownerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create?owner_id=$ownerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(shopData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error creating shop: $e");
      return false;
    }
  }
   static Future<List<dynamic>?> getAvailableBarbers(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barbers/available/$shopId'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch barbers: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching barbers: $e");
      return null;
    }
  }

  static Future<bool> addBarber(Map<String, dynamic> barberData, int shopId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/barbers/add/$shopId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(barberData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error adding barber: $e");
      return false;
    }
  }
  static Future<bool> addMenuItem(Map<String, dynamic> payload) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/menu/add'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Add Menu failed: ${response.body}');
    }
  } catch (e) {
    print("Error adding menu: $e");
  }
  return false;
}

static Future<List<dynamic>?> getMenuByShop(int shopId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/menu/shop/$shopId'),
      headers: {'accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (e) {

  }
  return [];
}
static Future<List<dynamic>?> getShops() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/shops/'),
      headers: {'accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (e) {
    print("Error fetching shops: $e");
  }
  return [];
}
static Future<List<dynamic>?> getShopSlots(int shopId, String date) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/shops/$shopId/slots/?date=$date'),
      headers: {'accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (e) {
    print("Error fetching slots: $e");
  }
  return [];
}
static Future<bool> bookSlots(Map<String, dynamic> payload) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/book-slots/'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    print("Error booking slots: $e");
  }
  return false;
}
static Future<bool> updateBarber(int barberId, int ownerId, Map body) async {
  final response = await http.put(
    Uri.parse("$baseUrl/barbers/update/$barberId?owner_id=$ownerId"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return response.statusCode == 200;
}
static Future<String> deleteBarber(int barberId, int ownerId) async {
  final url = Uri.parse("$baseUrl/barbers/delete/$barberId?owner_id=$ownerId");

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body["msg"] ?? "Deleted successfully";
  } else {
    return "Failed to delete barber";
  }
}
static Future<String> updateMenu({
  required int menuId,
  required int ownerId,
  required String serviceName,
  required String description,
  required int price,
  required int duration,
}) async {
  final url = Uri.parse("$baseUrl/menu/update/$menuId");

  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "owner_id": ownerId,
      "service_name": serviceName,
      "description": description,
      "price": price,
      "duration_minutes": duration,
    }),
  );

  if (response.statusCode == 200) {
    return "Menu Updated Successfully";
  } else {
    return "Failed to update menu";
  }
}


}


