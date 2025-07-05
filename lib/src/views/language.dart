import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'change_password.dart';

class Language extends StatelessWidget {
  const Language({super.key});

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
        title: Text('Language', style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black
        )),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildListItem(
            flag: 'english.png',
            title: 'English (US)',
            trailing: Radio.adaptive(
              value: 'english', 
              groupValue: 'english', 
              onChanged: (v) {}
            )
          ),
          const SizedBox(height: 16),
          _buildListItem(
            flag: 'hindi.png',
            title: 'Hindi',
            trailing: Radio.adaptive(
              value: 'hindi', 
              groupValue: 'english', 
              onChanged: (v) {}
            )
          ),
          const SizedBox(height: 16),
          _buildListItem(
            flag: 'chinese.png',
            title: 'Chinese',
            trailing: Radio.adaptive(
              value: 'chinese', 
              groupValue: 'english', 
              onChanged: (v) {}
            )
          ),
          const SizedBox(height: 16),
          _buildListItem(
            flag: 'spanish.png',
            title: 'Spanish',
            trailing: Radio.adaptive(
              value: 'spanish', 
              groupValue: 'english', 
              onChanged: (v) {}
            )
          ),
          const SizedBox(height: 16),
          _buildListItem(
            flag: 'arabic.png',
            title: 'Arabic',
            trailing: Radio.adaptive(
              value: 'arabic', 
              groupValue: 'english', 
              onChanged: (v) {}
            )
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({String? flag, String? title, Widget? trailing}) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      horizontalTitleGap: 24,
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/$flag'),
        radius: 18,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorBlack2,
        fontSize: 14
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 12,
        color: Color(0xFF858585)
      ),
      title: Text('$title'),
      trailing: trailing
    );
  }
}