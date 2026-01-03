// 공통으로 사용할 Snack Bar와 Dialog 기능을 구현

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message {
  // Snack Bar
  void errorSnackBar(String title, String message){
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  void successSnackBar(String title, String message){
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Dialog
  void showDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      backgroundColor: Colors.white,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}