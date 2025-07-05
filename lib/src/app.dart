import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'init.dart';
import 'views/splash.dart';

class ARU extends StatelessWidget {
  const ARU({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ARU',
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        canvasColor: Colors.transparent
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/', 
          page: () => Init()
        ),
        GetPage(
          name: '/splash', 
          page: () => Splash()
        )
      ]
    );
  }
}