import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shop_app/inner_screens/product_details.dart';
import 'package:grocery_shop_app/models/wishlist_model.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:grocery_shop_app/widgets/heart_btn.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';

import '../../providers/products_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/utils.dart';

class WishlistWidget extends StatelessWidget {
  const WishlistWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);
    final wishlistModel = Provider.of<WishlistModel>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final getCurrProduct = productProvider.findProById(wishlistModel.productId);
    
    if (getCurrProduct == null) {
      return const SizedBox.shrink(); // Return an empty widget if the product is not found
    }

    double usedPrice = getCurrProduct.isOnSale
        ? getCurrProduct.salePrice
        : getCurrProduct.price;
        
    bool _isInWishlist = wishlistProvider.getWishlistItems.containsKey(getCurrProduct.id);
    final cartProvider = Provider.of<CartProvider>(context);
    bool _isInCart = cartProvider.getCartItems.containsKey(getCurrProduct.id);
    
    final Color color = Utils(context).color;
    Size size = Utils(context).getScreenSize;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ProductDetails.routeName,
              arguments: wishlistModel.productId);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: FancyShimmerImage(
                  imageUrl: getCurrProduct.imageUrl,
                  height: size.width * 0.3,
                  width: double.infinity,
                  boxFit: BoxFit.contain,
                ),
              ),
              // Info Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: getCurrProduct.title,
                      color: color,
                      textSize: 16.0,
                      maxLines: 2,
                      isTitle: true,
                    ),
                    const SizedBox(height: 5),
                    TextWidget(
                      text: '\Rs.${usedPrice.toStringAsFixed(2)}',
                      color: color,
                      textSize: 18.0,
                      maxLines: 1,
                      isTitle: true,
                    ),
                    const SizedBox(height: 5),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (_isInCart) return;
                            await GlobalMethods.addToCart(
                              productId: getCurrProduct.id,
                              quantity: 1,
                              context: context,
                            );
                            await cartProvider.fetchCart();
                          },
                          icon: Icon(
                            _isInCart ? IconlyBold.bag2 : IconlyLight.bag2,
                            size: 22,
                            color: _isInCart ? Colors.green : color,
                          ),
                        ),
                        HeartBTN(
                          productId: getCurrProduct.id,
                          isInWishlist: _isInWishlist,
                        ),
                        IconButton(
                          onPressed: () {
                            GlobalMethods.warningDialog(
                              title: 'Remove from Wishlist?',
                              subtitle: 'Are you sure you want to remove this item?',
                              fct: () async {
                                await wishlistProvider.removeOneItem(
                                  wishlistId: wishlistModel.id,
                                  productId: getCurrProduct.id,
                                );
                              },
                              context: context,
                            );
                          },
                          icon: const Icon(
                            IconlyBroken.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}