import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // untuk kReleaseMode
import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // mati otomatis saat build release
      defaultDevice: Devices.ios.iPhone11ProMax,
      devices: [Devices.ios.iPhone11ProMax, Devices.ios.iPadPro11Inches],
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Integrasi Device Preview (wajib ketiga baris ini)
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      title: 'AI Schedule Generator',

      // Tema global menggunakan Material 3 (Futuristic Blue & White)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF), // Cyan neon blue
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A192F), // Deep blue
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const HomeScreen(), // Halaman pertama saat aplikasi dibuka
    );
  }
}
