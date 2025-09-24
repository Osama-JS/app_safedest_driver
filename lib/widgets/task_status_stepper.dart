import 'package:flutter/material.dart';
import '../models/task.dart';
import '../l10n/generated/app_localizations.dart';

class TaskStatusStepper extends StatelessWidget {
  final Task task;

  const TaskStatusStepper({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps(context);
    final currentStepIndex = _getCurrentStepIndex(steps);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'مراحل المهمة'
                      : 'Task Stages',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHorizontalStepper(context, steps, currentStepIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalStepper(
      BuildContext context, List<TaskStep> steps, int currentStepIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index <= currentStepIndex;
          final isCurrent = index == currentStepIndex;
          final isCompleted = index < currentStepIndex;

          return Row(
            children: [
              _buildStepItem(context, step, isActive, isCurrent, isCompleted),
              if (index < steps.length - 1)
                _buildConnector(context, index < currentStepIndex),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, TaskStep step, bool isActive,
      bool isCurrent, bool isCompleted) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    IconData icon;

    if (isCompleted) {
      backgroundColor = Colors.green;
      iconColor = Colors.white;
      textColor = Colors.green;
      icon = Icons.check;
    } else if (isCurrent) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      iconColor = Colors.white;
      textColor = Theme.of(context).colorScheme.primary;
      icon = _getStepIcon(step.status);
    } else {
      backgroundColor =
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
      iconColor =
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      textColor =
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      icon = _getStepIcon(step.status);
    }

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(BuildContext context, bool isCompleted) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  IconData _getStepIcon(String status) {
    switch (status) {
      case 'assign':
        return Icons.assignment;
      case 'started':
        return Icons.play_arrow;
      case 'in pickup point':
        return Icons.location_on;
      case 'loading':
        return Icons.upload;
      case 'in the way':
        return Icons.local_shipping;
      case 'in delivery point':
        return Icons.flag;
      case 'unloading':
        return Icons.download;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.circle;
    }
  }

  List<TaskStep> _getSteps(BuildContext context) {
    // استخدام النصوص المترجمة مباشرة حتى يتم إصلاح مشكلة توليد ملفات الترجمة
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return [
      TaskStep(
        title: isArabic ? 'مخصصة' : 'Assigned',
        content:
            isArabic ? 'تم تخصيص المهمة للسائق' : 'Task assigned to driver',
        status: 'assign',
      ),
      TaskStep(
        title: isArabic ? 'بدأت' : 'Started',
        content:
            isArabic ? 'بدأ السائق في تنفيذ المهمة' : 'Driver started the task',
        status: 'started',
      ),
      TaskStep(
        title: isArabic ? 'في نقطة الاستلام' : 'At Pickup Point',
        content: isArabic
            ? 'وصل السائق لنقطة الاستلام'
            : 'Driver arrived at pickup point',
        status: 'in pickup point',
      ),
      TaskStep(
        title: isArabic ? 'جاري التحميل' : 'Loading',
        content: isArabic ? 'يتم تحميل البضائع' : 'Loading goods',
        status: 'loading',
      ),
      TaskStep(
        title: isArabic ? 'في الطريق' : 'On the Way',
        content: isArabic
            ? 'السائق في طريقه لنقطة التسليم'
            : 'Driver on the way to delivery point',
        status: 'in the way',
      ),
      TaskStep(
        title: isArabic ? 'في نقطة التسليم' : 'At Delivery Point',
        content: isArabic
            ? 'وصل السائق لنقطة التسليم'
            : 'Driver arrived at delivery point',
        status: 'in delivery point',
      ),
      TaskStep(
        title: isArabic ? 'جاري التفريغ' : 'Unloading',
        content: isArabic ? 'يتم تفريغ البضائع' : 'Unloading goods',
        status: 'unloading',
      ),
      TaskStep(
        title: isArabic ? 'مكتملة' : 'Completed',
        content:
            isArabic ? 'تم إكمال المهمة بنجاح' : 'Task completed successfully',
        status: 'completed',
      ),
    ];
  }

  int _getCurrentStepIndex(List<TaskStep> steps) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].status == task.status) {
        return i;
      }
    }
    return 0; // Default to first step if status not found
  }
}

class TaskStep {
  final String title;
  final String? content;
  final String status;

  TaskStep({
    required this.title,
    this.content,
    required this.status,
  });
}
