import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/university_service.dart';
import 'services/swipe_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UniversityService>(
          create: (_) => UniversityService(baseUrl: 'http://localhost:8000'),
        ),
        Provider<SwipeService>(
          create: (_) => SwipeService(baseUrl: 'http://localhost:8000'),
        ),
      ],
      child: MaterialApp(
        title: 'University Finder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
