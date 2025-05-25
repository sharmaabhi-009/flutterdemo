import 'package:flutter/material.dart';
import 'page/home_page.dart'; // Import your home page

void main() {
  runApp(const MyApp()); // Make sure MyApp is a valid class here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // This is already correct

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color.fromARGB(228, 217, 212, 212),
            appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
      ),
      home: const StockHomePage(), // Your homepage widget here
    );
  }
}