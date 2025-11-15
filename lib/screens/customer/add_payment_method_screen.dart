import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_icon.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _setAsDefault = true;
  _SavedCardDetails? _savedCard;

  bool get _hasCardDetails {
    return _cardholderController.text.trim().isNotEmpty ||
        _cardNumberController.text.trim().isNotEmpty ||
        _expiryController.text.trim().isNotEmpty ||
        _cvvController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose how you want to pay',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildCardForm(theme),
            const SizedBox(height: 12),
            const SizedBox(height: 20),
            _buildSavedCardSection(theme),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: CustomButton(
                text: 'Save Payment Method',
                onPressed: _handleSave,
                borderRadius: 22,
                height: 52,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm(ThemeData theme) {
    return CustomCard(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIcon(
                    assetPath: AppIcons.creditCard,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit / Debit Card (optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add a card or pick another option below',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              label: 'Cardholder name',
              hint: 'Enter name on card',
              controller: _cardholderController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              label: 'Card number',
              hint: '0000 0000 0000 0000',
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  (value == null || value.trim().length < 12)
                      ? 'Enter a valid card number'
                      : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledField(
                    label: 'Expiry date',
                    hint: 'MM/YY',
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLabeledField(
                    label: 'CVV',
                    hint: '123',
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.trim().length < 3)
                            ? 'Invalid'
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set as default payment method',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can change this anytime',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _setAsDefault,
                  onChanged: (value) {
                    setState(() {
                      _setAsDefault = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    final hasCardDetails = _hasCardDetails;
    if (hasCardDetails) {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) {
        return;
      }
    }

    setState(() {
      _savedCard = hasCardDetails
          ? _SavedCardDetails(
              cardholderName: _cardholderController.text.trim(),
              maskedNumber: _maskCardNumber(_cardNumberController.text),
              expiry: _expiryController.text.trim(),
            )
          : null;
    });

    Get.snackbar(
      'Payment method saved',
      hasCardDetails
          ? 'Your ${_setAsDefault ? 'default ' : ''}card is ready to use.'
          : 'Your preferences have been saved.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Widget _buildSavedCardSection(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _savedCard != null
          ? CustomCard(
              key: const ValueKey('saved-card'),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Card',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _savedCard!.cardholderName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.credit_card,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _savedCard!.maskedNumber,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expiry',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _savedCard!.expiry,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Default',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _setAsDefault ? 'Yes' : 'No',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : CustomCard(
              key: const ValueKey('no-card'),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Card',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No card added yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Save your card details once to checkout faster and keep them secure for next time.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Your information stays encrypted and private.',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _maskCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return '**** **** **** $digits';
    final last4 = digits.substring(digits.length - 4);
    return '**** **** **** $last4';
  }
}

class _SavedCardDetails {
  final String cardholderName;
  final String maskedNumber;
  final String expiry;

  _SavedCardDetails({
    required this.cardholderName,
    required this.maskedNumber,
    required this.expiry,
  });
}

