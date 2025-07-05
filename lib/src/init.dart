import 'dart:async';
import 'dart:io';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'views/biometric_auth.dart';
import 'views/error.dart';
import 'views/login.dart';
import 'views/onboarding.dart';

class Init extends StatelessWidget {
  const Init({super.key});
  
  @override
  Widget build(BuildContext context) {
    final InitController controller = Get.put(InitController());

    return Scaffold(
      body: controller.obx(
        (state) {
          final Widget page = state!;
          return Navigator(
            key: Get.nestedKey(0),
            onGenerateRoute: (settings) {
              return GetPageRoute(page: () => page);
            },
          );
        },
        onLoading: Center(child: CircularProgressIndicator.adaptive()),
        onError: (err) => Center(child: Text('Something went wrong'),)
      )
    );
  }

  /*void _validateAppVersion() async {
    final pkgInfo = await PackageInfo.fromPlatform();

    final appVer = _getVersionNumber(pkgInfo.version);
    final requiredMinVer = _getVersionNumber(_getRequiredMinVer());
    final latestVer = _getVersionNumber(_getLatestVer());

    if (appVer < requiredMinVer) {
      _showUpdateDialog(true);
    } else if (appVer < latestVer) {
      _showUpdateDialog(false);
    }
  }

  int _getVersionNumber(String ver) {
    List semVers = ver.split('.');
    semVers = semVers.map((i) => int.parse(i)).toList();
    return semVers[0] * 100000 + semVers[1] * 1000 + semVers[2];
  }

  String _getLatestVer() {
    if (Platform.isIOS) {
      return RC.iOSLatestVer;
    }

    return RC.androidLatestVer;
  }

  String _getRequiredMinVer() {
    if (Platform.isIOS) {
      return RC.iOSRequiredMinVer;
    }

    return RC.androidRequiredMinVer;
  }

  Future _showUpdateDialog(bool isMandatory) {
    final title = isMandatory
      ? 'Update Required'
      : 'Update Available';

    final description = isMandatory
      ? 'This version of the schoolcube app is no longer supported. Please update to the latest version to continue.'
      : 'A new version of schoolcube app is now available. Please update your app to the latest version';

    return showDialog(
      context: Get.context!, 
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) => Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          // alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: kToolbarHeight + 16),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.red)
                ),
                height: MediaQuery.of(context).size.height * .7,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/update.png'),
                    const SizedBox(height: 52,),
                    Container(
                      child: Column(
                        children: [
                          Text(title, style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w700
                          )),
                          const SizedBox(height: 22),
                          Text(
                            description, 
                            style: TextStyle(
                              fontSize: 14,
                              color: appDark,
                              fontWeight: FontWeight.w500
                            ), 
                            textAlign: TextAlign.center
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ),
              // const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.red)
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: pryColor,
                          foregroundColor: Colors.white
                        ),
                        onPressed: () {
                          const appId = 'net.schoolcube.app.parent';
                          final url = Uri.parse(
                            Platform.isIOS
                              ? 'https://apps.apple.com/app/id$appId'
                              : 'market://details?id=$appId'
                          );

                          launchUrl(url, mode: LaunchMode.externalApplication);
                        }, 
                        child: Text('Update now', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                        ))
                      ),
                    ),
                    if (!isMandatory) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Get.back(), 
                          child: Text('Remind me later', style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: appDark
                          ))
                        ),
                      )
                    ],
                  ],
                ),
              )
            ],
          )
        ),
      )
    );
  }*/
}

class InitController extends GetxController with StateMixin<Widget> {
  AuthManager authManager = Get.find();
  HttpService http = Get.find();

  @override
  void onReady() async {
    // await _clearAllStorage();
    init();
  }

  Future _clearAllStorage() async {
    GetStorage().erase();
    FlutterSecureStorage().deleteAll();
  }

  Future init() async {
    change(null, status: RxStatus.loading());
    /*
      first launch
        :true - Goto onboarding -> login
        :false - Get user profile
          :token valid - Goto home
          :invalid - refresh token
            :true - store token, then go home
            :false - login
    */
    final firstLaunch = GetStorage().read('firstLaunch') ?? true;
    if (firstLaunch) {
      change(Onboarding(), status: RxStatus.success());
      return;
    }

    if (await authManager.loggedIn) {
      change(BiometricAuth(), status: RxStatus.success());
    } else {
      change(Login(), status: RxStatus.success());
    }



    // await SCFirebaseRemoteConfig.initialize();
    // RC = Get.find();
    // _validateAppVersion();
    // _authManager.validateUser();
  }
}