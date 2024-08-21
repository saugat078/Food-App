// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:grocery_shop_app/services/utils.dart';
// import 'package:grocery_shop_app/widgets/categories_widget.dart';
// import 'package:grocery_shop_app/widgets/text_widget.dart';
// import 'package:win32/win32.dart';

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
//             text: 'Our Categories',
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
//             _buildCategoryGrid(context, 'restaurants'),  // Fetch restaurant categories
//             _buildCategoryGrid(context, 'liquor'),      // Fetch liquor categories
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryGrid(BuildContext context, String categoryType) {
//     String collectionName;
//     bool showRating;
//     if (categoryType == 'restaurants') {
//       collectionName = 'resturants';
//       showRating=true;  // Fetch from restaurants collection
//     } else if (categoryType == 'liquor') {
//       collectionName = 'liquors';
//       showRating=false;  // Fetch from liquor collection
//     } else {
//       collectionName = '';
//       showRating=false;
//     }

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection(collectionName)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No categories available.'));
//           }

//           final categories = snapshot.data!.docs;

//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 1,
//               childAspectRatio: 5 / 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               return CategoriesWidget(
//                 catText: category['title'],
//                 imgPath: category['imageUrl'],
//                 passedColor: gridColors[index % gridColors.length],
//                 rating: showRating? category['rating']?.toDouble() ?? 0.0:null,
//               );
//             },
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
            text: 'Our Categories',
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
            _buildCategoryGrid(context, 'restaurants'),  // Fetch restaurant categories
            _buildCategoryGrid(context, 'liquor'),      // Fetch liquor categories
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, String categoryType) {
    String collectionName;
    bool showRating;
    if (categoryType == 'restaurants') {
      collectionName = 'resturants';
      showRating = true;  // Fetch from restaurants collection
    } else if (categoryType == 'liquor') {
      collectionName = 'liquors';
      showRating = false;  // Fetch from liquor collection
    } else {
      collectionName = '';
      showRating = false;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
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
              crossAxisCount: 1,
              childAspectRatio: 5 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoriesWidget(
                catText: category['title'],
                imgPath: category['imageUrl'],
                passedColor: gridColors[index % gridColors.length],
                rating: showRating ? category['rating']?.toDouble() ?? 0.0 : null,
              );
            },
          );
        },
      ),
    );
  }
}
