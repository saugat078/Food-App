import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/models/products_model.dart';
import 'package:grocery_shop_app/models/wishlist_model.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/providers/wishlist_provider.dart';
import 'package:grocery_shop_app/widgets/price_widget.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../inner_screens/on_sale_screen.dart';
import '../inner_screens/product_details.dart';
import '../services/global_methods.dart';
import '../services/utils.dart';
import 'heart_btn.dart';

class FeedsWidget extends StatefulWidget {
  const FeedsWidget({Key? key}) : super(key: key);
  @override
  State<FeedsWidget> createState() => _FeedsWidgetState();
}

class _FeedsWidgetState extends State<FeedsWidget> {
  final _quantityTextController = TextEditingController();
  @override
  void initState() {
    _quantityTextController.text = '1';
    super.initState();
  }

  @override
  void dispose() {
    _quantityTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final Color color = Utils(context).color;
    Size size = Utils(context).getScreenSize;
    bool? _isInCart = cartProvider.getCartItems.containsKey(productModel.id);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    bool? _isIWishlist =
        wishlistProvider.getWishlistItems.containsKey(productModel.id);

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          // GlobalMethods.navigateTo(
          //     ctx: context, routeName: ProductDetails.routeName);
          Navigator.pushNamed(context, ProductDetails.routeName,
              arguments: productModel.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(children: [
          FancyShimmerImage(
            imageUrl: productModel.imageUrl,
            height: size.width * 0.21,
            width: size.width * 0.2,
            boxFit: BoxFit.fill,
          ),
          SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: TextWidget(
                    text: productModel.title,
                    color: color,
                    maxLines: 1,
                    textSize: 18,
                    isTitle: true,
                  ),
                ),
                Flexible(
                    flex: 1,
                    child: HeartBTN(
                      productId: productModel.id,
                      isInWishlist: _isIWishlist,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: PriceWidget(
                    salePrice: productModel.salePrice,
                    price: productModel.price,
                    textPrice: _quantityTextController.text,
                    isOnSale: productModel.isOnSale,
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 6,
                        child: FittedBox(
                          child: TextWidget(
                            text: productModel.isPiece ? 'Piece' : 'KG',
                            color: color,
                            textSize: 20,
                            isTitle: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        flex: 2,
                        // TextField can be used also instead of the textFormField
                        child: TextFormField(
                          controller: _quantityTextController,
                          key: const ValueKey('10'),
                          style: TextStyle(color: color, fontSize: 18),
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          enabled: true,
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                _quantityTextController.text = '1';
                              } else {}
                            });
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[0-9.]'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          //const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                final User? user = authInstance.currentUser;
                if (user == null) {
                  GlobalMethods.errorDialog(
                      subtitle: 'No user found, Please login first!',
                      context: context);
                  return;
                }
                if (_isInCart) {
                  GlobalMethods.errorDialog(subtitle: 'Product already exists in cart!', context: context);
                  return;
                }
                await GlobalMethods.addToCart(
                    productId: productModel.id, quantity: 1, context: context);
                await cartProvider.fetchCart();
                // cartProvider.addProductsToCart(
                //     productId: productModel.id,
                //     quantity: int.parse(_quantityTextController.text));
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                    ),
                  )),
              child: TextWidget(
                text: _isInCart ? 'In cart' : ' Add To Cart',
                maxLines: 1,
                color: color,
                textSize: 20,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
