import 'dart:convert';

import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildLoader({double? opacity}) {
  return Container(
    color: Colors.white.withValues(alpha: opacity ?? 0.7),
    child: Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation(colorAccent),
      ),
    ),
  );
}

Widget buildEmptyPlaceholder({double? opacity, String? text}) {
  return Container(
    color: Colors.white.withValues(alpha: opacity ?? 0),
    child: Center(
      child: Text(text ?? 'No record', style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorBlack2
      )),
    ),
  );
}

Widget buildErrorPlaceholder({String? text}) {
  return Container(
    color: Colors.white,
    child: Center(
      child: Text(text ?? 'Something went wrong', style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorBlack2
      )),
    ),
  );
}

Future loadJson(String path) async {
  final jsonString = await rootBundle.loadString(path);
  final json = jsonDecode(jsonString);
  return json;
}

enum OrderType {
  ride('68493bb94f6cb8d6c883d589', 10),
  package('68493be94f6cb8d6c883d58b', 15);

  const OrderType(this.id, this.baseFare);

  final String id;
  final double baseFare;

  static fromString(String type) {
    late OrderType orderType;
    switch (type) {
      case 'package':
        orderType = OrderType.package;
        break;
      default:
        orderType = OrderType.ride;
    }

    return orderType;
  }

  static fromIndex(int index) {
    late OrderType orderType;
    switch (index) {
      case 1:
        orderType = OrderType.package;
        break;
      default:
        orderType = OrderType.ride;
    }

    return orderType;
  }
}