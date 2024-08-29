import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:grocery_shop_app/providers/wishlist_provider.dart';
import 'package:grocery_shop_app/widgets/empty_screen.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../../services/global_methods.dart';
import '../../services/utils.dart';
import '../../widgets/back_widget.dart';
import 'wishlist_widget.dart';

class WishlistScreen extends StatelessWidget {
  static const routeName = "/WishlistScreen";
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistItemsList =
        wishlistProvider.getWishlistItems.values.toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackWidget(),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextWidget(
          text: 'Wishlist',
          color: color,
          isTitle: true,
          textSize: 22,
        ),
        actions: [
          IconButton(
            onPressed: () {
              GlobalMethods.warningDialog(
                title: 'Empty your wishlist?',
                subtitle: 'Are you sure?',
                fct: () async {
                  await wishlistProvider.clearOnlineWishlist();
                  wishlistProvider.clearLocalWishlist();
                },
                context: context,
              );
            },
            icon: Icon(
              IconlyBroken.delete,
              color: color,
            ),
          ),
        ],
      ),
      body: wishlistItemsList.isEmpty
          ? const EmptyScreen(
              title: 'Your Wishlist Is Empty',
              subtitle: 'Explore more and shortlist some items',
              imagePath: 'assets/images/wishlist.png',
              buttonText: 'Add a wish',
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return MasonryGridView.count(
                    crossAxisCount: constraints.maxWidth > 700 ? 3 : 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    itemCount: wishlistItemsList.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider.value(
                        value: wishlistItemsList[index],
                        child: const WishlistWidget(),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
