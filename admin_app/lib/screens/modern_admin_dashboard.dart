import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_app/screens/modern_inventory_page.dart';
import 'package:admin_app/screens/show_category.dart';
import 'package:admin_app/screens/modern_incoming_orders.dart';
import 'package:admin_app/screens/show_feedback.dart';
import 'package:admin_app/screens/fix_products_utility.dart';

class ModernAdminDashboard extends StatefulWidget {
  @override
  _ModernAdminDashboardState createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard> {
  bool isAcceptingOrders = true;
  int categoriesCount = 0;
  int productsCount = 0;
  int pendingOrdersCount = 0;
  double averageRating = 4.8;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get categories count
      final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
      
      // Get products count
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      
      // Get pending orders count
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .get();
      
      // Get feedback for average rating
      final feedbackSnapshot = await FirebaseFirestore.instance.collection('feedback').get();
      double totalRating = 0;
      int ratingCount = 0;
      
      for (var doc in feedbackSnapshot.docs) {
        final rating = doc.data()['rating'];
        if (rating != null) {
          totalRating += rating.toDouble();
          ratingCount++;
        }
      }

      setState(() {
        categoriesCount = categoriesSnapshot.docs.length;
        productsCount = productsSnapshot.docs.length;
        pendingOrdersCount = ordersSnapshot.docs.length;
        averageRating = ratingCount > 0 ? totalRating / ratingCount : 4.8;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F5).withOpacity(0.9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1010),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hello, Admin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.build, color: Color(0xFFFF6B6B)),
                        tooltip: 'Fix Products',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FixProductsAvailability()),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAuYNifzd0a4FfKVenY-GDHlwjm0SuA5lZm8PM6bqor9Ur_20mGwPTTk0AOmojbD_7egnJSwX5IC-sheCkI9EqWUxtiky843OTa85bAUZcrX6S-CfonAwn9IflNbTJ4-mQxurZi6X5LKxMOXuh4I5PJLA7BVCuDIyXqTn2SvAL5kV0HHzUuSxFL_7ZQdRCEey603bZwbkAx3EJxN52rIabmlQAQa9fRDJf6O80m9sUw-qU7xJvsB2FUqgXwVtjdc-cdrd8gEImUZAU',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFFF6B6B),
                                child: const Icon(Icons.person, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Status Toggle Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: Color(0xFFFF6B6B),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAcceptingOrders ? 'Accepting Orders' : 'Closed',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1010),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isAcceptingOrders
                                        ? 'Canteen is currently open'
                                        : 'Canteen is currently closed',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isAcceptingOrders,
                              onChanged: (value) {
                                setState(() {
                                  isAcceptingOrders = value;
                                });
                              },
                              activeColor: const Color(0xFFFF6B6B),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Metric Grid (2x2)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                        children: [
                          _buildMetricCard(
                            'Active Categories',
                            categoriesCount.toString(),
                            Icons.category,
                            const [Color(0xFFFF6B6B), Color(0xFFFF9F9F)],
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShowCategory()),
                              );
                            },
                          ),
                          _buildMetricCard(
                            'Menu Items',
                            productsCount.toString(),
                            Icons.lunch_dining,
                            const [Color(0xFFF97316), Color(0xFFFBBF24)],
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ModernInventoryPage()),
                              );
                            },
                          ),
                          _buildMetricCard(
                            'Pending Orders',
                            pendingOrdersCount.toString(),
                            Icons.shopping_bag,
                            const [Color(0xFF2563EB), Color(0xFF06B6D4)],
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ModernIncomingOrders()),
                              );
                            },
                          ),
                          _buildMetricCard(
                            'Avg Rating',
                            averageRating.toStringAsFixed(1),
                            Icons.star,
                            const [Color(0xFF9333EA), Color(0xFF8B5CF6)],
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShowFeedback()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1010),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ModernIncomingOrders()),
                                  );
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('orders')
                                  .orderBy('datetime', descending: true)
                                  .limit(3)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final orders = snapshot.data!.docs;
                                
                                if (orders.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Center(
                                      child: Text(
                                        'No recent activity',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: List.generate(orders.length, (index) {
                                    final order = orders[index].data() as Map<String, dynamic>;
                                    final orderId = order['orderid'] ?? 'N/A';
                                    final status = order['status'] ?? 'pending';
                                    final isLast = index == orders.length - 1;
                                    final docId = orders[index].id;
                                    
                                    return _buildActivityItem(
                                      'Order #$orderId',
                                      _getStatusText(status),
                                      _getStatusIcon(status),
                                      _getStatusColor(status),
                                      isLast,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ModernIncomingOrders()),
                                        );
                                      },
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isLast,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1010),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCBD5E1),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Ready for Pickup';
      case 'preparing':
        return 'Being Prepared';
      case 'pending':
        return 'Awaiting Confirmation';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'preparing':
        return const Color(0xFFF59E0B);
      case 'pending':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }
}
