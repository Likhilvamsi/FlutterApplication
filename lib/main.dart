import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import '/pages/login_page.dart';
import '/pages/owner_page.dart';
import '/pages/customer_page.dart';
import '/pages/owner_details_page.dart';
import '/pages/shop_details_page.dart';
void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Login App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/owner': (context) => const OwnerPage(),
        '/customer': (context) => const CustomerPage(),
        '/owner-details': (context) => const OwnerDetailsPage(), // 👈 NEW
        '/shopDetails': (context) => const ShopDetailsPage(), 
      },
    );
  }
}
