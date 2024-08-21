import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

class OrderListPage extends StatelessWidget {
  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
    } else if (timestamp is String) {
      return timestamp;
    }
    return 'Unknown';
  }

  Future<List<OrderWithProductData>> _fetchOrdersWithProductData() async {
    QuerySnapshot orderSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    List<OrderWithProductData> ordersWithProductData = [];

    for (var doc in orderSnapshot.docs) {
      Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
      String productId = orderData['productId'] as String? ?? '';
      print(productId);

      if (productId.isNotEmpty) {
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        Map<String, dynamic>? productData =
            productSnapshot.data() as Map<String, dynamic>?;

        print(productData.toString());
        ordersWithProductData.add(OrderWithProductData(
          orderData: orderData,
          productData: productData,
        ));
      } else {
        ordersWithProductData.add(OrderWithProductData(
          orderData: orderData,
          productData: null,
        ));
      }
    }

    return ordersWithProductData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder<List<OrderWithProductData>>(
        future: _fetchOrdersWithProductData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<OrderWithProductData> ordersWithProductData = snapshot.data ?? [];

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: ordersWithProductData.length,
            itemBuilder: (context, index) {
              OrderWithProductData orderWithProductData =
                  ordersWithProductData[index];
              Map<String, dynamic> orderData = orderWithProductData.orderData;
              Map<String, dynamic>? productData = orderWithProductData.productData;

              return OrderCard(
                imageUrl: productData?['imageUrl'] as String? ?? '',
                personName: orderData['userName'] as String? ?? 'Unknown',
                restaurantName: productData?['productCategoryName'] as String? ?? 'Unknown',
                orderDate: formatTimestamp(orderData['orderDate']),
                price: (orderData['price'] as num?)?.toStringAsFixed(2) ?? 'Unknown',
              );
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String imageUrl;
  final String personName;
  final String restaurantName;
  final String orderDate;
  final String price;

  const OrderCard({
    Key? key,
    required this.imageUrl,
    required this.personName,
    required this.restaurantName,
    required this.orderDate,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
              ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    personName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(restaurantName),
                  Text(orderDate),
                  Text('\Rs.${price}'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                MapsLauncher.launchCoordinates(
                    26.629307, 87.982475, 'Delivery Point is here');
           
              },
              child: Text('Open Map'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderWithProductData {
  final Map<String, dynamic> orderData;
  final Map<String, dynamic>? productData;

  OrderWithProductData({required this.orderData, this.productData});
}
