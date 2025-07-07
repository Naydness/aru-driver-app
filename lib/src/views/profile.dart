import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'about.dart';
import 'login.dart';
import 'security.dart';
import 'settings.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    AuthManager authManager = Get.find();
    ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
        title: Text('Profile')
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 24, 47),
          image: DecorationImage(
            image: AssetImage('assets/images/map_bg_overlay.png'),
            fit: BoxFit.cover
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 120, 16, 0),
              child: Obx(() => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    // child: Image.asset('assets/images/user.png'),
                    child: Text(authManager.userInitials, style: TextStyle(
                      color: colorBlack1,
                      fontWeight: FontWeight.w600,
                      fontSize: 20
                    )),
                  ),
                  const SizedBox(height: 16,),
                  Text(authManager.userFullName, style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white
                  )),
                  const SizedBox(height: 8,),
                  Text(authManager.user['email'], style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                  ))
                ],
              ),
            )),
            const SizedBox(height: 24,),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)
                  )
                ),
                child: controller.obx(
                  (state) {
                    final profile = state!;
                    final balance = profile['wallet']['balance'];
                    // print('Profile: $profile');

                    return RefreshIndicator.adaptive(
                      // onRefresh: () async => controller.init(),
                      onRefresh: () async {},
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildProfileItem(
                            icon: TablerIcons.shield_check,
                            label: 'Security',
                            onTap: () => Get.to(Security())
                          ),
                          const SizedBox(height: 16,),
                          _buildProfileItem(
                            icon: TablerIcons.settings,
                            label: 'Settings',
                            onTap: () => Get.to(Settings())
                          ),
                          const SizedBox(height: 16,),
                          _buildProfileItem(
                            icon: TablerIcons.credit_card_pay,
                            label: 'Payment',
                            onTap: () {}
                          ),
                          const SizedBox(height: 16,),
                          _buildProfileItem(
                            icon: TablerIcons.jewish_star,
                            label: 'Ratings',
                            onTap: () {}
                          ),
                          const SizedBox(height: 16,),
                          _buildProfileItem(
                            icon: TablerIcons.help_circle,
                            label: 'Help Centre',
                            onTap: () {}

                          ),
                          const SizedBox(height: 16,),
                          _buildProfileItem(
                            icon: TablerIcons.info_circle,
                            label: 'About ARU',
                            onTap: () => Get.to(About())

                          ),
                          const SizedBox(height: 16,),
                          _buildProfileItem(
                            icon: TablerIcons.logout,
                            label: 'Sign Out',
                            onTap: () {
                              controller.logout();
                            }
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.center,
                            child: Text('App Version 1.0.0', style: TextStyle(
                              fontSize: 10,
                              color: Colors.black
                            ))
                          )
                        ],
                      )
                    );
                  },
                  onLoading: buildLoader(opacity: 0),
                  onError: (err) => Center(child: Text('Something went wrong'),)
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({IconData? icon, String? label, Function()? onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorPrimary,
          foregroundColor: Colors.white,
          radius: 20,
          child: Icon(icon, size: 20),
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorBlack2,
          fontSize: 14
        ),
        title: Text('$label'),
        trailing: Icon(TablerIcons.arrow_right, color: colorPrimary,),
      ),
    );
  }
}

class ProfileController extends GetxController with StateMixin {
  final HttpService http = Get.find();
  final AuthManager authManager = Get.find();
  Map? user;

  @override
  void onReady() {
    final user = authManager.user;
    change(user, status: RxStatus.success());
  }

  void init() async {
    change(null, status: RxStatus.loading());
    final result = await http.getUserProfile();
    if (result is String) {
      change(result, status: RxStatus.error());
    } else {
      user = result;
      change(result, status: RxStatus.success());
    }
  }

  void logout() {
    AuthManager authManager = Get.find();

    Get.until((route) => route.settings.name == '/');
    Get.off(Login(), id: 0);
    authManager.logout();
  }
}