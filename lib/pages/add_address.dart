import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/services/auth_service.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key, this.address});

  final Map<String, dynamic>? address;

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _deliveryAreaController = TextEditingController();
  final TextEditingController _completeAddressController =
      TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _deliveryInstructionsController =
      TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  String _selectedNickname = 'Home';

  bool get _isEditMode => widget.address != null;

  final List<String> _nicknameOptions = const ['Home', 'Office', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _hydrateForm(widget.address!);
    }
  }

  void _hydrateForm(Map<String, dynamic> address) {
    _deliveryAreaController.text = address['delivery_area'] ?? '';
    _completeAddressController.text = address['complete_address'] ?? '';
    _contactNoController.text = address['contact_no'] ?? '';
    _deliveryInstructionsController.text =
        address['delivery_instructions'] ?? '';
    _latitudeController.text = address['latitude']?.toString() ?? '';
    _longitudeController.text = address['longitude']?.toString() ?? '';

    final String nickname = address['nickname'] ?? 'Home';
    if (_nicknameOptions.contains(nickname) && nickname != 'Other') {
      _selectedNickname = nickname;
    } else {
      _selectedNickname = 'Other';
      _nicknameController.text = nickname;
    }
  }

  @override
  void dispose() {
    _deliveryAreaController.dispose();
    _completeAddressController.dispose();
    _contactNoController.dispose();
    _deliveryInstructionsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    const String url =
        'https://ecommerce.atithyahms.com/api/ecommerce/customer/address/save';

    final String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication token not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final Map<String, dynamic> addressData = {
      'delivery_area': _deliveryAreaController.text.trim(),
      'complete_address': _completeAddressController.text.trim(),
      'contact_no': _contactNoController.text.trim(),
      'delivery_instructions': _deliveryInstructionsController.text.trim(),
      'latitude': _latitudeController.text.trim(),
      'longitude': _longitudeController.text.trim(),
      'nickname': _selectedNickname == 'Other'
          ? _nicknameController.text.trim()
          : _selectedNickname,
    };

    if (_isEditMode && widget.address?['id'] != null) {
      addressData['id'] = widget.address!['id'];
    }

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(addressData),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final bool isSuccess =
            data['status'] == true ||
            data['success'] == true ||
            response.statusCode == 201;

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Address updated successfully!'
                    : 'Address added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to save address'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Address' : 'Add Address'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(colorScheme, 'Delivery Area'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _deliveryAreaController,
                hintText: 'e.g., Butwal',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter delivery area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel(colorScheme, 'Complete Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _completeAddressController,
                hintText: 'e.g., Devdaha-10, Charange',
                icon: Icons.home,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter complete address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel(colorScheme, 'Contact Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _contactNoController,
                hintText: 'e.g., 9816491822',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel(colorScheme, 'Delivery Instructions (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _deliveryInstructionsController,
                hintText: 'e.g., Ring the doorbell twice',
                icon: Icons.note,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(colorScheme, 'Latitude'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _latitudeController,
                          hintText: '28.2323232',
                          icon: Icons.place,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(colorScheme, 'Longitude'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _longitudeController,
                          hintText: '82.123434',
                          icon: Icons.place,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel(colorScheme, 'Address Nickname'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedNickname,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.label, color: colorScheme.primary),
                    ),
                  ),
                  items: _nicknameOptions
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue == null) {
                      return;
                    }
                    setState(() {
                      _selectedNickname = newValue;
                      if (_selectedNickname != 'Other') {
                        _nicknameController.clear();
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedNickname == 'Other')
                _buildTextField(
                  controller: _nicknameController,
                  hintText: 'Enter custom nickname',
                  icon: Icons.edit,
                  validator: (value) {
                    if (_selectedNickname == 'Other' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter a nickname';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Update Address' : 'Save Address',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(ColorScheme colorScheme, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
