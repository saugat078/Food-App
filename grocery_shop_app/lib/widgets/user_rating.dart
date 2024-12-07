import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/ratingWidget.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';

class RestaurantRatingWidget extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final Function(String) onRatingSubmitted;

  RestaurantRatingWidget({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
    required this.onRatingSubmitted,
  }) : super(key: key);

  @override
  _RestaurantRatingWidgetState createState() => _RestaurantRatingWidgetState();
}

class _RestaurantRatingWidgetState extends State<RestaurantRatingWidget> {
  double _rating = 0.0;
  final _commentController = TextEditingController();

  Future<void> _submitRating() async {
    final userId = uid;

    await FirebaseFirestore.instance
        .collection('resturants')
        .doc(widget.restaurantId)
        .collection('ratings')
        .add({
      'userId': userId,
      'rating': _rating,
      'comment': _commentController.text,
    });

    await _updateAverageRating();

    widget.onRatingSubmitted(widget.restaurantId);
  }

  Future<void> _updateAverageRating() async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('resturants')
        .doc(widget.restaurantId)
        .collection('ratings')
        .get();

    final ratings = ratingsSnapshot.docs.map((doc) => doc['rating'] as double).toList();
    final averageRating =
        ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

    await FirebaseFirestore.instance
        .collection('resturants')
        .doc(widget.restaurantId)
        .update({
      'averagerating': averageRating,
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final color = Utils(context).color;

    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.9),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: widget.restaurantName,
              color: color,
              isTitle: true,
              textSize: 18,
            ),
            SizedBox(height: 8.0),
            TextWidget(
              text: 'Rate your experience:',
              color: color,
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
                filled: true,
                fillColor: backgroundColor.withOpacity(0.5),
                border: OutlineInputBorder(),
                hintText: 'Enter your comment here',
              ),
              maxLines: 4,
              style: TextStyle(color: color),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: backgroundColor, 
              ),
              child: Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
