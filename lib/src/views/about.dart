import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class About extends StatelessWidget {
  const About({super.key});

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
        title: Text('About ARU', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black
        )),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildListItem(
            icon: TablerIcons.file_text,
            title: 'Privacy Policy',
            subtitle: 'Read about our orivacy policy'
          ),
          const SizedBox(height: 16),
          _buildListItem(
            icon: TablerIcons.file_text,
            title: 'Terms of Use',
            subtitle: 'Read about our terms of use'
          )
        ],
      ),
    );
  }

  Widget _buildListItem({IconData? icon, String? title, String? subtitle, Function()? onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      horizontalTitleGap: 24,
      tileColor: Colors.white,
      onTap: onTap,
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