import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This is a one-time utility screen to fix the 'available' field in products
/// Run this once if products show 'available: true' instead of 'available: "Y"'
class FixProductsAvailability extends StatefulWidget {
  @override
  State<FixProductsAvailability> createState() => _FixProductsAvailabilityState();
}

class _FixProductsAvailabilityState extends State<FixProductsAvailability> {
  List<Map<String, dynamic>> _diagnostics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    try {
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      
      List<Map<String, dynamic>> diag = [];
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        diag.add({
          'name': data['name'] ?? 'Unnamed',
          'available': data['available'],
          'availableType': data['available'].runtimeType.toString(),
        });
      }
      
      setState(() {
        _diagnostics = diag;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fix Products Availability'),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'This will update all products to use "Y"/"N" format for availability',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    
                    // Diagnostics section
                    if (_diagnostics.isNotEmpty) ...[
                      const Text(
                        'Current Database Values:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _diagnostics.map((diag) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '${diag['name']}: "${diag['available']}" (${diag['availableType']})',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    ElevatedButton(
                      onPressed: () async {
                        await _fixProductsAvailability(context);
                        await _loadDiagnostics(); // Reload to show updated values
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Fix All Products',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _fixProductsAvailability(BuildContext context) async {
    try {
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      
      int fixed = 0;
      int total = productsSnapshot.docs.length;
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final available = data['available'];
        
        bool needsUpdate = false;
        String newValue = 'Y'; // Default to available
        
        // Check various cases that need fixing
        if (available == null) {
          needsUpdate = true;
          newValue = 'Y';
        } else if (available is bool) {
          needsUpdate = true;
          newValue = available ? 'Y' : 'N';
        } else {
          String availString = available.toString().trim().toUpperCase();
          
          // Handle various string formats
          if (availString.isEmpty) {
            needsUpdate = true;
            newValue = 'Y';
          } else if (availString == 'TRUE' || availString == 'T' || availString == '1') {
            needsUpdate = true;
            newValue = 'Y';
          } else if (availString == 'FALSE' || availString == 'F' || availString == '0') {
            needsUpdate = true;
            newValue = 'N';
          } else if (availString == 'YES') {
            needsUpdate = true;
            newValue = 'Y';
          } else if (availString == 'NO') {
            needsUpdate = true;
            newValue = 'N';
          } else if (availString.toLowerCase() == 'y') {
            // It's lowercase 'y', needs to be uppercase 'Y'
            needsUpdate = true;
            newValue = 'Y';
          } else if (availString.toLowerCase() == 'n') {
            // It's lowercase 'n', needs to be uppercase 'N'
            needsUpdate = true;
            newValue = 'N';
          } else if (availString != 'Y' && availString != 'N') {
            // It's some other value, default to available
            needsUpdate = true;
            newValue = 'Y';
          }
        }
        
        if (needsUpdate) {
          await doc.reference.update({'available': newValue});
          fixed++;
          print('Fixed product ${doc.id}: ${data['name']} - available: $available -> $newValue');
        }
      }

      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fixed $fixed out of $total products successfully!\n${total - fixed} were already correct.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Go back after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
