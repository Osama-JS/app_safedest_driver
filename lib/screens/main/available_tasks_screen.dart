import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/TaskController.dart';
import '../../models/task_claim.dart';
import 'available_task_detail_screen.dart';

class AvailableTasksScreen extends StatefulWidget {
  const AvailableTasksScreen({super.key});

  @override
  State<AvailableTasksScreen> createState() => _AvailableTasksScreenState();
}

class _AvailableTasksScreenState extends State<AvailableTasksScreen> with SingleTickerProviderStateMixin {
  final TaskController _taskController = Get.find<TaskController>();
  late TabController _tabController;

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Expanded(child: Text('availableTasksInstructionTitle'.tr)),
          ],
        ),
        content: Text(
          'availableTasksInstructionBody'.tr,
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _taskController.fetchBroadcastTasks(),
      _taskController.fetchMyClaims(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('broadcastTasks'.tr),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline),
            tooltip: 'help'.tr,
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'availableTasks'.tr),
            Tab(text: 'claimRequests'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableTasksList(),
          _buildMyClaimsList(),
        ],
      ),
    );
  }

  Widget _buildAvailableTasksList() {
    return RefreshIndicator(
      onRefresh: () => _taskController.fetchBroadcastTasks(refresh: true),
      child: Obx(() {
        if (_taskController.isBroadcastLoading.value && _taskController.broadcastTasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_taskController.broadcastTasks.isEmpty) {
          return _buildEmptyState('noAvailableBroadcastTasks'.tr);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _taskController.broadcastTasks.length,
          itemBuilder: (context, index) {
            final task = _taskController.broadcastTasks[index];
            return _buildTaskCard(task);
          },
        );
      }),
    );
  }

  Widget _buildMyClaimsList() {
    return RefreshIndicator(
      onRefresh: () => _taskController.fetchMyClaims(refresh: true),
      child: Obx(() {
        if (_taskController.isClaimsLoading.value && _taskController.myClaims.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_taskController.myClaims.isEmpty) {
          return _buildEmptyState('noTransactions'.tr);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _taskController.myClaims.length,
          itemBuilder: (context, index) {
            final claim = _taskController.myClaims[index];
            return _buildClaimCard(claim);
          },
        );
      }),
    );
  }

  Widget _buildTaskCard(AvailableTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => AvailableTaskDetailScreen(task: task)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: #${task.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (task.vehicleSize != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping, size: 14, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                task.vehicleSize!,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${task.totalPrice.toStringAsFixed(2)} SAR',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Directional Graphic: Pickup <--- Truck --- Delivery
              Row(
                children: [
                  _buildDirectionNode('pickup'.tr, task.pickupAddress ?? '', isPickup: true),
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade300, Colors.red.shade300],
                                ),
                              ),
                            ),
                            Transform.rotate(
                              angle: Get.locale?.languageCode == 'ar' ? 3.14159 : 0, // Mirror for RTL
                              child: Transform.scale(
                                scaleX: -1, // Face the truck towards the pickup (left in LTR)
                                child: Icon(
                                  Icons.local_shipping,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (task.distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${task.distance!.toStringAsFixed(1)} KM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildDirectionNode('delivery'.tr, task.deliveryAddress ?? '', isPickup: false),
                ],
              ),

              const SizedBox(height: 20),

              // Bottom row: Distance detail and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.distance != null)
                    Row(
                      children: [
                        Icon(Icons.directions_run, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 6),
                        Text(
                          '${'awayFromPickup'.tr}: ${task.distance!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                  if (task.claimStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getClaimStatusColor(task.claimStatus!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getClaimStatusColor(task.claimStatus!), width: 1.5),
                      ),
                      child: Text(
                        task.claimStatus!.tr,
                        style: TextStyle(
                          color: _getClaimStatusColor(task.claimStatus!),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
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

  Widget _buildDirectionNode(String label, String address, {required bool isPickup}) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(
            isPickup ? Icons.radio_button_checked : Icons.location_on,
            color: isPickup ? Colors.blue : Colors.red,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(TaskClaim claim) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    claim.customerTaskNumber ?? '#${claim.taskId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildStatusBadge(claim.status ?? 'pending'),
              ],
            ),

            const SizedBox(height: 20),

            // Directional Graphic (Same as task card but for status tracking)
            Row(
              children: [
                _buildDirectionNode('pickup'.tr, claim.pickupAddress ?? '', isPickup: true),
                Expanded(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.red.shade300,
                                ],
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: Get.locale?.languageCode == 'ar' ? 3.14159 : 0,
                            child: Transform.scale(
                              scaleX: -1,
                              child: Icon(
                                Icons.local_shipping,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'delivery'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDirectionNode('delivery'.tr, claim.deliveryAddress ?? '', isPickup: false),
              ],
            ),

            if (claim.adminNote != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Note:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            claim.adminNote!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String address) {
    return Row(
      children: [
        Icon(icon, size: 16, color: icon == Icons.my_location ? Colors.blue : Colors.red),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getClaimStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Color _getClaimStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }
}
