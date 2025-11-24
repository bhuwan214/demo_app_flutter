import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/services/auth_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  Map<String, dynamic>? _trackingData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
  }

  Future<void> _fetchTrackingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final String url = 'https://ecommerce.atithyahms.com/api/ecommerce/customer/orders/track';
    
    final token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Authentication token not found';
      });
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'order_id': widget.orderId,
        }),
      );

      print('🚚 Tracking Response Status: ${response.statusCode}');
      print('🚚 Tracking Response Body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true || data['status'] == true) {
          setState(() {
            _trackingData = data['data'] ?? data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load tracking data';
            _isLoading = false;
          });
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['message'] ?? 'Failed to load tracking data';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading tracking data: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getTrackingSteps(String? currentStatus) {
    final status = currentStatus?.toLowerCase() ?? 'pending';
    
    return [
      {
        'title': 'Order Placed',
        'subtitle': 'Your order has been placed',
        'icon': Icons.shopping_bag,
        'status': 'pending',
        'completed': true,
      },
      {
        'title': 'Order Confirmed',
        'subtitle': 'Your order has been confirmed',
        'icon': Icons.check_circle,
        'status': 'confirmed',
        'completed': ['confirmed', 'processing', 'shipped', 'delivered'].contains(status),
      },
      {
        'title': 'Processing',
        'subtitle': 'Your order is being prepared',
        'icon': Icons.autorenew,
        'status': 'processing',
        'completed': ['processing', 'shipped', 'delivered'].contains(status),
      },
      {
        'title': 'Shipped',
        'subtitle': 'Your order is on the way',
        'icon': Icons.local_shipping,
        'status': 'shipped',
        'completed': ['shipped', 'delivered'].contains(status),
      },
      {
        'title': 'Delivered',
        'subtitle': 'Your order has been delivered',
        'icon': Icons.done_all,
        'status': 'delivered',
        'completed': status == 'delivered',
      },
    ];
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderId}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTrackingData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchTrackingData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTrackingData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.primaryContainer.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    color: colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Order #${widget.orderId}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_trackingData != null) ...[
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Date',
                                  _trackingData!['created_at']?.split('T')[0] ?? 
                                  _trackingData!['order_date'] ?? 
                                  'N/A',
                                  colorScheme,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.payments,
                                  'Total',
                                  'Rs ${_trackingData!['total'] ?? _trackingData!['net_amount'] ?? '0'}',
                                  colorScheme,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.info_outline,
                                  'Status',
                                  _trackingData!['status'] ?? 'Unknown',
                                  colorScheme,
                                  statusColor: _getStatusColor(_trackingData!['status']),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Tracking Timeline
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Timeline',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Timeline Steps
                              ..._getTrackingSteps(_trackingData?['status']).asMap().entries.map((entry) {
                                final index = entry.key;
                                final step = entry.value;
                                final isCompleted = step['completed'] as bool;
                                final isLast = index == _getTrackingSteps(_trackingData?['status']).length - 1;

                                return _buildTimelineStep(
                                  step['title'],
                                  step['subtitle'],
                                  step['icon'],
                                  isCompleted,
                                  isLast,
                                  colorScheme,
                                );
                              }),
                            ],
                          ),
                        ),

                        // Order Items
                        if (_trackingData != null && 
                            _trackingData!['items'] != null && 
                            _trackingData!['items'] is List &&
                            (_trackingData!['items'] as List).isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...(_trackingData!['items'] as List).map((item) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: item['imgUrl'] != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      'https://ecommerce.atithyahms.com${item['imgUrl']}',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stack) =>
                                                          Icon(
                                                            Icons.image,
                                                            color: colorScheme.onPrimaryContainer,
                                                          ),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.image,
                                                    color: colorScheme.onPrimaryContainer,
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['productname'] ?? item['product_name'] ?? 'Product',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Qty: ${item['qty'] ?? item['quantity']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colorScheme.onSurface.withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Rs ${item['price'] ?? 0}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Delivery Address
                        if (_trackingData != null && _trackingData!['delivery_address'] != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _trackingData!['delivery_address']['nickname'] ?? 'Address',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _trackingData!['delivery_address']['complete_address'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                              if (_trackingData!['delivery_address']['contact_no'] != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Contact: ${_trackingData!['delivery_address']['contact_no']}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: colorScheme.onSurface.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? statusColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: statusColor ?? colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted,
    bool isLast,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? colorScheme.primary : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : Colors.grey.shade400,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? colorScheme.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? colorScheme.onSurface : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted 
                        ? colorScheme.onSurface.withOpacity(0.7) 
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
