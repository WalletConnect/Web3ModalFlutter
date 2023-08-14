import 'package:flutter/material.dart';

class Util {
  static String shorten(
    String value, {
    bool short = false,
  }) {
    return short && value.length > 8 ? '${value.substring(0, 8)}..' : value;
  }

  static String truncate(String value, {int length = 8}) {
    if (value.length <= length) {
      return value;
    }

    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static List<Color> generateAvatarColors(String address) {
    final RegExp regExp = RegExp(r'.{1,7}');
    List<Match> matches = regExp.allMatches(address).toList();
    List<String> seedArr =
        matches.sublist(0, 5).map((m) => m.group(0)!).toList();
    List<Color> colors = [];

    for (var seed in seedArr) {
      int hash = 0;
      for (int i = 0; i < seed.length; i++) {
        hash = seed.codeUnitAt(i) + ((hash << 5) - hash);
        hash = hash & hash;
      }

      List<int> rgb = [0, 0, 0];
      for (int i = 0; i < 3; i++) {
        int value = (hash >> (i * 8)) & 255;
        rgb[i] = value;
      }

      colors.add(
        Color.fromARGB(
          255,
          rgb[0],
          rgb[1],
          rgb[2],
        ),
      );
    }

    return colors;
  }
}
