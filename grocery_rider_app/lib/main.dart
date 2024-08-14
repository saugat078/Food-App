import 'package:flutter/material.dart';
import 'package:grocery_rider_app/Map/Map.dart';

void main() => runApp(MyApp());  
  
class MyApp extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      title: 'OSM Flutter Application',  
      theme: ThemeData(  
        primarySwatch: Colors.blue,  
      ),  
      home: MapScreen(),  
    );  
  }  
}  
