import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.gif'),
            fit: BoxFit.cover
          )
        ),
        child: Container(
          alignment: Alignment.center,
          color: colorPrimary.withValues(alpha: 0.96),
          child: Image.asset('assets/images/brand_logo.png'),
        )
      ),
    );
  }
}

class SplashController extends GetxController {
  @override
  void onReady() async {
    await Future.delayed(Duration(seconds: 3));
    Get.offNamed('/');
  }
}