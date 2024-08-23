// import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:grocery_shop_app/consts/firebase_const.dart';
// import 'package:grocery_shop_app/models/products_model.dart';
// import 'package:grocery_shop_app/models/wishlist_model.dart';
// import 'package:grocery_shop_app/providers/cart_provider.dart';
// import 'package:grocery_shop_app/providers/wishlist_provider.dart';
// import 'package:grocery_shop_app/widgets/price_widget.dart';
// import 'package:grocery_shop_app/widgets/text_widget.dart';
// import 'package:provider/provider.dart';

// import '../inner_screens/on_sale_screen.dart';
// import '../inner_screens/product_details.dart';
// import '../services/global_methods.dart';
// import '../services/utils.dart';
// import 'heart_btn.dart';

// class FeedsWidget extends StatefulWidget {
//   const FeedsWidget({Key? key}) : super(key: key);
//   @override
//   State<FeedsWidget> createState() => _FeedsWidgetState();
// }

// class _FeedsWidgetState extends State<FeedsWidget> {
//   final _quantityTextController = TextEditingController();
//   @override
//   void initState() {
//     _quantityTextController.text = '1';
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _quantityTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productModel = Provider.of<ProductModel>(context);
//     final cartProvider = Provider.of<CartProvider>(context);
//     final Color color = Utils(context).color;
//     Size size = Utils(context).getScreenSize;
//     bool? _isInCart = cartProvider.getCartItems.containsKey(productModel.id);
//     final wishlistProvider = Provider.of<WishlistProvider>(context);
//     bool? _isIWishlist =
//         wishlistProvider.getWishlistItems.containsKey(productModel.id);

//     return Material(
//       borderRadius: BorderRadius.circular(12),
//       color: Theme.of(context).cardColor,
//       child: InkWell(
//         onTap: () {
//           // GlobalMethods.navigateTo(
//           //     ctx: context, routeName: ProductDetails.routeName);
//           Navigator.pushNamed(context, ProductDetails.routeName,
//               arguments: productModel.id);
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Column(children: [
//           FancyShimmerImage(
//             imageUrl: productModel.imageUrl,
//             height: size.width * 0.21,
//             width: size.width * 0.2,
//             boxFit: BoxFit.fill,
//           ),
//           SizedBox(height: 5,),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   flex: 3,
//                   child: TextWidget(
//                     text: productModel.title,
//                     color: color,
//                     maxLines: 1,
//                     textSize: 18,
//                     isTitle: true,
//                   ),
//                 ),
//                 Flexible(
//                     flex: 1,
//                     child: HeartBTN(
//                       productId: productModel.id,
//                       isInWishlist: _isIWishlist,
//                     )),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   flex: 3,
//                   child: PriceWidget(
//                     salePrice: productModel.salePrice,
//                     price: productModel.price,
//                     textPrice: _quantityTextController.text,
//                     isOnSale: productModel.isOnSale,
//                   ),
//                 ),
//                 Flexible(
//                   child: Row(
//                     children: [
//                       Flexible(
//                         flex: 6,
//                         child: FittedBox(
//                           child: TextWidget(
//                             text: productModel.isPiece ? 'Piece' : 'KG',
//                             color: color,
//                             textSize: 20,
//                             isTitle: true,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       Flexible(
//                         flex: 2,
//                         // TextField can be used also instead of the textFormField
//                         child: TextFormField(
//                           controller: _quantityTextController,
//                           key: const ValueKey('10'),
//                           style: TextStyle(color: color, fontSize: 18),
//                           keyboardType: TextInputType.number,
//                           maxLines: 1,
//                           enabled: true,
//                           onChanged: (value) {
//                             setState(() {
//                               if (value.isEmpty) {
//                                 _quantityTextController.text = '1';
//                               } else {}
//                             });
//                           },
//                           inputFormatters: [
//                             FilteringTextInputFormatter.allow(
//                               RegExp('[0-9.]'),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//           //const Spacer(),
//           SizedBox(
//             width: double.infinity,
//             child: TextButton(
//               onPressed: () async {
//                 final User? user = authInstance.currentUser;
//                 if (user == null) {
//                   GlobalMethods.errorDialog(
//                       subtitle: 'No user found, Please login first!',
//                       context: context);
//                   return;
//                 }
//                 if (_isInCart) {
//                   GlobalMethods.errorDialog(subtitle: 'Product already exists in cart!', context: context);
//                   return;
//                 }
//                 await GlobalMethods.addToCart(
//                     productId: productModel.id, quantity: 1, context: context);
//                 await cartProvider.fetchCart();
//                 // cartProvider.addProductsToCart(
//                 //     productId: productModel.id,
//                 //     quantity: int.parse(_quantityTextController.text));
//               },
//               style: ButtonStyle(
//                   backgroundColor:
//                       WidgetStateProperty.all(Theme.of(context).cardColor),
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                     const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(12.0),
//                         bottomRight: Radius.circular(12.0),
//                       ),
//                     ),
//                   )),
//               child: TextWidget(
//                 text: _isInCart ? 'In cart' : ' Add To Cart',
//                 maxLines: 1,
//                 color: color,
//                 textSize: 20,
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/models/products_model.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/providers/wishlist_provider.dart';
import 'package:grocery_shop_app/widgets/price_widget.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

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
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final Color color = Utils(context).color;
    final screenSize = MediaQuery.of(context).size;
    bool _isInCart = cartProvider.getCartItems.containsKey(productModel.id);
    bool _isInWishlist = wishlistProvider.getWishlistItems.containsKey(productModel.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, ProductDetails.routeName,
                  arguments: productModel.id);
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: constraints.maxHeight > 200 ? 2 : 1,
                  child: FancyShimmerImage(
                    imageUrl: productModel.imageUrl,
                    boxFit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
                Flexible(
                  flex: constraints.maxHeight > 200 ? 2 : 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: TextWidget(
                                text: productModel.title,
                                color: color,
                                maxLines: 2,
                                textSize: constraints.maxWidth * 0.08,
                                isTitle: true,
                              ),
                            ),
                            HeartBTN(
                              productId: productModel.id,
                              isInWishlist: _isInWishlist,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Flexible(
                          child: Row(
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
                              const SizedBox(width: 5),
                              Flexible(
                                child: TextWidget(
                                  text: productModel.isPiece ? 'Piece' : 'KG',
                                  color: color,
                                  textSize: constraints.maxWidth * 0.06,
                                  isTitle: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _isInCart
                                  ? null
                                  : () async {
                                      final User? user = authInstance.currentUser;
                                      if (user == null) {
                                        GlobalMethods.errorDialog(
                                            subtitle: 'No user found, Please login first!',
                                            context: context);
                                        return;
                                      }
                                      await GlobalMethods.addToCart(
                                          productId: productModel.id,
                                          quantity: int.parse(_quantityTextController.text),
                                          context: context);
                                      await cartProvider.fetchCart();
                                    },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  _isInCart ? Colors.grey : Theme.of(context).colorScheme.secondary,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                              child: TextWidget(
                                text: _isInCart ? 'In cart' : 'Add To Cart',
                                maxLines: 1,
                                color: _isInCart ? Colors.white : color,
                                textSize: constraints.maxWidth * 0.08,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}