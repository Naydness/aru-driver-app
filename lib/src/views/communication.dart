import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'change_password.dart';

class Communication extends StatelessWidget {
  const Communication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: colorPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        title: Text('Communication', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black
        )),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildListItem(
            icon: TablerIcons.mail,
            title: 'Email',
          ),
          const SizedBox(height: 16),
          _buildListItem(
            icon: TablerIcons.message,
            title: 'SMS',
          )
        ],
      ),
    );
  }

  Widget _buildListItem({IconData? icon, String? title, Function(bool)? onChanged}) {
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
      trailing: Switch.adaptive(
        value: false, 
        activeColor: colorPrimary,
        onChanged: onChanged
      )
    );
  }
}