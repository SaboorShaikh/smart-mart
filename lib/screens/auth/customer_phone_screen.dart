import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class CustomerPhoneScreen extends StatefulWidget {
  final Map<String, dynamic>? previousData;
  const CustomerPhoneScreen({super.key, this.previousData});

  @override
  State<CustomerPhoneScreen> createState() => _CustomerPhoneScreenState();
}

class _CustomerPhoneScreenState extends State<CustomerPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _countryCodes = const ['+92', '+91', '+880', '+1', '+44'];
  String _code = '+92';
  final TextEditingController _phone = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('Phone Number'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      initialValue: _code,
                      items: _countryCodes
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _code = v ?? _code),
                      decoration: const InputDecoration(labelText: 'Code'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Phone number'),
                      validator: (v) => (v == null || v.trim().length < 7)
                          ? 'Enter valid number'
                          : null,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Finish',
                isLoading: _isSaving,
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || _isSaving) return;
                  setState(() => _isSaving = true);

                  final previous = widget.previousData ?? {};
                  final fullAddress = [
                    previous['address1'] ?? '',
                    previous['address2'] ?? ''
                  ].where((e) => (e as String).trim().isNotEmpty).join(', ');

                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  final result = await auth.register(
                    RegisterData(
                      email: (previous['email'] ?? '') as String,
                      password: (previous['password'] ?? '') as String,
                      role: UserRole.customer,
                      name: (previous['name'] ?? '') as String,
                      phone: '$_code${_phone.text.trim()}',
                      address: fullAddress.isNotEmpty
                          ? '${previous['city'] ?? ''}, ${previous['country'] ?? ''} - $fullAddress'
                          : '${previous['city'] ?? ''}, ${previous['country'] ?? ''}',
                      city: previous['city'] as String?,
                      state: previous['state'] as String?,
                      country: previous['country'] as String?,
                      postalCode: previous['postalCode'] as String?,
                    ),
                  );

                  setState(() => _isSaving = false);

                  if (!mounted) return;
                  if (result.success) {
                    // Go straight to customer home after successful signup
                    Get.offAllNamed('/customer');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(result.error ?? 'Registration failed')),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
