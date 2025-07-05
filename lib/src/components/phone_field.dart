import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({super.key, this.fillColor, this.validator, this.controller, this.onChanged, this.initialValue});

  final Color? fillColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final PhoneNumber? initialValue;
  final Function(PhoneNumber)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: fillColor ?? colorPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14)
      ),
      child: InternationalPhoneNumberInput(
        textFieldController: controller,
        validator: validator,
        initialValue: initialValue,
        onInputChanged: onChanged,
        cursorColor: colorPrimary,
        searchBoxDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: TextStyle(color: colorBlack1),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorBlack1)
          )
        ),
        inputDecoration: InputDecoration(
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: 'Phone Number',
          hintStyle: TextStyle(
            color: Color(0xFF7C8BA0),
            fontSize: 12
          )
        ),
        selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.DIALOG
        ),
      ),
    );
  }
}