import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskStatusStepper extends StatelessWidget {
  final Task task;

  const TaskStatusStepper({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    final currentStepIndex = _getCurrentStepIndex();

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
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'مراحل المهمة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHorizontalStepper(steps, currentStepIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalStepper(List<TaskStep> steps, int currentStepIndex) {
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
              _buildStepItem(step, isActive, isCurrent, isCompleted),
              if (index < steps.length - 1)
                _buildConnector(index < currentStepIndex),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepItem(
      TaskStep step, bool isActive, bool isCurrent, bool isCompleted) {
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
      backgroundColor = Colors.blue;
      iconColor = Colors.white;
      textColor = Colors.blue;
      icon = _getStepIcon(step.status);
    } else {
      backgroundColor = Colors.grey[300]!;
      iconColor = Colors.grey[600]!;
      textColor = Colors.grey[600]!;
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

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.grey[300],
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

  List<TaskStep> _getSteps() {
    return [
      TaskStep(
        title: 'مخصصة',
        content: 'تم تخصيص المهمة للسائق',
        status: 'assign',
      ),
      TaskStep(
        title: 'بدأت',
        content: 'بدأ السائق في تنفيذ المهمة',
        status: 'started',
      ),
      TaskStep(
        title: 'في نقطة الاستلام',
        content: 'وصل السائق لنقطة الاستلام',
        status: 'in pickup point',
      ),
      TaskStep(
        title: 'جاري التحميل',
        content: 'يتم تحميل البضائع',
        status: 'loading',
      ),
      TaskStep(
        title: 'في الطريق',
        content: 'السائق في طريقه لنقطة التسليم',
        status: 'in the way',
      ),
      TaskStep(
        title: 'في نقطة التسليم',
        content: 'وصل السائق لنقطة التسليم',
        status: 'in delivery point',
      ),
      TaskStep(
        title: 'جاري التفريغ',
        content: 'يتم تفريغ البضائع',
        status: 'unloading',
      ),
      TaskStep(
        title: 'مكتملة',
        content: 'تم إكمال المهمة بنجاح',
        status: 'completed',
      ),
    ];
  }

  int _getCurrentStepIndex() {
    final steps = _getSteps();
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
