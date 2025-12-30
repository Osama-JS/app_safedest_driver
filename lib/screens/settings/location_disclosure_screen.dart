import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationDisclosureScreen extends StatelessWidget {
  const LocationDisclosureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('locationDisclosureTitle'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Icon(Icons.location_on, size: 56, color: Colors.blue),
              const SizedBox(height: 16),

              Text(
                'locationDisclosureTitle'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Text(
                'locationDisclosureMessage'.tr,
                style: const TextStyle(height: 1.4, fontSize: 14),
              ),

              const SizedBox(height: 12),
              Text(
                'locationDisclosureBullets'.tr,
                style: const TextStyle(height: 1.4, fontSize: 13),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('deny'.tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: Text('accept'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
