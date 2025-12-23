import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/task_ad.dart';
import '../../models/task_offer.dart';
import '../../services/task_ads_service.dart';
import 'package:get/get.dart';

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
                  _isEditing ? 'offer_updated_successfully'.tr : 'offer_submitted_successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
               content: Text(response.message ?? 'failed_to_submit_offer'.tr),
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
             content: Text('error_occurred'.tr + ': $e'),
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
        title: Text(_isEditing ? 'edit_offer'.tr : 'submit_offer'.tr),
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
               'ad_summary'.tr,
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
                   'ad_number'.tr + '${widget.taskAd.id}',
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
                   widget.taskAd.lowestPrice == 0 && widget.taskAd.highestPrice == 0
                      ? 'price_range'.tr + ': ' + 'open_price'.tr
                      : 'price_range'.tr + ': ${widget.taskAd.lowestPrice.toStringAsFixed(2)} - ${widget.taskAd.highestPrice.toStringAsFixed(2)} ' + 'sar'.tr,
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
           'proposed_price'.tr + ' *',
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
             hintText: 'enter_proposed_price'.tr,
             suffixText: 'sar'.tr,
            prefixIcon: const Icon(Icons.monetization_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
               return 'please_enter_price'.tr;
            }

            final price = double.tryParse(value);
            if (price == null) {
               return 'enter_valid_price'.tr;
            }

            if (price <= 0) {
               return 'price_must_be_greater_than_zero'.tr;
            }

            // Skip range check if both are 0
            if (widget.taskAd.lowestPrice == 0 && widget.taskAd.highestPrice == 0) {
              return null;
            }

            if (price < widget.taskAd.lowestPrice) {
               return 'price_below_minimum'.tr + ' (${widget.taskAd.lowestPrice.toStringAsFixed(2)} ' + 'sar'.tr + ')';
            }

            if (price > widget.taskAd.highestPrice) {
               return 'price_above_maximum'.tr + ' (${widget.taskAd.highestPrice.toStringAsFixed(2)} ' + 'sar'.tr + ')';
            }

            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          widget.taskAd.lowestPrice == 0 && widget.taskAd.highestPrice == 0
              ? 'open_price_range'.tr
              : 'allowed_range'.tr + ': ${widget.taskAd.lowestPrice.toStringAsFixed(2)} - ${widget.taskAd.highestPrice.toStringAsFixed(2)} ' + 'sar'.tr,
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
      color: Colors.blue.withOpacity(0.05),
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
                   'net_earnings_calculation'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalculationRow(
                 'offer_price'.tr, '${price.toStringAsFixed(2)} ' + 'sar'.tr),
            _buildCalculationRow(
               'taxes_and_fees'.tr,
              '- ${((commission.serviceCommissionType == 'fixed' ? commission.serviceCommission : (price * commission.serviceCommission / 100)) + (price * commission.vatCommission / 100)).toStringAsFixed(2)} ' + 'sar'.tr,
            ),
            const Divider(),
            _buildCalculationRow(
               'net_earnings'.tr,
               '${_calculatedNet!.toStringAsFixed(2)} ' + 'sar'.tr,
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
           'offer_description'.tr + ' *',
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
             hintText: 'add_offer_description'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'please_enter_description'.tr;
            }
            return null;
          },
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
                 _isEditing ? 'update_offer'.tr : 'submit_offer'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
