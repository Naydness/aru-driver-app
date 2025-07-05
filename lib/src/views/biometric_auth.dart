import 'dart:io';

import 'package:aru/src/components/button.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'dashboard.dart';

class BiometricAuth extends StatelessWidget {
  const BiometricAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final BiometricAuthController controller = Get.put(BiometricAuthController());

    return Scaffold(
      body: controller.obx(
        (state) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.authStatus == AuthStatus.inactive) ...[
                    if (Platform.isIOS)
                    Icon(TablerIcons.face_id, size: 80,)
                    else
                    Icon(TablerIcons.fingerprint, size: 80,),
                    const SizedBox(height: 32,),
                    Text('Use Biometric Authentication?', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorPrimary
                    ), textAlign: TextAlign.center,),
                    const SizedBox(height: 16,),
                    Text('Access your account using biometric authentication', style: TextStyle(
                      color: colorBlack2
                    ), textAlign: TextAlign.center,),
                    const SizedBox(height: 16,),
                    Text('You can turn this feature on or off later', style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF858585)
                    ), textAlign: TextAlign.center,),
                    const SizedBox(height: 32,),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Buttons.text('Enable biometric login', onPressed: () {
                        GetStorage().write('bioAuth', true);
                        controller.gotoDashboard();
                      }).primary.build(),
                    ),
                    const SizedBox(height: 8,),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Buttons.text('Skip for now', onPressed: () {
                        GetStorage().write('bioAuth', false);
                        controller.gotoDashboard();
                      }).outlined.build(),
                    ),
                  ]
                ],
              ),
            )
          );
        },
        onLoading: Container()
      )
    );
  }
}

class BiometricAuthController extends GetxController with StateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  AuthStatus authStatus = AuthStatus.inactive;

  @override
  void onReady() async {
    change(null, status: RxStatus.loading());

    if (await auth.canCheckBiometrics == false) {
      gotoDashboard();
      return;
    }

    if (GetStorage().read('bioAuth') == false) {
      gotoDashboard();
      return;
    }

    change(null, status: RxStatus.success());

    if (GetStorage().read('bioAuth') ?? false) {
      authStatus = AuthStatus.active;

      try {
        final authResult = await auth.authenticate(
          localizedReason: 'Authenticate with bimetric to continue',
          options: const AuthenticationOptions(biometricOnly: true)
        );

        if (authResult) {
          gotoDashboard();
        }
      } on PlatformException catch (_) {
        gotoDashboard();
      }
    }
  }

  /*@override
  void onReady() async {
    change(null, status: RxStatus.success());

  }*/

  void gotoDashboard() {
    Get.off(Dashboard(), id: 0);
  }
}

enum AuthStatus {
  inactive,
  active
}