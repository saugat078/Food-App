import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'orderProductScreen.dart';
import 'package:intl/intl.dart';

class OrdersList extends StatelessWidget {
  final String riderId;

  const OrdersList({Key? key, required this.riderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: UserProfileWidget(userId: riderId),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(
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
                  return GestureDetector(
                    child: OrderCard(orderData: orderDetails),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OrderProductScreen(
                            orderId: orderDetails['orderId'],
                            riderId: riderId,
                          )));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchOrderDetails(QueryDocumentSnapshot order) async {
    var orderData = order.data() as Map<String, dynamic>;

    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(orderData['userId'])
        .get();
    var userName = userSnapshot.data()?['name'] ?? 'Unknown User';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_bag, color: Colors.teal, size: 30),
        ),
        title: Text(
          'Order #${orderData['orderId'].substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Total: \Rs. ${orderData['totalPrice'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            Text('Ordered by: ${orderData['userName']}', 
                 style: const TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formattedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class UserProfileWidget extends StatelessWidget {
  final String userId;

  const UserProfileWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('riders').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Icon(Icons.error);
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Icon(Icons.person);
        }

        Map<String, dynamic> riderData = snapshot.data!.data() as Map<String, dynamic>;
        String name = riderData['name'] ?? 'N/A';
        String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(riderData: riderData),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.teal,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> riderData;

  const UserProfileScreen({Key? key, required this.riderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${riderData['name'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Email: ${riderData['email'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Phone: ${riderData['phone'] ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}