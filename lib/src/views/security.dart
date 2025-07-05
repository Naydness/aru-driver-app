import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'change_password.dart';

class Security extends StatelessWidget {
  const Security({super.key});

  @override
  Widget build(BuildContext context) {
    final SecurityController controller = Get.put(SecurityController());

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: colorPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        title: Text('Security', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black
        )),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildListItem(
            icon: TablerIcons.lock,
            title: 'Password',
            subtitle: 'Change your current password',
            onTap: () => Get.to(ChangePassword())
          ),
          const SizedBox(height: 16),
          Obx(() => _buildListItem(
            icon: TablerIcons.fingerprint_scan,
            title: 'Biometrics',
            subtitle: 'Turn on Face ID or Fingerprint',
            trailing: Switch.adaptive(
              value: controller.bioAuth.value, 
              activeColor: colorPrimary,
              onChanged: (v) => controller.setBioAuth(v)
            )
          ))
        ],
      ),
    );
  }

  Widget _buildListItem({IconData? icon, String? title, String? subtitle, Function()? onTap, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 60
        ),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
              radius: 22,
              child: Icon(icon, size: 20,)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$title', style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorBlack2
                  )),
                  const SizedBox(height: 8,),
                  Text('$subtitle', style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF858585)
                  ))
                ],
              )
            ),
            const SizedBox(width: 8,),
            trailing ?? Icon(TablerIcons.arrow_right, color: colorPrimary,)
          ],
        ),
      )
    );
  }
}

class SecurityController extends GetxController {
  RxBool bioAuth = false.obs;

  @override
  void onInit() async {
    super.onInit();
    bioAuth.value = await GetStorage().read('bioAuth');
  }

  void setBioAuth(bool v) {
    bioAuth.value = v;
    GetStorage().write('bioAuth', bioAuth.value);
  }
}