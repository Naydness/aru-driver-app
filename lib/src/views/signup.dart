import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/otp.dart';
import 'package:aru/src/components/phone_field.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'login.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.stage.value == SignupStage.initial) {
              return Form(
                key: controller.formKey,
                autovalidateMode: controller.validateMode.value,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 80, 16, 100),
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16,),
                    Align(
                      alignment: Alignment.center,
                      child: Text('Sign Up', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700
                      ))
                    ),
                    const SizedBox(height: 32,),
                    Row(
                      children: [
                        Expanded(
                          child: Buttons
                            .text('Google', prefixPath: 'google.png')
                            .neutral
                            .outlined
                            .build()
                        ),
                        const SizedBox(width: 16,),
                        Expanded(
                          child: Buttons
                            .text('Apple', prefixPath: 'apple.png')
                            .neutral
                            .outlined
                            .build()
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Color(0xFFE0E5EC),
                            endIndent: 8,
                          ),
                        ),
                        Text('Or'),
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Color(0xFFE0E5EC),
                            indent: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16,),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 60
                      ),
                      child: CustomTextField(
                        controller: controller.nameCtrl,
                        label: 'Name',
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Name is required';
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
                        controller: controller.emailCtrl,
                        label: 'Email',
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email address is required';
                          } return null;
                        },
                      )
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 44
                      ),
                      child: PhoneField(
                        controller: controller.phoneCtrl,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Phone number is required';
                          } return null;
                        },
                        onChanged: (phone) {
                          controller.phoneData = phone;
                        },
                      ),
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
                            return 'Password is required';
                          } return null;
                        },
                        obscureText: controller.hidePassword.value,
                        suffixIcon: controller.hidePassword.value
                          ? TablerIcons.eye_off
                          : TablerIcons.eye,
                        onSuffixIconTap: () => controller.hidePassword.toggle(),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.agreeTerms.toggle(),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333)
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: controller.agreeTerms.value, 
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return colorPrimary;
                                }

                                return colorPrimary.withValues(alpha: 0.05);
                              }),
                              shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(4)
                              ),
                              side: BorderSide.none,
                              onChanged: (v) {
                                controller.agreeTerms.value = v!;
                              }
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                children: [
                                  Text('I agree to the '),
                                  InkWell(
                                    onTap: () {},
                                    child: Text('Terms of Service ', style: TextStyle(
                                      color: colorAccent
                                    )),
                                  ),
                                  Text('and '),
                                  InkWell(
                                    onTap: () {},
                                    child: Text('Privacy Policy ', style: TextStyle(
                                      color: colorAccent
                                    )),
                                  )
                                ],
                              ),
                            )
                          ]
                        )
                      ),
                    ),
                    const SizedBox(height: 32),
                    Stack(
                      children: [
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: Buttons
                            .text(
                              'Create an Account',
                              onPressed: () {
                                if (controller.agreeTerms.value) {
                                  FocusScopeNode focus = FocusScope.of(context);
                                  if (!focus.hasPrimaryFocus) {
                                    focus.unfocus();
                                  }

                                  controller.signup();
                                }
                              }
                            )
                            .primary
                            .build(),
                        ),
                        if (!controller.agreeTerms.value)
                        Container(
                          height: 60, 
                          width: double.infinity, 
                          color: Colors.white.withValues(alpha: .5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333333)
                      ),
                      child: Row(
                        children: [
                          Text('Already have an account? '),
                          InkWell(
                            onTap: () => Get.off(Login(), id: 0),
                            child: Text('Sign In', style: TextStyle(
                              color: colorAccent
                            )),
                          )
                        ]
                      )
                    )
                  ],
                )
              );
            }

            if (controller.stage.value == SignupStage.verify) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    Image.asset('assets/images/app_logo.png', width: 100, height: 100,),
                    const SizedBox(height: 16,),
                    Align(
                      alignment: Alignment.center,
                      child: Text('Enter OTP', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700
                      ))
                    ),
                    const SizedBox(height: 16,),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 450,
                        child: OTP(
                          formKey: controller.otpFormKey,
                          tokenController: controller.otpCtrl,
                          onSubmit: () => controller.verifyToken(),
                        )
                      )
                    ),
                    const SizedBox(height: 16,),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333333)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Did\'t get an OTP? '),
                          InkWell(
                            onTap: () => controller.resendOTP(),
                            child: Text('Resend OTP', style: TextStyle(
                              color: colorAccent
                            )),
                          )
                        ]
                      )
                    ),
                  ],
                ),
              );
            }

            return Container();
          }),
          /* Loader overlay */
          Obx(() {
            if (controller.processing.value) {
              return buildLoader();
            }

            return Container();
          })
        ],
      )
    );
  }
}

class SignupController extends GetxController {
  Rx<SignupStage> stage = SignupStage.initial.obs;
  final formKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;
  final HttpService http = Get.find();
  RxBool hidePassword = true.obs;
  RxBool processing = false.obs;

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController passwordCtrl;
  PhoneNumber phoneData = PhoneNumber();
  RxBool agreeTerms = false.obs;

  final otpFormKey = GlobalKey<FormState>();
  late TextEditingController otpCtrl;

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
    otpCtrl = TextEditingController();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    otpCtrl.dispose();
    super.onClose();
  }

  void signup() async {
    if (formKey.currentState!.validate()) {
      processing.value = true;

      final names = nameCtrl.text.trim().split(RegExp(r'\s{1,}'));
      final data = {
        'firstname': names[0],
        'lastname': names.sublist(1).join(' '),
        'email': emailCtrl.text,
        'phone': phoneData.phoneNumber,
        'password': passwordCtrl.text,
        'countryCode': phoneData.isoCode
      };

      print('Reg Req: $data');

      final result = await http.signup(data);
      if (result is String) {
        PopupManager.error(
          title: 'Registration Failed!',
          message: result
        );
      } else {
        PopupManager.success(
          title: 'Registration Successful',
          message: 'Verify account to continue.'
        );

        stage.value = SignupStage.verify;
      }

      processing.value = false;
    } else {
      validateMode.value = AutovalidateMode.onUserInteraction;
    }
  }

  void verifyToken() async {
    if (otpFormKey.currentState!.validate()) {
      processing.value = true;
      final result = await http.verifyEmail(emailCtrl.text, otpCtrl.text);
      if (result is String) {
        PopupManager.error(
          title: 'Failed',
          message: result
        );
      } else {
        PopupManager.success(
          title: 'Success',
          message: 'Email verification completed.'
        );

        Get.off(Login(), id: 0);
      }

      processing.value = false;
    }
  }

  void resendOTP() async {
    if (true) {
      processing.value = true;
      final result = await http.resendOTP(emailCtrl.text);
      if (result) {
        PopupManager.success(
          title: 'OTP sent',
          message: 'OTP was sent to your email address.'
        );
      } else {
        PopupManager.error(
          title: 'Failed',
          message: 'Error sending OTP.'
        );
      }

      processing.value = false;
    }
  }
}

enum SignupStage {
  initial,
  verify
}