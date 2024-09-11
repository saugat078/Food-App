import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shop_app/screens/loading_manager.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:grocery_shop_app/widgets/user_rating.dart';

class RatingScreen extends StatefulWidget {
  static const routeName = '/ratingScreen';

  final List<String> restaurantIds;

  RatingScreen({Key? key, required this.restaurantIds}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  Map<String, String> _restaurantNames = {};
  List<String> _remainingRestaurantIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _remainingRestaurantIds = List.from(widget.restaurantIds);
    _fetchRestaurantNames();
  }

  Future<void> _fetchRestaurantNames() async {
    setState(() {
      _isLoading = true;
    });

    for (String restaurantId in _remainingRestaurantIds) {
      DocumentSnapshot restaurantSnapshot = await FirebaseFirestore.instance
          .collection('resturants')
          .doc(restaurantId)
          .get();

      if (restaurantSnapshot.exists) {
        setState(() {
          _restaurantNames[restaurantId] = restaurantSnapshot['title'];
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onRatingSubmitted(String restaurantId) {
    setState(() {
      _remainingRestaurantIds.remove(restaurantId);
      _restaurantNames.remove(restaurantId);
    });

    if (_remainingRestaurantIds.isEmpty) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted. Please rate the next restaurant.')),
      );
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Rating'),
          content: Text('Are you sure you want to cancel the rating process?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).color;
    return LoadingManager(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rate Restaurants'),
          actions: [
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _showCancelConfirmationDialog,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Progress: ${widget.restaurantIds.length - _remainingRestaurantIds.length}/${widget.restaurantIds.length}',
                color: color,
                isTitle: true,
                textSize: 16,
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _remainingRestaurantIds.length,
                  itemBuilder: (context, index) {
                    final restaurantId = _remainingRestaurantIds[index];
                    final restaurantName = _restaurantNames[restaurantId] ?? '';
                    return RestaurantRatingWidget(
                      restaurantId: restaurantId,
                      restaurantName: restaurantName,
                      onRatingSubmitted: _onRatingSubmitted,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}