import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/models/products_model.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/providers/wishlist_provider.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/heart_btn.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../inner_screens/product_details.dart';
import '../services/global_methods.dart';
import 'price_widget.dart';

class OnSaleWidget extends StatelessWidget {
  const OnSaleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productModel = Provider.of<ProductModel>(context);
      print('Building OnSaleWidget for product: ${productModel.id}: ${productModel.title}');

    final Color color = Utils(context).color;
    final theme = Utils(context).getTheme;
    final size = MediaQuery.of(context).size;
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    bool _isInCart = cartProvider.getCartItems.containsKey(productModel.id);
    bool _isInWishlist = wishlistProvider.getWishlistItems.containsKey(productModel.id);

    return Material(
      color: Theme.of(context).cardColor.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      child: Container(width:size.width*0.45,height:size.width*0.01,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, ProductDetails.routeName,
                arguments: productModel.id);
          },
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FancyShimmerImage(
                      imageUrl: productModel.imageUrl,
                      height: size.width * 0.15,
                      width: size.width * 0.15,
                      boxFit: BoxFit.fill,
                      errorWidget: Icon(Icons.error),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: productModel.isPiece ? '1 Piece' : '1 Plate',
                            color: color,
                            textSize: size.width * 0.035,
                            isTitle: true,
                          ),
                          SizedBox(height: size.height * 0.005),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _addToCart(context, productModel.id),
                                child: Icon(
                                  _isInCart ? IconlyBold.bag2 : IconlyLight.bag2,
                                  size: size.width * 0.05,
                                  color: _isInCart ? Colors.green : color,
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              HeartBTN(
                                productId: productModel.id,
                                isInWishlist: _isInWishlist,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                PriceWidget(
                  salePrice: productModel.salePrice,
                  price: productModel.price,
                  textPrice: '1',
                  isOnSale: true,
                ),
                SizedBox(height: size.height * 0.005),
                TextWidget(
                  text: productModel.title,
                  color: color,
                  textSize: size.width * 0.03,
                  isTitle: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, String productId) async {
    final User? user = authInstance.currentUser;
    if (user == null) {
      GlobalMethods.errorDialog(
        subtitle: 'No user found, Please login first!',
        context: context,
      );
      return;
    }
    await GlobalMethods.addToCart(productId: productId, quantity: 1, context: context);
    await Provider.of<CartProvider>(context, listen: false).fetchCart();
  }
}
