import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef PressAction = void Function()?;

class Buttons {
  static ButtonConfig text(String data, { 
    PressAction onPressed, 
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? prefixPath,
    String? suffixPath
  }) {
    return ButtonConfig(
      label: data, 
      onPressed: onPressed,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixPath: prefixPath,
      suffixPath: suffixPath
    );
  }

  static ButtonConfig get icon {
    return ButtonConfig();
  }
}


class ButtonConfig {
  ButtonType type;
  PressAction onPressed;
  double height;
  Color? bgColor;
  Color? fgColor;
  String label;
  IconData? prefixIcon;
  IconData? suffixIcon;
  String? prefixPath;
  String? suffixPath;
  bool border;
  String? icon;

  ButtonConfig({
    this.type = ButtonType.text, 
    this.onPressed,
    this.height = 56,
    Color? bgColor, 
    Color? fgColor, 
    this.label = '',
    this.prefixIcon,
    this.suffixIcon,
    this.prefixPath,
    this.suffixPath,
    this.border = false
  }): bgColor = bgColor ?? colorPrimary,
      fgColor = fgColor ?? Colors.white,
      assert(prefixIcon == null || prefixPath == null, 'Cannot provide both prefixIcon and preixPath');

  ButtonConfig get primary {
    bgColor = colorPrimary;
    fgColor = Colors.white;
    
    return this;
  }

  ButtonConfig get red {
    bgColor = colorRed;
    fgColor = Colors.white;
    
    return this;
  }

  ButtonConfig get green {
    bgColor = colorGreen;
    fgColor = Colors.white;
    
    return this;
  }

  ButtonConfig get white{
    bgColor = Colors.white;
    fgColor = Color(0xFF858585);
    
    return this;
  }

  ButtonConfig get neutral{
    bgColor = Color(0xFF858585);
    fgColor = Colors.white;
    
    return this;
  }

  ButtonConfig get outlined {
    border = true;
    fgColor = bgColor;

    return this;
  }

  ButtonConfig get md {
    height = 48;
    return this;
  }

  ButtonConfig get sm {
    height = 28;
    return this;
  }

  Widget build() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 128
        // maxWidth: 229
      ),
      child: SizedBox(
        height: height,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: border ? Colors.transparent : bgColor,
            foregroundColor: fgColor,
            textStyle: Theme.of(Get.context!).textTheme.bodyLarge!
              .copyWith(fontWeight: FontWeight.w400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: border 
                ? BorderSide(color: fgColor ?? colorPrimary) 
                : BorderSide.none
            )
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(
                  prefixIcon!,
                  color: fgColor
                ),
                const SizedBox(width: 12,)
              ],
              if (prefixPath != null) ...[
                Image.asset('assets/images/$prefixPath'),
                const SizedBox(width: 12,)
              ],
              Text(label, style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fgColor
              )),
              if (suffixIcon != null) ...[
                const SizedBox(width: 5,),
                Icon(
                  suffixIcon!,
                  color: Colors.black
                )
              ],
              if (suffixPath != null) ...[
                const SizedBox(width: 12,),
                Image.asset('assets/images/$suffixPath')
              ],
            ]
          )
        )
      )
    );
  }
}

enum ButtonType {
  text,
  icon
}