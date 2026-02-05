import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/global.dart';
import 'package:intl/intl.dart';

class ModernOrderHistoryPage extends StatefulWidget {
  const ModernOrderHistoryPage({Key? key}) : super(key: key);

  @override
  _ModernOrderHistoryPageState createState() => _ModernOrderHistoryPageState();
}

class _ModernOrderHistoryPageState extends State<ModernOrderHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
        return Color(0xFF10B981);
      case 'waiting':
        return Color(0xFF3B82F6);
      case 'completed':
        return Color(0xFF10B981);
      case 'cancelled':
        return Color(0xFF9CA3AF);
      default:
        return Color(0xFFF59E0B);
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'N/A';
      }
      
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildOrderCard(DocumentSnapshot order, bool isActive) {
    final String orderId = order.id;
    final String amount = order['amount']?.toString() ?? '0';
    final String status = order['status']?.toString() ?? 'pending';
    final String payment = order['payment']?.toString() ?? 'N/A';
    final List<dynamic> items = order['items'] ?? [];
    final List<dynamic> quantities = order['quantity'] ?? [];
    final dynamic datetime = order['datetime'];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showOrderDetails(order);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${orderId.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatDateTime(datetime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),
              
              // Items Summary
              Row(
                children: [
                  Icon(Icons.fastfood, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getItemsSummary(items, quantities),
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Payment Method
              Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    payment.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),
              
              // Bottom Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Amount
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '₹$amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                  
                  // Action Buttons
                  Row(
                    children: [
                      if (isActive && status.toLowerCase() == 'ready')
                        ElevatedButton(
                          onPressed: () {
                            _collectOrder(orderId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF10B981),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Collect',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      if (!isActive)
                        OutlinedButton.icon(
                          onPressed: () {
                            _reorder(items, quantities);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFFFF6B6B),
                            side: BorderSide(color: Color(0xFFFF6B6B)),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(Icons.refresh, size: 16),
                          label: Text(
                            'Reorder',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getItemsSummary(List<dynamic> items, List<dynamic> quantities) {
    if (items.isEmpty) return 'No items';
    
    String summary = '';
    int totalItems = items.length;
    
    for (int i = 0; i < (totalItems > 2 ? 2 : totalItems); i++) {
      final qty = i < quantities.length ? quantities[i] : 1;
      summary += '${items[i]} x$qty';
      if (i < totalItems - 1 && i < 1) summary += ', ';
    }
    
    if (totalItems > 2) {
      summary += ' +${totalItems - 2} more';
    }
    
    return summary;
  }

  void _showOrderDetails(DocumentSnapshot order) {
    final String orderId = order.id;
    final String amount = order['amount']?.toString() ?? '0';
    final String status = order['status']?.toString() ?? 'pending';
    final String payment = order['payment']?.toString() ?? 'N/A';
    final List<dynamic> items = order['items'] ?? [];
    final List<dynamic> quantities = order['quantity'] ?? [];
    final dynamic datetime = order['datetime'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '#${orderId.substring(0, 12).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Order Info
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    _buildInfoRow(Icons.access_time, 'Order Time', _formatDateTime(datetime)),
                    SizedBox(height: 16),
                    
                    // Payment
                    _buildInfoRow(Icons.payment, 'Payment Method', payment.toUpperCase()),
                    SizedBox(height: 24),
                    
                    // Items Header
                    Text(
                      'Items Ordered',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Items List
                    ...List.generate(items.length, (index) {
                      final qty = index < quantities.length ? quantities[index] : 1;
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                items[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Text(
                              'x$qty',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Total
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '₹$amount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFFF6B6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Color(0xFFFF6B6B)),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _collectOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'completed'});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order collected successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reorder(List<dynamic> orderItems, List<dynamic> quantities) {
    // Clear current cart
    total = 0;
    items.clear();
    quantity.clear();
    prices.clear();
    
    // Add items to cart (simplified - you might need to fetch prices from products collection)
    for (int i = 0; i < orderItems.length; i++) {
      items.add(orderItems[i]);
      if (i < quantities.length) {
        quantity.add(quantities[i]);
      } else {
        quantity.add(1);
      }
      // You'll need to fetch the actual price from products collection
      prices.add(0); // Placeholder
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items added to cart! (Note: Please verify prices)'),
        backgroundColor: Color(0xFFFF6B6B),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFFFF6B6B),
          unselectedLabelColor: Color(0xFF64748B),
          indicatorColor: Color(0xFFFF6B6B),
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions, size: 18),
                  SizedBox(width: 8),
                  Text('Active', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 18),
                  SizedBox(width: 8),
                  Text('Past', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Orders Tab
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', whereIn: ['pending', 'waiting', 'ready'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Color(0xFFE2E8F0)),
                      SizedBox(height: 16),
                      Text(
                        'No Active Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your active orders will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Sort orders by datetime in the app
              final orders = snapshot.data!.docs.toList();
              orders.sort((a, b) {
                final aTime = a['datetime'];
                final bTime = b['datetime'];
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                
                DateTime aDate = aTime is Timestamp ? aTime.toDate() : DateTime.parse(aTime.toString());
                DateTime bDate = bTime is Timestamp ? bTime.toDate() : DateTime.parse(bTime.toString());
                return bDate.compareTo(aDate);
              });
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index], true);
                },
              );
            },
          ),
          
          // Past Orders Tab
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', whereIn: ['completed', 'cancelled'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Color(0xFFE2E8F0)),
                      SizedBox(height: 16),
                      Text(
                        'No Past Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your completed orders will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Sort orders by datetime in the app
              final orders = snapshot.data!.docs.toList();
              orders.sort((a, b) {
                final aTime = a['datetime'];
                final bTime = b['datetime'];
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                
                DateTime aDate = aTime is Timestamp ? aTime.toDate() : DateTime.parse(aTime.toString());
                DateTime bDate = bTime is Timestamp ? bTime.toDate() : DateTime.parse(bTime.toString());
                return bDate.compareTo(aDate);
              });
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index], false);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
