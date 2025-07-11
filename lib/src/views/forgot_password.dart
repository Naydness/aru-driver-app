import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/otp.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    ForgotPasswordController controller = Get.put(ForgotPasswordController()); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(id: 0),
          icon: Icon(TablerIcons.arrow_left),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.stage.value == FPStage.requestToken) {
              return Form(
                key: controller.stage0FormKey,
                autovalidateMode: controller.stage0ValidateMode,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16,),
                    Align(
                      alignment: Alignment.center,
                      child: Text('Reset Password', style: TextStyle(
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
                            return 'Email address is required';
                          } return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32,),
                    SizedBox(
                      height: 60,
                      child: Buttons
                        .text('Continue', onPressed: () {
                          FocusScopeNode focus = FocusScope.of(context);
                          if (!focus.hasPrimaryFocus) {
                            focus.unfocus();
                          }
                          controller.sendCode();
                        }).primary.build(),
                    )
                  ],
                )
              );
            }

            if (controller.stage.value == FPStage.validateToken) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    Image.asset('assets/images/app_logo.png', width: 100, height: 100,),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: Text('Enter OTP', style: TextStyle(
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
                          formKey: controller.stage1FormKey,
                          tokenController: controller.otpCtrl,
                          submitText: 'Reset Password',
                          onSubmit: () {
                            if (controller.stage1FormKey.currentState!.validate()) {
                              controller.stage.value = FPStage.updatePassword;
                            }
                          }
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
              );
            }

            if (controller.stage.value == FPStage.updatePassword) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Form(
                  key: controller.stage2FormKey,
                  autovalidateMode: controller.stage2ValidateMode,
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    children: [
                      Image.asset('assets/images/app_logo.png', width: 100, height: 100,),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: Text('Set New Password', style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                        ))
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 60
                        ),
                        child: CustomTextField(
                          controller: controller.passwd1Ctrl,
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
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 60
                        ),
                        child: CustomTextField(
                          controller: controller.passwd2Ctrl,
                          label: 'Confirm password',
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            } else if (v != controller.passwd1Ctrl.text) {
                              return 'Passwords do not match';
                            } return null;
                          },
                          obscureText: controller.hidePassword.value,
                          suffixIcon: controller.hidePassword.value
                            ? TablerIcons.eye_off
                            : TablerIcons.eye,
                          onSuffixIconTap: () => controller.hidePassword.toggle(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: Buttons.text('Submit', onPressed: () {
                          FocusScopeNode focus = FocusScope.of(context);
                          if (!focus.hasPrimaryFocus) {
                            focus.unfocus();
                          }

                          controller.updatePassword();
                        }).primary.build(),
                      )
                    ],
                  )
                )
              );
            }

            return Container();
          }),
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

class ForgotPasswordController extends GetxController {
  Rx<FPStage> stage = FPStage.requestToken.obs;

  final stage0FormKey = GlobalKey<FormState>();
  final stage1FormKey = GlobalKey<FormState>();
  final stage2FormKey = GlobalKey<FormState>();
  AutovalidateMode stage0ValidateMode = AutovalidateMode.disabled;
  AutovalidateMode stage1ValidateMode = AutovalidateMode.disabled;
  AutovalidateMode stage2ValidateMode = AutovalidateMode.disabled;
  RxBool processing = false.obs;

  late TextEditingController emailCtrl;
  late TextEditingController otpCtrl;
  RxBool hidePassword = true.obs;
  late TextEditingController passwd1Ctrl;
  late TextEditingController passwd2Ctrl;

  final HttpService http = Get.find();

  @override
  void onInit() {
    super.onInit();
    emailCtrl = TextEditingController();
    otpCtrl = TextEditingController();
    passwd1Ctrl = TextEditingController();
    passwd2Ctrl = TextEditingController();
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    otpCtrl.dispose();
    passwd1Ctrl.dispose();
    passwd2Ctrl.dispose();
    super.onClose();
  }

  void sendCode() async {
    if (stage0FormKey.currentState!.validate()) {
      processing.value = true;

      final result = await http.forgotPassword(emailCtrl.text);
      if (result) {
        stage.value = FPStage.validateToken;
      } else {
        PopupManager.error(
          title: 'Error',
          message: 'Unable to reset password. Please try again later.'
        );
      }
      
      processing.value = false;
    }
  }

  /*void verifyToken() async {
    if (stage1FormKey.currentState!.validate()) {
      processing.value = true;
      
      stage.value = FPStage.updatePassword;
    }
  }*/

  void updatePassword() async {
    if (stage2FormKey.currentState!.validate()) {
      processing.value = true;
      
      final data = {
        'email': emailCtrl.text,
        'otp': otpCtrl.text,
        'password': passwd1Ctrl.text
      };

      final result = await http.resetPassword(data);
      if (result is bool) {
        Get.back();
        PopupManager.success(
          title: 'Success',
          message: 'Password updated successfully.'
        );
      } else {
        PopupManager.error(
          title: 'Failed',
          message: result
        );
      }

      processing.value = false;
    }
  }
}

enum FPStage {
  requestToken,
  validateToken,
  updatePassword
}