 import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';

Widget emptyListDefault( String title, Color color) {
    return  Padding(padding: const EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 20) , child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.list_rounded, color: color, size: 100,),
           Text(
          title,
          textAlign: TextAlign.center,
            style:  AppFonts.title3.copyWith(color: color),
            ),
          ],
        ),
     );
  }

