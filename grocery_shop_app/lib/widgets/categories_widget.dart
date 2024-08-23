import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:grocery_shop_app/inner_screens/cat_screen.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../provider/dark_theme_provider.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({
    Key? key,
    required this.catText,
    required this.imgPath,
    required this.passedColor,
    this.rating,
  }) : super(key: key);

  final String catText, imgPath;
  final Color passedColor;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    final double _screenWidth = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final Color color = themeState.getDarkTheme ? Colors.white : Colors.black;

    return rating == null
        ? _buildGridWidget(context, _screenWidth,_height, color)
        : _buildRowWidget(context, _screenWidth, color);
  }


  Widget _buildRowWidget(BuildContext context, double _screenWidth, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, CategoryScreen.routeName, arguments: catText);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: passedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: passedColor.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: _screenWidth * 0.25,
              height: _screenWidth * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imgPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: catText,
                    color: color,
                    textSize: _screenWidth < 600 ? 16 : 20,
                    isTitle: true,
                  ),
                  const SizedBox(height: 4),
                  RatingBar.builder(
                    initialRating: rating!,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: _screenWidth < 600 ? 16 : 20,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      // Handle rating update if needed
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildGridWidget(BuildContext context, double _screenWidth,double _height, Color color) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      physics: const NeverScrollableScrollPhysics(), // Disables scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _screenWidth< 600 ? 1 : 2,
        childAspectRatio: _screenWidth/_height *2.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 1,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, CategoryScreen.routeName,
                arguments: catText);
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: passedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: passedColor.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imgPath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextWidget(
                  text: catText,
                  color: color,
                  textSize: 16,
                  isTitle: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}