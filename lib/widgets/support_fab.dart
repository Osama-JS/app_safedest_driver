import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Helpers/SupportHelper.dart';

class SupportFAB extends StatelessWidget {
  const SupportFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => SupportHelper.showSupportDialog(context),
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(
        Icons.support_agent,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
