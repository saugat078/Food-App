import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/services/utils.dart';

import '../consts/constants.dart';
import 'order_product_widget.dart';

class OrderProductGridWidget extends StatelessWidget {
  const OrderProductGridWidget({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
    this.isInMain = true,
    required this.orderId,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;
  final bool isInMain;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data!.exists) {
            // Extract the 'products' array from the document
            var products = snapshot.data!.get('products') as List<dynamic>?;
            if (products != null && products.isNotEmpty) {
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: isInMain && products.length > 4 ? 4 : products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: defaultPadding,
                  mainAxisSpacing: defaultPadding,
                ),
                itemBuilder: (context, index) {
                  // Extract the productId from each product map
                  var product = products[index] as Map<String, dynamic>;
                  String productId = product['productId'] ?? '';
                  int quantity = product['quantity'] ?? 1;
                  return OrderProductWidget(
                    id: productId,
                    quantity: quantity // Pass the product ID
                  );
                },
              );
            } else {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text('No products found in this order'),
                ),
              );
            }
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Order not found'),
              ),
            );
          }
        }
        return const Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        );
      },
    );
  }
}
