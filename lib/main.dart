import 'package:flutter/material.dart';
import 'package:job_finder/features/presentation/app_role_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            height: 2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
          unselectedLabelStyle: TextStyle(
            height: 2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AppRoleScreen(),
    );
  }
}
