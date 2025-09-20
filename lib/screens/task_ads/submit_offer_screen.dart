import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/task_ad.dart';
import '../../models/task_offer.dart';
import '../../services/task_ads_service.dart';

class SubmitOfferScreen extends StatefulWidget {
  final TaskAd taskAd;
  final TaskOffer? existingOffer;

  const SubmitOfferScreen({
    super.key,
    required this.taskAd,
    this.existingOffer,
  });

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskAdsService _taskAdsService = TaskAdsService();

  bool _isLoading = false;
  double? _calculatedNet;

  bool get _isEditing => widget.existingOffer != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _priceController.text = widget.existingOffer!.price.toStringAsFixed(2);
      _descriptionController.text = widget.existingOffer!.description;
      _calculateNetEarnings();
    }

    _priceController.addListener(_calculateNetEarnings);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateNetEarnings() {
    final priceText = _priceController.text;
    if (priceText.isNotEmpty && widget.taskAd.commission != null) {
      final price = double.tryParse(priceText);
      if (price != null) {
        setState(() {
          _calculatedNet = widget.taskAd.commission!.calculateDriverNet(price);
        });
        return;
      }
    }

    setState(() {
      _calculatedNet = null;
    });
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text);
    final description = _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = _isEditing
          ? await _taskAdsService.updateOffer(
              offerId: widget.existingOffer!.id,
              price: price,
              description: description,
            )
          : await _taskAdsService.submitOffer(
              adId: widget.taskAd.id,
              price: price,
              description: description,
            );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _isEditing ? 'تم تحديث العرض بنجاح' : 'تم تقديم العرض بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'فشل في تقديم العرض'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل العرض' : 'تقديم عرض'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ad summary
              _buildAdSummaryCard(),

              const SizedBox(height: 24),

              // Price input
              _buildPriceInput(),

              const SizedBox(height: 16),

              // Net earnings calculation
              if (_calculatedNet != null) _buildNetEarningsCard(),

              const SizedBox(height: 16),

              // Description input
              _buildDescriptionInput(),

              const SizedBox(height: 32),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الإعلان',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.campaign, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'إعلان #${widget.taskAd.id}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'النطاق السعري: ${widget.taskAd.lowestPrice.toStringAsFixed(2)} - ${widget.taskAd.highestPrice.toStringAsFixed(2)} ر.س',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (widget.taskAd.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.taskAd.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السعر المقترح *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: 'أدخل السعر المقترح',
            suffixText: 'ر.س',
            prefixIcon: const Icon(Icons.monetization_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال السعر المقترح';
            }

            final price = double.tryParse(value);
            if (price == null) {
              return 'يرجى إدخال سعر صحيح';
            }

            if (price <= 0) {
              return 'يجب أن يكون السعر أكبر من صفر';
            }

            if (price < widget.taskAd.lowestPrice) {
              return 'السعر أقل من الحد الأدنى (${widget.taskAd.lowestPrice.toStringAsFixed(2)} ر.س)';
            }

            if (price > widget.taskAd.highestPrice) {
              return 'السعر أعلى من الحد الأقصى (${widget.taskAd.highestPrice.toStringAsFixed(2)} ر.س)';
            }

            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'النطاق المسموح: ${widget.taskAd.lowestPrice.toStringAsFixed(2)} - ${widget.taskAd.highestPrice.toStringAsFixed(2)} ر.س',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildNetEarningsCard() {
    final commission = widget.taskAd.commission!;
    final price = double.parse(_priceController.text);

    return Card(
      color: Colors.blue.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'حساب صافي المستحقات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalculationRow(
                'سعر العرض', '${price.toStringAsFixed(2)} ر.س'),
            _buildCalculationRow(
              'عمولة الخدمة',
              commission.serviceCommissionType == 'fixed'
                  ? '- ${commission.serviceCommission.toStringAsFixed(2)} ر.س'
                  : '- ${(price * commission.serviceCommission / 100).toStringAsFixed(2)} ر.س',
            ),
            _buildCalculationRow(
              'ضريبة القيمة المضافة',
              '- ${(price * commission.vatCommission / 100).toStringAsFixed(2)} ر.س',
            ),
            const Divider(),
            _buildCalculationRow(
              'صافي المستحقات',
              '${_calculatedNet!.toStringAsFixed(2)} ر.س',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.green[700] : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف العرض (اختياري)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'أضف وصفاً لعرضك (اختياري)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitOffer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditing ? 'تحديث العرض' : 'تقديم العرض',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
