import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/models/order_model.dart';

class OrdersProvider with ChangeNotifier{
    static List<OrderModel> _orders = [];
  List<OrderModel> get getOrders {
    return _orders;
  }
   Future<void> fetchOrders() async {
    print("fetching the order function called--------------");
    try {
      User? user = authInstance.currentUser;
    await FirebaseFirestore.instance
        .collection('orders').where("userId", isEqualTo: user!.uid)
        //.orderBy('orderDate', descending: false)
        .get()
        .then((QuerySnapshot ordersSnapshot) {
      _orders = [];
      // _orders.clear();
      ordersSnapshot.docs.forEach((element) {
        _orders.insert(
          0,
          OrderModel(
            orderId: element.get('orderId'),
            userId: element.get('userId'),
            products:element.get('products'),
            resturantsId:element.get('resturantsId'),
            userName: element.get('userName'),
            totalPrice: element.get('totalPrice').toString(),
            // imageUrl: element.get('imageUrl'),
            // quantity: element.get('quantity').toString(),
            orderDate: element.get('orderDate'),
            status: element.get('status')
          ),
        );
      });
    });
    notifyListeners();
    } catch (e) {
      print('Error From Firebase $e');
    }
    
  }
    void clearLocalOrder() {
    _orders.clear();
    notifyListeners();
  }

}