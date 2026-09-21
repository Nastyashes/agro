 import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

Widget appBarBack( String title) {
    return   Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white,),
                      ),
                      Expanded(
                        child: Text(
                        title,
                          style: AppFonts.title2.white,
                        ),
                      ),
                    ],
                  ),
                );
  }

