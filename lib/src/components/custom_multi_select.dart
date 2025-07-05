import 'package:aru/src/constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

class CustomMultiSelect extends StatelessWidget {
  const CustomMultiSelect({
    super.key, 
    this.list = const [],
    required this.onChanged,
    this.numItemLabels = 3
  });

  final List list;
  final Function(List) onChanged;
  final int numItemLabels;


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.white,
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(Colors.white),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorPrimary;
            }

            return Colors.transparent;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          )
        )
      ),
      child: SizedBox(
        height: 60,
        child: MultiSelectDropdown(
          list: list, 
          initiallySelected: const [], 
          onChange: onChanged,
          numberOfItemsLabelToShow: numItemLabels,
          textStyle: TextStyle(
            fontSize: 14,
            color: Color(0xFF212121)
          ),
          splashColor: Colors.grey,
          includeSelectAll: false,
          includeSearch: false,
          boxDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8)
          ),
        )
      ),
    );
  }
}