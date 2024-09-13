import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_rider_app/userProfile/user.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:googleapis_auth/auth_io.dart' as auth;


class OrderProductScreen extends StatelessWidget {
  final String orderId;
  final String riderId; 

  const OrderProductScreen({Key? key, required this.orderId, required this.riderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderId.substring(0, 8)}'),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: UserProfileWidget(userId: riderId),
          ),
        ],
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
          List<dynamic> resturantsId = orderData['resturantsId'];

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
                onPressed: ()async {
                final  accessToken =  await _getAccessToken(); 
                _sendNotification(orderData["userId"], context, orderData['resturantsId'], accessToken);
                      
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
                    Text(productData['isPiece'] ? 'Sold by: Piece' : 'Sold by: Plate'),
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

Future<String> _getAccessToken() async{
  final serviceAccountJson = {
  "type": "service_account",
  "project_id": "grocery-app-29daf",
  "private_key_id": "e2cfb569996a2cb1bd562fe594bf0b2f25079e36",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDDgRISNFexwkOC\nJYhpks7WYDib/whXpHv4own1UxDo1rWGBb4RLSJLL4OCbr8gedvcgve0HokmGyPd\n2qqlaa3vC0ohV0S//Lx4vYjv8UnOHPedFlwUaPCPx/XkBUjaT5udhUno9E8DU0Hf\nOpLhv/OhOgm02wWQpoZ4epsUL4UTNHAA/8JZGVCuIPR5/b8H3qaTuIHlh1Pj1K57\n9u2AoICV7EwO9mQfC7PRNRpeaSWk1UpNva4HqL+zRWcPY4ILcp9zDy3U1HmHWpHk\nDG+yAxBiZbn9/SVPziKnabx5Y3g1zX+A5TlowVPi6bN1EL3J0GwcRoUtlogE7Oe2\n3K4aO4o3AgMBAAECggEAGbx+AoN9dTBw7qBo6sJMFDsqeJlZdyAiFG3HZnzUNwfn\ncYiD/YLcMYWZtwFD4SSUOt0gJUf3ygUR8vym24uj6ASrx45+GxVMQktrzBpkGuFZ\nVLFC1zT7+2bZXyEK9szlXBaAek2JsT2z6Devv6QjOvrcQutU5OE8cSkYDSThodCu\n2c5MWqZ2gohwbjiz4Y+SjkbDQuPei1wYns+M4tvZjC2MeNIjKC0AYK1Pjc3pQMU4\nZwmLoeHPgQ661VLikZ4ebZJauFSnp1Nz3fevxw7WIC3i+wzqsfPAsj8AmN7dBEub\nwIaKGVvyhm+l7Oydg23ibcUL27g4n7wVfTeTjCyTIQKBgQD2OxNrOiYIHIwb/cgQ\ngmliwKtbbjJxw+sj4QfbC3OtHj0QcknACy9JuFb2EIimvkD0NQhNPQWL7yF24n1p\nwwuujEoD5CAZhqYRvmsBn8c0Oi0YrNaLGY+EP1RfnydQ2q+eBt+WdMw0MGfvkePD\ngz2qPDRfx4SqmYGmrMfxGamcSQKBgQDLQsX/dUZfldOBqWrum4LzYAnrclo9wiVc\n8ObaC/3e/+k288bQM765kkKHcFBK35USsPkIYfKL7dB2BPeV3UgPUNGJ7CI5tIfv\niZAq8sMYQ7fLZ76249Gy+uAftbal0/d7eeoZ4skIcSRIuhePeIp5DEKGOqVPdvNg\nuzKveoryfwKBgQCJXjfdMFmbWOHJk/GTVE4a68YtgfLeiSCbqaVKTL9CK4aBsGD4\npMTC6faJ3HuAGs/97cAt5wc7JDOVMZIp+MiBnn6EYTaPRxFLAOKNy2fE+VfDVlly\nzNXGP9aAajfy4a3sCYWfWJW73+18N/XLU2KJoIDPlm2rB2zPYcFB/sEjEQKBgFk9\n2fzNGrbA63oUTjSw5o/AbNqI/IH9CbaCtnippy8PoO9VnMaw0V5cjwU0FKyq+aKZ\nPN2nU3yIT2xhxepwm0DONRGfMW+wibZr6XZR28J9iOaviBZ4dAtnBpwlhinMpO37\nmwL+hVFFi666tblyLSn0bgjNGuOG0Fh6GEjfPr41AoGACFECVxuxExFhYlHSFfY9\n6GXBopbo1qIx7e2nUt0eX1UOCrFILqh8KUmQk3cWDgA62TLE6MMVgHNx3gCQS+/U\n0M0k1FgJUso+RETP1T4UBzI4qLWpfHHu9j6iUSGPpDip6dDOBXQsrzne98EUrVYd\nO0h5+iFFx2cdmI9xjCBkP1Y=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-eloht@grocery-app-29daf.iam.gserviceaccount.com",
  "client_id": "109769308924305455420",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-eloht%40grocery-app-29daf.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};

List<String> scopes = [
  "https://www.googleapis.com/auth/userinfo.email",
  "https://www.googleapis.com/auth/firebase.database",
  "https://www.googleapis.com/auth/firebase.messaging"
];

http.Client client = await auth.clientViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson),scopes);

auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes, client);

client.close();
print(credentials.accessToken.data);
return credentials.accessToken.data;
}

  Future<void> _sendNotification(String userId, BuildContext context, List<dynamic> resturantsId, String accessToken) async {
   String constructFCMPayload(String? token, List<dynamic>? resturantsId) {
  
          return jsonEncode({
                      "message": {
                        "data": {
                          "resturantId": resturantsId
                        },
                        "token": token,
                        "notification": {
                          "body": "Your order has been delivered successfully.",
                          "title": "Bhooj"
                          
                        }
                      }
        });
        }
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      String userToken = userDoc['fcmToken'];

      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/grocery-app-29daf/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: constructFCMPayload(userToken, resturantsId),
      );
      print('FCM request for device sent!');
      print(response.body);
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notification: $e')),
      );
    }
  }
