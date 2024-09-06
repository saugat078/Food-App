import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _restaurantIds = [];
    Map<String, String> _restaurantTitleToId = {}; // Map of restaurant titles to their IDs

  List<String> get restaurantIds => _restaurantIds;
  Map<String, String> get restaurantTitleToId => _restaurantTitleToId;
  

  Future<void> fetchRestaurantIds() async {
    try {
      // Fetching all restaurants
      QuerySnapshot restaurantSnapshot = await _firestore.collection('resturants').get();

      // Populate _restaurantIds and _restaurantTitleToId
      _restaurantIds = restaurantSnapshot.docs.map((doc) => doc.id).toList();
      _restaurantTitleToId = {
        for (var doc in restaurantSnapshot.docs) doc['title']: doc.id,
      };

      notifyListeners();
    } catch (error) {
      print('Error fetching restaurant IDs: $error');
    }
  }

  Future<void> linkOrdersToRestaurants() async {
    try {
      // Fetching all restaurants
      QuerySnapshot restaurantSnapshot = await _firestore.collection('resturants').get();

      // Creating a map with restaurant titles and their IDs
      Map<String, String> restaurantTitleToId = {
        for (var doc in restaurantSnapshot.docs) doc['title']: doc.id,
      };

      // Fetching all orders
      QuerySnapshot orderSnapshot = await _firestore.collection('orders').get();

      for (var orderDoc in orderSnapshot.docs) {
        List products = orderDoc['products'];

        for (var product in products) {
          // Check if the productCategoryName matches any restaurant title
          String? restaurantId = restaurantTitleToId[product['productCategoryName']];

          if (restaurantId != null) {
            await _firestore.collection('orders').doc(orderDoc.id).update({
              'resturantsId': restaurantId,
            });
          }
        }
      }

      notifyListeners();
    } catch (error) {
      print('Error linking orders to restaurants: $error');
    }
  }
  Future<List<String>> getRestaurantIdsFromOrders() async {
    try {
      final QuerySnapshot ordersSnapshot = await _firestore.collection('orders').get();
      List<String> restaurantIds = [];

      for (var doc in ordersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('resturantsId')) {
          restaurantIds.add(data['resturantsId']);
        }
      }
      return restaurantIds;
    } catch (e) {
      print("Error fetching restaurant IDs: $e");
      return [];
    }
  }
}
