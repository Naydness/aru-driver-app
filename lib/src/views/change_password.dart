import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: colorPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        title: Text('Change Password', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black
        )),
      ),
      body: Stack(
        children: [
          Obx(() => Form(
            key: controller.formKey,
            // autovalidateMode: controller.validateMode.value,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60
                  ),
                  child: CustomTextField(
                    controller: controller.currPasswd,
                    label: 'Current Password',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Current password is required';
                      } return null;
                    },
                    obscureText: controller.hidePassword.value,
                    suffixIcon: controller.hidePassword.value
                      ? TablerIcons.eye_off
                      : TablerIcons.eye,
                    onSuffixIconTap: () => controller.hidePassword.toggle(),
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: colorBlack2
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60
                  ),
                  child: CustomTextField(
                    controller: controller.newPasswd,
                    label: 'New Password',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'New password is required';
                      } return null;
                    },
                    obscureText: controller.hidePassword.value,
                    suffixIcon: controller.hidePassword.value
                      ? TablerIcons.eye_off
                      : TablerIcons.eye,
                    onSuffixIconTap: () => controller.hidePassword.toggle(),
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: colorBlack2
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60
                  ),
                  child: CustomTextField(
                    controller: controller.confirmPasswd,
                    label: 'Confirm New Password',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Confirm new password';
                      } else if (v != controller.newPasswd.text) {
                        return 'New password does not match';
                      } return null;
                    },
                    obscureText: controller.hidePassword.value,
                    suffixIcon: controller.hidePassword.value
                      ? TablerIcons.eye_off
                      : TablerIcons.eye,
                    onSuffixIconTap: () => controller.hidePassword.toggle(),
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: colorBlack2
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 60,
                  child: Buttons.text('Submit', onPressed: () {
                    FocusScopeNode focus = FocusScope.of(context);
                    if (!focus.hasPrimaryFocus) {
                      focus.unfocus();
                    }

                    controller.updatePassword();
                  }).primary.build()
                )
              ],
            ),
          )),
          Obx(() {
            if (controller.processing.value) {
              return buildLoader();
            } return Container();
          })
        ],
      )
    );
  }

  Widget _buildListItem({IconData? icon, String? title, String? subtitle}) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      horizontalTitleGap: 24,
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        radius: 22,
        child: Icon(icon, size: 20,)
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorBlack2
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 12,
        color: Color(0xFF858585)
      ),
      title: Text('$title'),
      subtitle: Text('$subtitle'),
      trailing: Icon(TablerIcons.arrow_right, color: colorPrimary,),
    );
  }
}

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;
  final HttpService http = Get.find();
  RxBool hidePassword = true.obs;
  RxBool processing = false.obs;

  late TextEditingController currPasswd;
  late TextEditingController newPasswd;
  late TextEditingController confirmPasswd;

  @override
  void onInit() {
    super.onInit();
    currPasswd = TextEditingController();
    newPasswd = TextEditingController();
    confirmPasswd = TextEditingController();
  }

  @override
  void onClose() {
    currPasswd.dispose();
    newPasswd.dispose();
    confirmPasswd.dispose();
    super.onClose();
  }

  void updatePassword() async {
    if (formKey.currentState!.validate()) {
      processing.value = true;
      final result = await http.changePassword(currPasswd.text, newPasswd.text);
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
    } else {
      validateMode.value = AutovalidateMode.onUserInteraction;
    }
  }
}