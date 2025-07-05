import 'dart:io';

import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/otp.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:aru/src/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'biometric_auth.dart';
import 'forgot_password.dart';
import 'signup.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(() => Form(
            key: controller.formKey,
            autovalidateMode: controller.validateMode.value,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 80, 16, 16),
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16,),
                Align(
                  alignment: Alignment.center,
                  child: Text('Sign In', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700
                  ))
                ),
                const SizedBox(height: 32,),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60
                  ),
                  child: CustomTextField(
                    controller: controller.emailCtrl,
                    label: 'Email',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email address required';
                      } return null;
                    },
                  )
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60
                  ),
                  child: CustomTextField(
                    controller: controller.passwordCtrl,
                    label: 'Password',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password required';
                      } return null;
                    },
                    obscureText: controller.hidePassword.value,
                    suffixIcon: controller.hidePassword.value 
                      ? TablerIcons.eye_off
                      : TablerIcons.eye,
                    onSuffixIconTap: () => controller.hidePassword.toggle(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Get.to(ForgotPassword(), id: 0),
                    child: Text('Forgot Password?')
                  )
                ),
                const SizedBox(height: 32),
                Buttons
                  .text(
                    'Sign In',
                    onPressed: () {
                      FocusScopeNode focus = FocusScope.of(context);
                      if (!focus.hasPrimaryFocus) {
                        focus.unfocus();
                      }
                      
                      controller.login();
                    }
                  )
                  .primary
                  .build(),
                const SizedBox(height: 16),
                DefaultTextStyle(
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333)
                  ),
                  child: Row(
                    children: [
                      Text('Don\'t have an account? '),
                      InkWell(
                        onTap: () => Get.off(SignUp(), id: 0),
                        child: Text('Sign Up', style: TextStyle(
                          color: colorAccent
                        )),
                      )
                    ]
                  )
                ),
                if (false) ... [
                  const SizedBox(height: 32,),
                  Center(
                    child: SizedBox(
                      //color: Colors.grey[100],
                      width: 48,
                      height: 48,
                      child: Image.asset(
                        'assets/images/${Platform.isIOS ? 'face_id.png' : 'touch_id.png'}'
                      ),
                    )
                  )
                ]
              ],
            ),
          )),
          Obx(() {
            if (controller.authenticating.value) {
              return buildLoader();
            } return Container();
          })
        ],
      )
    );
  }
}

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;
  final HttpService http = Get.find();
  RxBool hidePassword = true.obs;
  RxBool authenticating = false.obs;
  final AuthManager authManager = Get.find();

  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;

  @override
  void onInit() {
    super.onInit();
    emailCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      authenticating.value = true;

      final result = await http.authenticate(emailCtrl.text, passwordCtrl.text);
      // final result = await http.getUserProfile();
      if (result is String) {
        PopupManager.error(
          title: 'Login Failed!',
          message: result
        );
      } else {
        if (result['verifyEmail'] != null) {
          // Redirect to otp
          Get.off(VerifyAccount(email: emailCtrl.text), id: 0);
        } else {
          await authManager.updateAuthToken(result['access_token'], result['refreshToken']);
          Get.off(BiometricAuth(), id: 0);
        }
      }

      authenticating.value = false;
    } else {
      validateMode.value = AutovalidateMode.onUserInteraction;
    }
  }
}

class VerifyAccount extends StatelessWidget {
  final String email;

  const VerifyAccount({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final VerifyAccountController controller = Get.put(VerifyAccountController(email));

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 100, 24, 16),
            child: Column(
              children: [
                Image.asset('assets/images/app_logo.png', width: 100, height: 100,),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Text('Account Verification', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700
                  ))
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 450,
                    child: OTP(
                      formKey: controller.formKey,
                      tokenController: controller.otpCtrl,
                      submitText: 'Reset Password',
                      onSubmit: () => controller.verifyToken(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DefaultTextStyle(
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333)
                  ),
                  child: Row(
                    children: [
                      Text('Did\'t get an OTP? '),
                      InkWell(
                        onTap: () => {},
                        child: Text('Resend OTP', style: TextStyle(
                          color: colorAccent
                        )),
                      )
                    ]
                  )
                ),
              ],
            )
          ),
          Obx(() {
            if (controller.processing.value) {
              return buildLoader();
            } return Container();
          })
        ],
      )
    );
  }
}

class VerifyAccountController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late TextEditingController otpCtrl;
  final HttpService http = Get.find();
  final String email;
  RxBool processing = false.obs;

  VerifyAccountController(this.email);

  @override
  void onInit() {
    super.onInit();
    otpCtrl = TextEditingController();
  }

  @override
  void onClose() {
    otpCtrl.dispose();
    super.onClose();
  }

  void verifyToken() async {
    if (formKey.currentState!.validate()) {
      processing.value = true;
      final result = await http.verifyEmail(email, otpCtrl.text);
      processing.value = false;

      if (result is String) {
        PopupManager.error(
          title: 'Failed',
          message: result
        );
      } else {
        Get.off(Login(), id: 0);
        PopupManager.success(
          title: 'Success',
          message: 'Email verification completed.'
        );

      }
    }
  }
}