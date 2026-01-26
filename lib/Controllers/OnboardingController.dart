import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared_prff.dart';
import '../Languages/LanguageController.dart';

class OnboardingController extends GetxController {
  var pageController = PageController();
  var currentPage = 0.obs;
  final LanguageController _languageController = Get.find();
  var selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    selectedLanguage.value = Selected_Language.getLanguage() ?? 'en';
  }

  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    _languageController.changeLanguage(languageCode);
  }

  List<Map<String, String>> onboardingData = [
    {
      "title": "onboarding_title_1",
      "desc": "onboarding_desc_1",
      // "image": "assets/images/onboarding_1.png" // Placeholder
    },
    {
      "title": "onboarding_title_2",
      "desc": "onboarding_desc_2",
      // "image": "assets/images/onboarding_2.png" // Placeholder
    },
    {
      "title": "onboarding_title_3",
      "desc": "onboarding_desc_3",
      // "image": "assets/images/onboarding_3.png" // Placeholder
    }
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      finishOnboarding();
    }
  }

  void skip() {
    finishOnboarding();
  }

  Future<void> finishOnboarding() async {
    await Bool_pref.setBool('seenOnboarding', true);
    Get.offAllNamed('/login');
  }
}
