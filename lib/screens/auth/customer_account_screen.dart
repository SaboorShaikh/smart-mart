import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';

class CustomerAccountScreen extends StatefulWidget {
  final Map<String, dynamic>? locationData;
  const CustomerAccountScreen({super.key, this.locationData});

  @override
  State<CustomerAccountScreen> createState() => _CustomerAccountScreenState();
}

class _CustomerAccountScreenState extends State<CustomerAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  int _passwordStrength = 0;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _updateEmailError(showIfEmpty: false);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _name.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!valid) return;
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    final data = {
      ...?widget.locationData,
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
    };
    Get.toNamed('/auth/register/customer/phone', arguments: data);
  }

  bool get _canSubmit {
    final nameOk = _name.text.trim().isNotEmpty;
    final emailOk = _isValidEmail(_email.text);
    final passOk = _password.text.length >= 6;
    final matchOk = _password.text == _confirmPassword.text &&
        _confirmPassword.text.isNotEmpty;
    return nameOk && emailOk && passOk && matchOk;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecoration = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6DEE6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6DEE6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF4B5563),
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w500,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Account Details',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create your login credentials',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Theme(
                    data: theme.copyWith(inputDecorationTheme: inputDecoration),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLabel(theme, 'Full Name', required: true),
                          TextFormField(
                            controller: _name,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Abdul Saboor',
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel(theme, 'Email Address', required: true),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'saboor@example.com',
                              errorText: _emailError,
                            ),
                            onChanged: (_) => setState(() {
                              _updateEmailError(showIfEmpty: false);
                            }),
                            validator: (v) => (v == null || !_isValidEmail(v))
                                ? 'Enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel(theme, 'Password', required: true),
                          _buildPasswordField(
                            controller: _password,
                            hint: 'Create a password',
                            obscure: !_showPassword,
                            onToggle: () =>
                                setState(() => _showPassword = !_showPassword),
                            onChanged: (v) => setState(() {
                              _passwordStrength = _calculateStrength(v);
                            }),
                          ),
                          const SizedBox(height: 12),
                          _buildStrengthMeter(theme, _passwordStrength),
                          const SizedBox(height: 16),
                          _buildLabel(theme, 'Retype Password', required: true),
                          _buildPasswordField(
                            controller: _confirmPassword,
                            hint: 'Confirm your password',
                            obscure: !_showConfirmPassword,
                            onToggle: () => setState(() =>
                                _showConfirmPassword = !_showConfirmPassword),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: CustomButton(
          text: 'Continue',
          onPressed: _submit,
          width: double.infinity,
          borderRadius: 16,
          isDisabled: !_canSubmit,
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFF2563EB)),
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          color: const Color(0xFF6B7280),
        ),
      ),
      onChanged: onChanged,
      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
    );
  }

  Widget _buildStrengthMeter(ThemeData theme, int level) {
    final hasInput = _password.text.isNotEmpty;
    final color = _strengthColor(level, theme);
    final label = _strengthLabel(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _strengthBar(
              color: hasInput && level >= 1 ? color : const Color(0xFFE5E7EB),
            ),
            const SizedBox(width: 6),
            _strengthBar(
              color: hasInput && level >= 2 ? color : const Color(0xFFE5E7EB),
            ),
            const SizedBox(width: 6),
            _strengthBar(
              color: hasInput && level >= 3 ? color : const Color(0xFFE5E7EB),
            ),
            const SizedBox(width: 6),
            _strengthBar(
              color: hasInput && level >= 4 ? color : const Color(0xFFE5E7EB),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (hasInput)
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _strengthBar({required Color color}) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  int _calculateStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++; // extra credit for length
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasNumber = value.contains(RegExp(r'\d'));
    final hasSpecial = value.contains(RegExp(r'[^A-Za-z0-9]'));

    if (hasLower && hasUpper) score++;
    if (hasNumber) score++;
    if (hasSpecial) score++;

    // Cap at 4
    return score.clamp(0, 4);
  }

  Color _strengthColor(int level, ThemeData theme) {
    switch (level) {
      case 0:
      case 1:
        return const Color(0xFFF87171); // red-400
      case 2:
        return const Color(0xFFF59E0B); // amber-500
      case 3:
        return const Color(0xFF22C55E); // green-500
      case 4:
      default:
        return theme.colorScheme.primary; // blue
    }
  }

  String _strengthLabel(int level) {
    switch (level) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      case 4:
      default:
        return 'Very Strong';
    }
  }

  bool _isValidEmail(String value) {
    const pattern =
        r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*$";
    return RegExp(pattern).hasMatch(value.trim());
  }

  void _updateEmailError({required bool showIfEmpty}) {
    final text = _email.text.trim();
    if (text.isEmpty && !showIfEmpty) {
      _emailError = null;
      return;
    }
    _emailError = _isValidEmail(text) ? null : 'Enter a valid email';
  }
}
