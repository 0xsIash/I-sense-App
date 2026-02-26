import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgWrapper extends StatelessWidget {
  const CustomSvgWrapper({super.key, required this.path, this.iconWidth, this.iconHeight});

  final String path;
  final double? iconWidth;
  final double? iconHeight;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
                path, 
                width: iconWidth,
                height: iconHeight,
              );
  }
}