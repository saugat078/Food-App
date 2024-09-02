import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shop_app/widgets/ratingWidget.dart';

class RatingScreen extends StatefulWidget {
  static const routeName = '/ratingScreen';

  final String restaurantId;

  RatingScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0;
  final _commentController = TextEditingController();

  Future<void> _submitRating() async {
    final userId = "user123"; 
    await FirebaseFirestore.instance
        .collection('resturants')
        .doc(widget.restaurantId)
        .set({
          'userId': userId,
          'rating': _rating,
          'comment': _commentController.text,
        });

    await _updateAverageRating();
    Navigator.pop(context); 
  }

  Future<void> _updateAverageRating() async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('resturants')
        .doc(widget.restaurantId)
        .collection('ratings')
        .get();

    final ratings = ratingsSnapshot.docs.map((doc) => doc['rating'] as double).toList();
    final averageRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

    await FirebaseFirestore.instance
        .collection('resturants')
        .doc(widget.restaurantId)
        .update({
          'rating': averageRating,
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate your experience:',
              style: Theme.of(context).textTheme.titleLarge,
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
            Text(
              'Leave a comment (optional):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your comment here',
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
    );
  }
}
