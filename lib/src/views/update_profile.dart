import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/phone_field.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final UpdateProfileController controller = Get.put(UpdateProfileController());

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: colorPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        title: Text('Edit Profile', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black
        )),
      ),
      body: Stack(
        children: [
          Obx(() => Form(
            key: controller.formKey,
            autovalidateMode: controller.validateMode.value,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60
                  ),
                  child: CustomTextField(
                    controller: controller.nameCtrl,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Name is required';
                      } return null;
                    },
                    label: 'Name',
                    suffixIcon: TablerIcons.eye_off,
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
                    controller: controller.emailCtrl,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email address is required';
                      } return null;
                    },
                    label: 'Email address',
                    readOnly: true,
                    suffixIcon: TablerIcons.eye_off,
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
                  child: PhoneField(
                    controller: controller.phoneCtrl,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Phone number is required';
                      } return null;
                    },
                    initialValue: controller.phoneData,
                    onChanged: (phone) {
                      controller.phoneData = phone;
                    },
                    fillColor: Colors.white
                  )
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 60,
                  child: Buttons.text('Update', onPressed: () {
                    FocusScopeNode focus = FocusScope.of(context);
                    if (!focus.hasPrimaryFocus) {
                      focus.unfocus();
                    }

                    controller.updateProfile();
                  }).primary.build()
                )
              ],
            )
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

class UpdateProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;
  final HttpService http = Get.find();
  final AuthManager authManager = Get.find();
  RxBool processing = false.obs;

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  PhoneNumber phoneData = PhoneNumber();

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();

    nameCtrl.text = authManager.userFullName;
    emailCtrl.text = authManager.user['email'];
    final String phone = authManager.user['phoneNumber'];
    phoneData = PhoneNumber(
      phoneNumber: phone,
      dialCode: phone.substring(0, 4),
      isoCode: 'NG'
    );
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
  }

  void updateProfile() async {
    if (formKey.currentState!.validate()) {
      processing.value = true;

      final names = nameCtrl.text.trim().split(RegExp(r'\s{1,}'));
      final result = await http.updateProfile(
        names[0], 
        names.sublist(1).join(' '),
        phoneData.phoneNumber!
      );

      if (result is String) {
        PopupManager.error(
          title: 'Failed',
          message: 'Error updating profile'
        );
      } else {
        Get.back();
        PopupManager.success(
          title: 'Success',
          message: 'Profile updated successfully.'
        );
        authManager.saveUser(result);
      }

      processing.value = false;
    } else {
      validateMode.value = AutovalidateMode.onUserInteraction;
    }
  }
}