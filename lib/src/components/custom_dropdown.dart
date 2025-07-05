import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key, 
    this.onChanged, 
    required this.value, 
    required this.items
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)?onChanged;


  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField2<T>(
        value: value,
        /*items: [
          DropdownMenuItem(child: Text('First'), value: 1,),
          DropdownMenuItem(child: Text('Second'), value: 2,),
          DropdownMenuItem(child: Text('Third'), value: 3,)
        ], */
        items: items,
        onChanged: onChanged,
        buttonStyleData: ButtonStyleData(
          padding: EdgeInsets.only(left: 0)
        ),
        dropdownStyleData: DropdownStyleData(
          offset: Offset(0, -12),
          elevation: 0,
          decoration: BoxDecoration(color: Colors.white)
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8)
          )
        ),
      )
    );
  }
}