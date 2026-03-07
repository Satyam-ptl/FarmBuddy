import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import 'app_shell.dart';

class RegisterFarmerScreen extends StatefulWidget {
  const RegisterFarmerScreen({super.key});

  @override
  State<RegisterFarmerScreen> createState() => _RegisterFarmerScreenState();
}

class _RegisterFarmerScreenState extends State<RegisterFarmerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _firstNameCtl = TextEditingController();
  final _lastNameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _cityCtl = TextEditingController();
  final _stateCtl = TextEditingController();
  final _postalCodeCtl = TextEditingController();
  final _landAreaCtl = TextEditingController(text: '1');

  String _language = 'English';
  String _soil = 'Loamy';
  String _experience = 'Beginner';

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // ── Validators ────────────────────────────────────────
  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
  static final _phoneRegex = RegExp(r'^\d{10}$');

  String? _requiredValidator(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _usernameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username is required';
    if (v.trim().length < 3) return 'At least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) return 'Letters, digits, underscore only';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Include an uppercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Include a digit';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    if (!_phoneRegex.hasMatch(v.trim())) return 'Enter 10-digit number';
    return null;
  }

  String? _postalCodeValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Postal code is required';
    if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) return 'Enter 6-digit PIN';
    return null;
  }

  String? _landAreaValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Land area is required';
    final n = double.tryParse(v.trim());
    if (n == null || n <= 0) return 'Must be > 0';
    return null;
  }

  // ── Submit ────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.registerFarmer({
        'username': _usernameCtl.text.trim(),
        'password': _passwordCtl.text,
        'first_name': _firstNameCtl.text.trim(),
        'last_name': _lastNameCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'phone_number': _phoneCtl.text.trim(),
        'address': _addressCtl.text.trim(),
        'city': _cityCtl.text.trim(),
        'state': _stateCtl.text.trim(),
        'postal_code': int.parse(_postalCodeCtl.text.trim()),
        'preferred_language': _language,
        'land_area_hectares': double.parse(_landAreaCtl.text.trim()),
        'soil_type': _soil,
        'experience_level': _experience,
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('username') && lower.contains('exists')) {
      return 'Username already taken. Try a different one.';
    }
    if (lower.contains('email') && lower.contains('exists')) {
      return 'Email already registered.';
    }
    if (lower.contains('connection') || lower.contains('socketexception')) {
      return 'Cannot reach server. Check your internet connection.';
    }
    return 'Registration failed. Please check your details and try again.';
  }

  // ── UI ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // Error banner
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Account section
            _sectionHeader('Account'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameCtl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
              validator: _usernameValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                helperText: 'Min 8 chars, 1 uppercase, 1 digit',
                helperMaxLines: 2,
              ),
              validator: _passwordValidator,
            ),

            const SizedBox(height: 20),
            _sectionHeader('Personal Info'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (v) => _requiredValidator(v, 'First name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (v) => _requiredValidator(v, 'Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              decoration: const InputDecoration(labelText: 'Phone (10 digits)', prefixIcon: Icon(Icons.phone_outlined)),
              validator: _phoneValidator,
            ),

            const SizedBox(height: 20),
            _sectionHeader('Location'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressCtl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home_outlined)),
              validator: (v) => _requiredValidator(v, 'Address'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (v) => _requiredValidator(v, 'City'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateCtl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'State'),
                    validator: (v) => _requiredValidator(v, 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _postalCodeCtl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: const InputDecoration(labelText: 'Postal code (6 digits)', prefixIcon: Icon(Icons.pin_drop_outlined)),
              validator: _postalCodeValidator,
            ),

            const SizedBox(height: 20),
            _sectionHeader('Farm Details'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _landAreaCtl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Land area (hectares)', prefixIcon: Icon(Icons.landscape_outlined)),
              validator: _landAreaValidator,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: 'Preferred language', prefixIcon: Icon(Icons.language)),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                DropdownMenuItem(value: 'Marathi', child: Text('Marathi')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'English'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _soil,
              decoration: const InputDecoration(labelText: 'Soil type', prefixIcon: Icon(Icons.terrain)),
              items: const [
                DropdownMenuItem(value: 'Loamy', child: Text('Loamy')),
                DropdownMenuItem(value: 'Clay', child: Text('Clay')),
                DropdownMenuItem(value: 'Sandy', child: Text('Sandy')),
                DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
              ],
              onChanged: (v) => setState(() => _soil = v ?? 'Loamy'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _experience,
              decoration: const InputDecoration(labelText: 'Experience level', prefixIcon: Icon(Icons.star_outline)),
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'Expert', child: Text('Expert')),
              ],
              onChanged: (v) => setState(() => _experience = v ?? 'Beginner'),
            ),

            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2ECC71)),
    );
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    _firstNameCtl.dispose();
    _lastNameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _addressCtl.dispose();
    _cityCtl.dispose();
    _stateCtl.dispose();
    _postalCodeCtl.dispose();
    _landAreaCtl.dispose();
    super.dispose();
  }
}
