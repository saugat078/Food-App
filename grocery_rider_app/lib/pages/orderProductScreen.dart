import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:http/http.dart' as http;
class OrderProductScreen extends StatelessWidget {
  final String orderId;

  const OrderProductScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderId.substring(0, 8)}'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

        Map<String, dynamic> orderData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> products = orderData['products'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfo(orderData, context),
                const SizedBox(height: 20),
                Text('Products', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                ...products.map((product) => _buildProductCard(context, product)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildOrderInfo(Map<String, dynamic> orderData,BuildContext context) {
    Timestamp orderDate = orderData['orderDate']; 
    String formattedDate = DateFormat('MMMM d, yyyy at h:mm:ss a').format(orderDate.toDate());

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Date: $formattedDate'),
            Text('Total Price: \Rs. ${orderData['totalPrice'].toStringAsFixed(2)}'),
            Text('Customer: ${orderData['userName']}'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  MapsLauncher.launchCoordinates(
                    26.629307, 87.982475, 'Delivery Point is here');
                },
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Open Delivery Location', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _sendNotification(orderData["userId"], context, orderData['orderId']);
                },
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Product delivered and notified', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('products').doc(product['productId']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Error loading product')));
        }

        Map<String, dynamic> productData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  productData['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productData['title'], style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    _buildPriceWidget(productData),
                    const SizedBox(height: 4),
                    Text('Category: ${productData['productCategoryName']}'),
                    Text(productData['isPiece'] ? 'Sold by: Piece' : 'Sold by: 1kg'),
                    const SizedBox(height: 4),
                    Text('Quantity: ${product['quantity']}'),
                    Text('Subtotal: \Rs. ${(product['price'] * product['quantity']).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceWidget(Map<String, dynamic> productData) {
    if (productData['isOnSale']) {
      return Row(
        children: [
          Text(
            '\$${productData['salePrice'].toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${productData['price']}',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ],
      );
    } else {
      return Text(
        '\Rs. ${productData['price']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }
}


  Future<void> _sendNotification(String userId, BuildContext context, String orderId) async {
   String constructFCMPayload(String? token) {
  
          return jsonEncode({
              'token': token,
              'data': {
              'orderId': orderId,
      },
        'notification': {
        'title': 'Bhooj',
        'body': 'Your order has been delivered successfully.',
    },
  });
}
 
    try {
      // Fetch the user's FCM token from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      String userToken = userDoc['fcmToken'];

    if (userToken == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(userToken),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notification: $e')),
      );
    }
  }
