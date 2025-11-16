import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deliveryAreaController = TextEditingController();
  final TextEditingController _completeAddressController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _deliveryInstructionsController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _showForm = false; // Toggle between form and address list
  String _selectedNickname = 'Home';
  final List<String> _nicknameOptions = ['Home', 'Office', 'Other'];
  final List<Map<String, dynamic>> _savedAddresses = []; // Store saved addresses

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

    const String url = 'https://ecommerce.atithyahms.com/api/ecommerce/customer/address/save';

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

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNzdiNWRhNjY2NmEyMGFiNTYyZDdkZTA4MDVhYzFlYjc0ZWM5MThjYjA3ZGJiYWEzMjQwMzUwY2U4MzAyNTZiZjA1ODVlMGRhMWIyZmNkNjkiLCJpYXQiOjE3NjMyNzQ3NzgsIm5iZiI6MTc2MzI3NDc3OCwiZXhwIjoxNzk0ODEwNzc4LCJzdWIiOiI1MDciLCJzY29wZXMiOltdfQ.mNLd3nAxIKdipWnBChIln91Fu5xB9BX0ZpdwbjLRUbieos_UZfllq9oFVlI64eVygsKi4pQO_A4otTnvlpnOHzvfOIjNYFw0ZfesEIFViH9sGWr_coAH1FYJpLiWbyQ0hM8SHbfnJi3fMbCo1X7vdcsUlmJeDf1jeTx4_7O7jXeIULADBknhwN24WmhkhLROXCbGs-FIn3o2LWlDLNzGQUkzJWgzFyyj2wdiCge4pnn1TbPYFQ9cedZQ7jBCuu1BrLCKP94pSe-g_bCj1Nno1q3vPUwVpkAsRYkXw2wZV7olbmDUQhTZYqLELcFDPxJaeymLO1OwHI-wtCAmKmRM7zTs8ZvxqgvWN_MN14gBWzadUIsnZoE4r-WBnd62CrtDHcEo317viNTHJz6AvJml9ByapfKo0xuJdgdgywsZy4T_FXENP3DQnHyO4RawYU3BhjI_pr5Fq1FHDayWzs3c8NzpRwykQvykJ2fzEzdQrPj3Xl1fovB_Pu7puolZneLcmJzoxwsfBMJQDmgizFzcjQEq67nYskegwc3HhOpZMxk1QgezJXycRWA4pCjzLRyUGSDoaLZcA-dgrkNWsUlPn3wGxkgla61VMiPJAYbCjCyia7mTiJG5qEkQwBN-Ovb-_G7xfOEjvHzIy5m_A1w7bL5cQ3WVOQRvCTPEA__6UIw',
        },
        body: jsonEncode(addressData),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final isSuccess = data['status'] == true || 
                         data['success'] == true || 
                         response.statusCode == 201;

        if (isSuccess) {
          // Add to saved addresses list
          setState(() {
            _savedAddresses.add({
              'delivery_area': _deliveryAreaController.text.trim(),
              'complete_address': _completeAddressController.text.trim(),
              'contact_no': _contactNoController.text.trim(),
              'delivery_instructions': _deliveryInstructionsController.text.trim(),
              'latitude': _latitudeController.text.trim(),
              'longitude': _longitudeController.text.trim(),
              'nickname': _selectedNickname == 'Other' 
                  ? _nicknameController.text.trim() 
                  : _selectedNickname,
            });
            _showForm = false; // Hide form after saving
          });
          
          // Clear form fields
          _deliveryAreaController.clear();
          _completeAddressController.clear();
          _contactNoController.clear();
          _deliveryInstructionsController.clear();
          _latitudeController.clear();
          _longitudeController.clear();
          _nicknameController.clear();
          _selectedNickname = 'Home';
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to add address'),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () {
              setState(() {
                _showForm = !_showForm;
              });
            },
            tooltip: _showForm ? 'Cancel' : 'Add Address',
          ),
        ],
      ),
      body: _showForm
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Delivery Area
                Text(
                  'Delivery Area',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deliveryAreaController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Butwal',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.location_city, color: colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter delivery area';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Complete Address
                Text(
                  'Complete Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _completeAddressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g., Devdaha-10, Charange',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.home, color: colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter complete address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Contact Number
                Text(
                  'Contact Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactNoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'e.g., 9816491822',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.phone, color: colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
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

                // Delivery Instructions
                Text(
                  'Delivery Instructions (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deliveryInstructionsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g., Ring the doorbell twice',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.note, color: colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Location Coordinates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _latitudeController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '28.2323232',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(Icons.place, color: colorScheme.primary),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          Text(
                            'Longitude',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _longitudeController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '82.123434',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(Icons.place, color: colorScheme.primary),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

                // Address Nickname
                Text(
                  'Address Nickname',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _selectedNickname,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.label, color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: _nicknameOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedNickname = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Custom Nickname Field (shown only when "Other" is selected)
                if (_selectedNickname == 'Other')
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      hintText: 'Enter custom nickname',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.edit, color: colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (_selectedNickname == 'Other' && 
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter a nickname';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 30),

                // Submit Button
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
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          : _savedAddresses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 80,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No addresses added yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a new delivery address',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedAddresses.length,
                  itemBuilder: (context, index) {
                    final address = _savedAddresses[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        address['nickname'] == 'Home'
                                            ? Icons.home
                                            : address['nickname'] == 'Office'
                                                ? Icons.work
                                                : Icons.location_on,
                                        size: 16,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        address['nickname'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      _savedAddresses.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Address deleted'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address['delivery_area'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address['complete_address'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  address['contact_no'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            if (address['delivery_instructions'].isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.note_outlined,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      address['delivery_instructions'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
