// import 'package:flutter/material.dart';
// import 'package:grocery_shop_app/inner_screens/cat_screen.dart';
// import 'package:grocery_shop_app/widgets/text_widget.dart';
// import 'package:provider/provider.dart';
// import '../provider/dark_theme_provider.dart';

// class CategoriesWidget extends StatelessWidget {
//   const CategoriesWidget({
//     Key? key,
//     required this.catText,
//     required this.imgPath,
//     required this.passedColor,
//   }) : super(key: key);

//   final String catText, imgPath;
//   final Color passedColor;

//   @override
//   Widget build(BuildContext context) {
//     final themeState = Provider.of<DarkThemeProvider>(context);
//     double _screenWidth = MediaQuery.of(context).size.width;
//     final Color color = themeState.getDarkTheme ? Colors.white : Colors.black;

//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, CategoryScreen.routeName,
//             arguments: catText);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           color: passedColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: passedColor.withOpacity(0.7),
//             width: 2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: _screenWidth * 0.3,
//               width: _screenWidth * 0.3,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12), // Rounded corners for the image
//                 image: DecorationImage(
//                   image: NetworkImage(imgPath),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10), // Spacing between the image and the text
//             Expanded(
//               child: TextWidget(
//                 text: catText,
//                 color: color,
//                 textSize: 20,
//                 isTitle: true,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
    required this.rating,
  }) : super(key: key);

  final String catText, imgPath;
  final Color passedColor;
  final double rating; 

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    double _screenWidth = MediaQuery.of(context).size.width;
    final Color color = themeState.getDarkTheme ? Colors.white : Colors.black;

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
        child: Row(
          children: [
            Container(
              height: _screenWidth * 0.3,
              width: _screenWidth * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imgPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10), // Spacing between the image and the text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height:12),
                  TextWidget(
                    text: catText,
                    color: color,
                    textSize: 20,
                    isTitle: true,
                  ),
                  const SizedBox(height: 10), // Spacing between the text and the rating
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => Icon(
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
}
