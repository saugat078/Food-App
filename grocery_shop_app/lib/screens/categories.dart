// import 'package:flutter/material.dart';
// import 'package:grocery_shop_app/services/utils.dart';
// import 'package:grocery_shop_app/widgets/categories_widget.dart';
// import 'package:grocery_shop_app/widgets/text_widget.dart';


// class CategoriesScreen extends StatelessWidget {
//   CategoriesScreen({Key? key}) : super(key: key);

//   List<Color> gridColors = [
//     const Color(0xff53B175),
//     const Color(0xffF8A44C),
//     const Color(0xffF7A593),
//     const Color(0xffD3B0E0),
//     const Color(0xffFDE598),
//     const Color(0xffB7DFF5),
//   ];

// List<Map<String, dynamic>> catInfo = [
//     {
//       'imgPath': 'assets/images/cat/fruits.png',
//       'catText': 'Fruits',
//     },
//     {
//       'imgPath': 'assets/images/cat/veg.png',
//       'catText': 'Vegetables',
//     },
//     {
//       'imgPath': 'assets/images/cat/Spinach.png',
//       'catText': 'Herbs',
//     },
//     {
//       'imgPath': 'assets/images/cat/nuts.png',
//       'catText': 'Nuts',
//     },
//     {
//       'imgPath': 'assets/images/cat/spices.png',
//       'catText': 'Spices',
//     },
//      {
//       'imgPath': 'assets/images/cat/grains.png',
//       'catText': 'Grains',
//     },
//      {
//       'imgPath': 'assets/images/cat/grains.png',
//       'catText': 'Restaurants',
//     },
//   ];
//   @override
//   Widget build(BuildContext context) {

//     final utils = Utils(context);
//     Color color = utils.color;
//     return Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           title: TextWidget(
//             text: 'Categories',
//             color: color,
//             textSize: 24,
//             isTitle: true,
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GridView.count(
//             crossAxisCount: 2,
//             childAspectRatio: 240 / 250,
//             crossAxisSpacing: 10, // Vertical spacing
//             mainAxisSpacing: 10, // Horizontal spacing 
//             children: List.generate(6, (index) {
//               return CategoriesWidget(
//                 catText: catInfo[index]['catText'],
//                 imgPath: catInfo[index]['imgPath'],
//                 passedColor: gridColors[index],
//               );
//             }),
//           ),
//         ));
//   }
// }


//NEW
// CategoriesScreen.dart
// import 'package:flutter/material.dart';
// import 'package:grocery_shop_app/services/utils.dart';
// import 'package:grocery_shop_app/widgets/categories_widget.dart';
// import 'package:grocery_shop_app/widgets/text_widget.dart';

// class CategoriesScreen extends StatelessWidget {
//   CategoriesScreen({Key? key}) : super(key: key);

//   final List<Color> gridColors = [
//     const Color(0xff53B175),
//     const Color(0xffF8A44C),
//     const Color(0xffF7A593),
//     const Color(0xffD3B0E0),
//     const Color(0xffFDE598),
//     const Color(0xffB7DFF5),
//   ];

//   final List<Map<String, dynamic>> foodCategories = [
//     {
//       'imgPath': 'assets/images/cat/timeless.jpeg',
//       'catText': 'Timeless Moments',
//     },
//     {
//       'imgPath': 'assets/images/cat/veg.png',
//       'catText': 'Vegetables',
//     },
//     {
//       'imgPath': 'assets/images/cat/Spinach.png',
//       'catText': 'Herbs',
//     },
//     {
//       'imgPath': 'assets/images/cat/nuts.png',
//       'catText': 'Nuts',
//     },
//     {
//       'imgPath': 'assets/images/cat/spices.png',
//       'catText': 'Spices',
//     },
//     {
//       'imgPath': 'assets/images/cat/grains.png',
//       'catText': 'Grains',
//     },
//   ];

//   final List<Map<String, dynamic>> liquorCategories = [
//     {
//       'imgPath': 'assets/images/cat/wine.png',
//       'catText': 'Wine',
//     },
//     {
//       'imgPath': 'assets/images/cat/beer.png',
//       'catText': 'Beer',
//     },
//     {
//       'imgPath': 'assets/images/cat/spirits.png',
//       'catText': 'Spirits',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final utils = Utils(context);
//     Color color = utils.color;
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           title: TextWidget(
//             text: 'Categories',
//             color: color,
//             textSize: 24,
//             isTitle: true,
//           ),
//           bottom: TabBar(
//             tabs: [
//               Tab(text: 'Restaurants'),
//               Tab(text: 'Liquor'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildCategoryGrid(context, foodCategories),
//             _buildCategoryGrid(context, liquorCategories),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryGrid(BuildContext context, List<Map<String, dynamic>> categories) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 240 / 250,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           return CategoriesWidget(
//             catText: categories[index]['catText'],
//             imgPath: categories[index]['imgPath'],
//             passedColor: gridColors[index % gridColors.length],
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/categories_widget.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  final List<Color> gridColors = [
    const Color(0xff53B175),
    const Color(0xffF8A44C),
    const Color(0xffF7A593),
    const Color(0xffD3B0E0),
    const Color(0xffFDE598),
    const Color(0xffB7DFF5),
  ];

  @override
  Widget build(BuildContext context) {
    final utils = Utils(context);
    Color color = utils.color;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: TextWidget(
            text: 'Categories',
            color: color,
            textSize: 24,
            isTitle: true,
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Restaurants'),
              Tab(text: 'Liquor'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryGrid(context, 'food'), // Fetch food categories
            _buildCategoryGrid(context, 'liquor'), // Fetch liquor categories
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, String categoryType) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('type', isEqualTo: categoryType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No categories available.'));
          }

          final categories = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 240 / 250,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoriesWidget(
                catText: category['catText'],
                imgPath: category['imgPath'],
                passedColor: gridColors[index % gridColors.length],
              );
            },
          );
        },
      ),
    );
  }
}
