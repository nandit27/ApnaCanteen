import 'package:flutter/material.dart';
import 'package:user_app/global.dart';

class ItemDetailsModal extends StatefulWidget {
  final Map<String, dynamic> product;

  const ItemDetailsModal({Key? key, required this.product}) : super(key: key);

  @override
  _ItemDetailsModalState createState() => _ItemDetailsModalState();
}

class _ItemDetailsModalState extends State<ItemDetailsModal> {
  int itemQuantity = 1;
  bool extraCheese = false;
  bool doublePatty = false;

  double get basePrice => (widget.product['price'] ?? 0).toDouble();
  
  double get totalPrice {
    double price = basePrice;
    if (extraCheese) price += 20;
    if (doublePatty) price += 60;
    return price * itemQuantity;
  }

  void _incrementQuantity() {
    if (itemQuantity < 50) {
      setState(() {
        itemQuantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (itemQuantity > 1) {
      setState(() {
        itemQuantity--;
      });
    }
  }

  void _addToCart() {
    String itemName = widget.product['name'] ?? 'Unknown';
    if (extraCheese) itemName += ' + Extra Cheese';
    if (doublePatty) itemName += ' + Double Patty';

    items.add(itemName);
    quantity.add(itemQuantity);
    prices.add(totalPrice / itemQuantity);
    total = calculateTotal();

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart'),
        backgroundColor: const Color(0xFFFF6B6B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.product['name'] ?? 'Unknown';
    String description = widget.product['description'] ?? 'Delicious food item from our menu';
    List<dynamic> images = widget.product['images'] ?? [];
    String imageUrl = images.isNotEmpty 
        ? images[0] 
        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Close Button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 4),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 240,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.fastfood, size: 64, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'BESTSELLER',
                                style: TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D0C0C),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              '4.8',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            Text(
                              ' (1.2k)',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Icon(Icons.local_fire_department, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '450 kcal',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              '20 min',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${basePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.grey[200],
                  ),

                  // Description
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Customization Options
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CUSTOMIZE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCustomOption(
                          'Extra Cheese Slice',
                          20,
                          extraCheese,
                          (value) => setState(() => extraCheese = value!),
                        ),
                        const SizedBox(height: 12),
                        _buildCustomOption(
                          'Double Patty',
                          60,
                          doublePatty,
                          (value) => setState(() => doublePatty = value!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              Icons.remove,
                              _decrementQuantity,
                              itemQuantity > 1,
                            ),
                            SizedBox(
                              width: 56,
                              child: Text(
                                '$itemQuantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              Icons.add,
                              _incrementQuantity,
                              true,
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _addToCart,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8A8A)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ADD TO CART',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            '₹${totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomOption(String label, double price, bool value, Function(bool?) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? const Color(0xFFFF6B6B).withOpacity(0.5) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: value ? const Color(0xFFFF6B6B) : Colors.white,
                    border: Border.all(
                      color: value ? const Color(0xFFFF6B6B) : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: value
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '+₹${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed, bool enabled, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF6B6B) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : (enabled ? Colors.grey[500] : Colors.grey[300]),
          size: 20,
        ),
      ),
    );
  }
}
