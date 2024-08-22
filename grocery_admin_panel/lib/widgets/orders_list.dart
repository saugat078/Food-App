
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No orders found', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index];
            return FutureBuilder<Map<String, dynamic>>(
              future: fetchOrderDetails(order),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error fetching details'));
                }

                var orderDetails = snapshot.data!;
                return OrderCard(orderData: orderDetails);
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchOrderDetails(QueryDocumentSnapshot order) async {
    var orderData = order.data() as Map<String, dynamic>;
    
    // Fetch product name
    // var productSnapshot = await FirebaseFirestore.instance
    //     .collection('products')
    //     .doc(orderData['productId'])
    //     .get();
    // var productName = productSnapshot.data()?['title'] ?? 'Unknown Product';

    // Fetch user name
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(orderData['userId'])
        .get();
    var userName = userSnapshot.data()?['name'] ?? 'Unknown User';

    // Add the fetched names to the order data
    // orderData['productName'] = productName;
    orderData['userName'] = userName;

    return orderData;
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var orderDate = (orderData['orderDate'] as Timestamp).toDate();
    var formattedDate = DateFormat('MMM d, yyyy').format(orderDate);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${orderData['orderId'].substring(0, 8)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(formattedDate,
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child: Image.network(
                //     orderData['imageUrl'],
                //     width: 80,
                //     height: 80,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(orderData['productName'],
                      //     style: TextStyle(fontSize: 16)),
                      // SizedBox(height: 4),
                      // Text('Quantity: ${orderData['quantity']}',
                      //     style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Total: \$${orderData['totalPrice'].toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Ordered by: ${orderData['userName']}', 
                 style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
