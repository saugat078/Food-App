import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/inner_screens/edit_prod.dart';

import '../services/global_method.dart';
import '../services/utils.dart';
import 'text_widget.dart';

class OrderProductWidget extends StatefulWidget {
  const OrderProductWidget({
    Key? key,
    required this.id,
    required this.quantity
  }) : super(key: key);
  final String id;
  final int quantity;
  @override
  _OrderProductWidgetState createState() => _OrderProductWidgetState();
}

class _OrderProductWidgetState extends State<OrderProductWidget> {
  bool _isLoading = false;
  String title = '';
  String? productCat='';
  String? imageUrl;
  String price = '0.0';
  double salePrice = 0.0;
  bool isOnSale = false;
  bool isPiece = false;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DocumentSnapshot productsDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .get();
      if (productsDoc == null) {
        return;
      } else {
        title = productsDoc.get('title');
        productCat = productsDoc.get('productCategoryName');
        imageUrl = productsDoc.get('imageUrl');
        price = productsDoc.get('price');
        salePrice = productsDoc.get('salePrice');
        isOnSale = productsDoc.get('isOnSale');
        isPiece = productsDoc.get('isPiece');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      GlobalMethods.errorDialog(subtitle: '$error', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;

    final color = Utils(context).color;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor.withOpacity(0.6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Image.network(
                        imageUrl == null
                            ? 'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png'
                            : imageUrl!,
                        fit: BoxFit.fill,
                        // width: screenWidth * 0.12,
                        height: size.width * 0.12,
                      ),
                    ),
                    const Spacer(),
                    
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    TextWidget(
                      text: isOnSale
                          ? '\Rs.${salePrice.toStringAsFixed(2)}'
                          : '\Rs.$price',
                      color: color,
                      textSize: 18,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Visibility(
                        visible: isOnSale,
                        child: Text(
                          '\Rs.$price',
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: color),
                        )),
                    const Spacer(),
                    TextWidget(
                      text: isPiece ? 'Piece' : '1Kg',
                      color: color,
                      textSize: 18,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  text: title,
                  color: color,
                  textSize: 24,
                  isTitle: true,
                ),
               const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  text: productCat!,
                  color: color,
                  textSize: 12,
                  isTitle: false,
                ),
                const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  text: 'Quantity Ordered: ${widget.quantity.toString()}',
                  color: color,
                  textSize: 10,
                  isTitle: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
