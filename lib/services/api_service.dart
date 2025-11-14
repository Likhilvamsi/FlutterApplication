import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Backend base URL (nginx reverse proxy)
  static const String baseUrl = 'http://48.221.112.220/api';


  // -----------------------------
  // USERS
  // -----------------------------
  static Future<dynamic> registerUser(Map data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<dynamic> sendOTP(Map data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/send-verification-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "role": role}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<dynamic> loginWithOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login-with-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  // -----------------------------
  // SHOPS
  // -----------------------------
  static Future<List<dynamic>?> getShops() async {
    final response = await http.get(
      Uri.parse('$baseUrl/shops/'),
      headers: {'accept': 'application/json'},
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>?> getShopsByOwner(int ownerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/owner/$ownerId'),
      headers: {'accept': 'application/json'},
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<bool> createShop(Map<String, dynamic> shopData, int ownerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create?owner_id=$ownerId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(shopData),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>?> getShopSlots(int shopId, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/shops/$shopId/slots/?date=$date'),
      headers: {'accept': 'application/json'},
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> bookSlots(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book-slots/'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return response.statusCode == 200;
  }

  // -----------------------------
  // BARBERS
  // -----------------------------
  static Future<List<dynamic>?> getAvailableBarbers(int shopId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/barbers/available/$shopId'),
      headers: {'accept': 'application/json'},
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<bool> addBarber(Map<String, dynamic> barberData, int shopId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/barbers/add/$shopId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barberData),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateBarber(
      int barberId, int ownerId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/barbers/update/$barberId?owner_id=$ownerId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response.statusCode == 200;
  }

  static Future<String> deleteBarber(int barberId, int ownerId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/barbers/delete/$barberId?owner_id=$ownerId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["msg"] ?? "Deleted successfully";
    }
    return "Failed to delete barber";
  }

  // -----------------------------
  // MENU
  // -----------------------------
  static Future<bool> addMenuItem(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>?> getMenuByShop(int shopId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/menu/shop/$shopId'),
      headers: {'accept': 'application/json'},
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<String> updateMenu({
    required int menuId,
    required int ownerId,
    required String serviceName,
    required String description,
    required int price,
    required int duration,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/menu/update/$menuId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "owner_id": ownerId,
        "service_name": serviceName,
        "description": description,
        "price": price,
        "duration_minutes": duration,
      }),
    );

    return response.statusCode == 200
        ? "Menu Updated Successfully"
        : "Failed to update menu";
  }
}
