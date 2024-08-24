import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderModel with ChangeNotifier {
  final String orderId, userId, userName, totalPrice;
  final List<dynamic> products;
  final Timestamp orderDate;

  OrderModel(
      {required this.orderId,
      required this.userId,
      // required this.productId,
      required this.products,
      required this.userName,
      required this.totalPrice,
      // required this.imageUrl,
      // required this.quantity,
      required this.orderDate});
}
