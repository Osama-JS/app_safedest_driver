import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/OnboardingController.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Language Selection Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Buttons
                  // Obx(
                  //   () => Row(
                  //     children: [
                  //       OnboardingScreen._buildLanguageButton(
                  //         context,
                  //         'ar',
                  //         'ع',
                  //         controller.selectedLanguage.value == 'ar',
                  //         controller,
                  //       ),
                  //       const SizedBox(width: 8),
                  //       OnboardingScreen._buildLanguageButton(
                  //         context,
                  //         'en',
                  //         'EN',
                  //         controller.selectedLanguage.value == 'en',
                  //         controller,
                  //       ),
                  //       const SizedBox(width: 8),
                  //       OnboardingScreen._buildLanguageButton(
                  //         context,
                  //         'ur',
                  //         'اُ',
                  //         controller.selectedLanguage.value == 'ur',
                  //         controller,
                  //       ),
                  //       const SizedBox(width: 8),
                  //       OnboardingScreen._buildLanguageButton(
                  //         context,
                  //         'zh',
                  //         '中',
                  //         controller.selectedLanguage.value == 'zh',
                  //         controller,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Language Buttons
                  Obx(
                        () => Row(
                      children: [
                        OnboardingScreen._buildLanguageButton(
                          context,
                          'ar',
                          '🇸🇦', // علم السعودية للغة العربية
                          controller.selectedLanguage.value == 'ar',
                          controller,
                        ),
                        const SizedBox(width: 8),
                        OnboardingScreen._buildLanguageButton(
                          context,
                          'en',
                          '🇺🇸', // علم أمريكا للغة الإنجليزية
                          controller.selectedLanguage.value == 'en',
                          controller,
                        ),
                        const SizedBox(width: 8),
                        OnboardingScreen._buildLanguageButton(
                          context,
                          'ur',
                          '🇵🇰', // علم باكستان للغة الأوردو
                          controller.selectedLanguage.value == 'ur',
                          controller,
                        ),
                        const SizedBox(width: 8),
                        OnboardingScreen._buildLanguageButton(
                          context,
                          'zh',
                          '🇨🇳', // علم الصين للغة الصينية
                          controller.selectedLanguage.value == 'zh',
                          controller,
                        ),
                      ],
                    ),
                  ),
                  // Skip Button
                  TextButton(
                    onPressed: controller.skip,
                    child: Text(
                      'skip'.tr,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onboardingData.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: controller.onboardingData[index]['title'] ?? '',
                    desc: controller.onboardingData[index]['desc'] ?? '',
                    index: index,
                  );
                },
              ),
            ),

            // Dots Indicator & Next Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Dots
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 10,
                          width: controller.currentPage.value == index ? 25 : 10,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          controller.currentPage.value ==
                                  controller.onboardingData.length - 1
                              ? 'get_started'.tr
                              : 'next'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // static Widget _buildLanguageButton(
  //   BuildContext context,
  //   String locale,
  //   String label,
  //   bool isSelected,
  //   OnboardingController controller,
  // ) {
  //   return GestureDetector(
  //     onTap: () => controller.changeLanguage(locale),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? Theme.of(context).primaryColor
  //             : Colors.grey.shade200,
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: isSelected
  //               ? Theme.of(context).primaryColor
  //               : Colors.grey.shade300,
  //           width: 1.5,
  //         ),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           color: isSelected ? Colors.white : Colors.grey.shade700,
  //           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //           fontSize: 14,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  static Widget _buildLanguageButton(
      BuildContext context,
      String locale,
      String flag, // نغير التسمية لـ flag للوضوح
      bool isSelected,
      OnboardingController controller,
      ) {
    return GestureDetector(
      onTap: () => controller.changeLanguage(locale),
      child: AnimatedContainer( // أضفنا حركة بسيطة عند الاختيار
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.2) // خلفية فاتحة عند الاختيار
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          flag,
          style: const TextStyle(
            fontSize: 22, // حجم العلم ليكون واضحاً كأيقونة
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String desc;
  final int index;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.desc,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Placeholder (Animate It)
          Expanded(
            flex: 3,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        // Dynamic icons based on index
                        index == 0
                            ? Icons.bar_chart_rounded
                            : index == 1
                                ? Icons.delivery_dining_rounded
                                : Icons.account_balance_wallet_rounded,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 40),

          // Text Content (Fade/Slide Up)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  desc.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
