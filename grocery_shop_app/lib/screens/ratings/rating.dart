import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/screens/loading_manager.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/ratingWidget.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
class RatingScreen extends StatefulWidget {
  static const routeName = '/ratingScreen';

  final List<String> restaurantIds;

  RatingScreen({Key? key, required this.restaurantIds}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0;
  final _commentController = TextEditingController();
  String? _selectedRestaurantId;
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
    print('name:$_restaurantNames');
  }

  Future<void> _submitRating() async {
    if (_selectedRestaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a restaurant to rate')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userId = uid;

    await FirebaseFirestore.instance
        .collection('resturants')
        .doc(_selectedRestaurantId)
        .collection('ratings')
        .add({
      'userId': userId,
      'rating': _rating,
      'comment': _commentController.text,
    });

    await _updateAverageRating(_selectedRestaurantId!);

    // Remove the rated restaurant from the list
    setState(() {
      _remainingRestaurantIds.remove(_selectedRestaurantId);
      _restaurantNames.remove(_selectedRestaurantId);
      _selectedRestaurantId = null;
      _rating = 0.0;
      _commentController.clear();
      _isLoading = false;
    });

    if (_remainingRestaurantIds.isEmpty) {
      // All restaurants have been rated
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted. Please rate the next restaurant.')),
      );
    }
  }

  Future<void> _updateAverageRating(String restaurantId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('resturants')
        .doc(restaurantId)
        .collection('ratings')
        .get();

    final ratings = ratingsSnapshot.docs.map((doc) => doc['rating'] as double).toList();
    final averageRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    print('Updated Average Rating for $restaurantId: $averageRating');

    await FirebaseFirestore.instance
        .collection('resturants')
        .doc(restaurantId)
        .update({
      'averagerating': averageRating,
    });
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
              TextWidget(
                text: 'Select a restaurant:',
                color: color,
                isTitle: true,
                textSize: 16,
              ),
              DropdownButton<String>(
                value: _selectedRestaurantId,
                hint: Text('Select Restaurant'),
                items: _restaurantNames.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRestaurantId = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextWidget(
                text: 'Rate your experience:',
                color: color,
                isTitle: true,
                textSize: 16,
              ),
              SizedBox(height: 8.0),
              RatingWidget(
                initialRating: _rating,
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextWidget(
                text: 'Leave a comment (optional):',
                color: color,
                textSize: 16,
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your comment here',
                  fillColor: color,
                ),
                maxLines: 4,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitRating,
                child: Text('Submit Rating'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}