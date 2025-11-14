import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Correct base URL (NO trailing slash)
  static const String baseUrl = 'http://48.221.112.220/api';

  // -----------------------------
  // USERS
  // -----------------------------
  static Future<dynamic> registerUser(Map data) async {
    final url = Uri.parse('$baseUrl/users/register');
    print("REGISTER URL: $url");
    print("BODY: ${jsonEncode(data)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<dynamic> sendOTP(Map data) async {
    final url = Uri.parse('$baseUrl/users/send-verification-otp');
    print("SEND OTP URL: $url");
    print("BODY: ${jsonEncode(data)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/users/login');

    final bodyData = {
      "email": email,
      "password": password,
      "role": role,
    };

    print("LOGIN URL: $url");
    print("LOGIN BODY: ${jsonEncode(bodyData)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bodyData),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<dynamic> loginWithOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/users/login-with-otp');

    print("LOGIN OTP URL: $url");
    print("BODY: ${jsonEncode({"email": email, "otp": otp})}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  // -----------------------------
  // SHOPS
  // -----------------------------
  static Future<List<dynamic>?> getShops() async {
    final url = Uri.parse('$baseUrl/shops/');
    print("GET SHOPS URL: $url");

    final response = await http.get(
      url,
      headers: {'accept': 'application/json'},
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>?> getShopsByOwner(int ownerId) async {
    final url = Uri.parse('$baseUrl/owner/$ownerId');
    print("GET SHOPS BY OWNER URL: $url");

    final response = await http.get(url);

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<bool> createShop(Map<String, dynamic> shopData, int ownerId) async {
    final url = Uri.parse('$baseUrl/create?owner_id=$ownerId');

    print("CREATE SHOP URL: $url");
    print("BODY: ${jsonEncode(shopData)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(shopData),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  static Future<List<dynamic>?> getShopSlots(int shopId, String date) async {
    final url = Uri.parse('$baseUrl/shops/$shopId/slots/?date=$date');
    print("GET SLOTS URL: $url");

    final response = await http.get(url);

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> bookSlots(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/book-slots/');
    print("BOOK SLOTS URL: $url");
    print("BODY: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  // -----------------------------
  // BARBERS
  // -----------------------------
  static Future<List<dynamic>?> getAvailableBarbers(int shopId) async {
    final url = Uri.parse('$baseUrl/barbers/available/$shopId');
    print("GET BARBERS URL: $url");

    final response = await http.get(url);

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<bool> addBarber(Map<String, dynamic> barberData, int shopId) async {
    final url = Uri.parse('$baseUrl/barbers/add/$shopId');
    print("ADD BARBER URL: $url");
    print("BODY: ${jsonEncode(barberData)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barberData),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  static Future<bool> updateBarber(
      int barberId, int ownerId, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/barbers/update/$barberId?owner_id=$ownerId');

    print("UPDATE BARBER URL: $url");
    print("BODY: ${jsonEncode(body)}");

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  static Future<String> deleteBarber(int barberId, int ownerId) async {
    final url = Uri.parse('$baseUrl/barbers/delete/$barberId?owner_id=$ownerId');

    print("DELETE BARBER URL: $url");

    final response = await http.delete(url);

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["msg"] ?? "Deleted successfully";
    }
    return "Failed to delete barber";
  }

  // -----------------------------
  // MENU
  // -----------------------------
  static Future<bool> addMenuItem(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/menu/add');

    print("ADD MENU URL: $url");
    print("BODY: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  static Future<List<dynamic>?> getMenuByShop(int shopId) async {
    final url = Uri.parse('$baseUrl/menu/shop/$shopId');
    print("GET MENU URL: $url");

    final response = await http.get(url);

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

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
    final url = Uri.parse('$baseUrl/menu/update/$menuId');

    print("UPDATE MENU URL: $url");

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "owner_id": ownerId,
        "service_name": serviceName,
        "description": description,
        "price": price,
        "duration_minutes": duration,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200
        ? "Menu Updated Successfully"
        : "Failed to update menu";
  }
}
