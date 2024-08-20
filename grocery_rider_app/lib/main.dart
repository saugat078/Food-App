import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:grocery_rider_app/firebase_options.dart';
import 'package:grocery_rider_app/pages/order_list.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

          return MaterialApp(  
      title: 'OSM Flutter Application',  
      theme: ThemeData(  
        primarySwatch: Colors.blue,  
      ),  
      home: OrderListPage(),  
    ); 
  }

}
