import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void updateIndex(int index) => currentIndex.value = index;
}
