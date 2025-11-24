// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../core/services/auth_service.dart';

// class AddAddressPage extends StatefulWidget {
//   const AddAddressPage({super.key});

//   @override
//   State<AddAddressPage> createState() => _AddAddressPageState();
// }

// class _AddAddressPageState extends State<AddAddressPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _deliveryAreaController = TextEditingController();
//   final TextEditingController _completeAddressController = TextEditingController();
//   final TextEditingController _contactNoController = TextEditingController();
//   final TextEditingController _deliveryInstructionsController = TextEditingController();
//   final TextEditingController _latitudeController = TextEditingController();
//   final TextEditingController _longitudeController = TextEditingController();
//   final TextEditingController _nicknameController = TextEditingController();

//   bool _isLoading = false;
//   bool _showForm = false; // Toggle between form and address list
//   bool _isLoadingAddresses = true;
//   bool _isEditMode = false;
//   int? _editingIndex;
//   String _selectedNickname = 'Home';
//   final List<String> _nicknameOptions = ['Home', 'Office', 'Other'];
//   List<Map<String, dynamic>> _savedAddresses = []; // Store saved addresses

//   @override
//   void initState() {
//     super.initState();
//     _fetchAddresses();
//   }

//   Future<void> _fetchAddresses() async {
//     setState(() => _isLoadingAddresses = true);

//     const String url = 'https://ecommerce.atithyahms.com/api/ecommerce/customer/address/';
    
//     // Get token from AuthService
//     final token = await AuthService.getToken();
    
//     export 'package:demo_app/pages/add_address.dart';
//     print('🔍 Fetching addresses - Token: ${token != null && token.isNotEmpty ? "Found (${token.substring(0, 10)}...)" : "NOT FOUND"}');
