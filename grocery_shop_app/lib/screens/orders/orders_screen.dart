import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/inner_screens/product_details.dart';
import 'package:grocery_shop_app/models/order_model.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../services/utils.dart';
import '../../widgets/text_widget.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key}) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late String orderDateToShow;

  @override
  void didChangeDependencies() {
    final ordersModel = Provider.of<OrderModel>(context);
    var orderDate = ordersModel.orderDate.toDate();
    orderDateToShow = '${orderDate.day}/${orderDate.month}/${orderDate.year}';
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ordersModel = Provider.of<OrderModel>(context);
    var status = ordersModel.status.toString();
    final Color color = Utils(context).color;
    Size size = Utils(context).getScreenSize;
    final productProvider = Provider.of<ProductsProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Date: $orderDateToShow',
              style: TextStyle(fontSize: 18, color: color),
            ),
            Flexible(
              child: Material(
                color: status == 'Delivered' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: TextWidget(
                      text: status,
                      color: Colors.white,
                      textSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ordersModel.products.length,
          itemBuilder: (ctx, index) {
            final product = ordersModel.products[index];
            final getCurrProduct = productProvider.findProById(product['productId']);
            return ListTile(
              leading: FancyShimmerImage(
                width: size.width * 0.2,
                imageUrl: getCurrProduct.imageUrl,
                boxFit: BoxFit.fill,
              ),
              title: TextWidget(
                text: '${getCurrProduct.title}  x${product['quantity']}',
                color: color,
                textSize: 18,
              ),
              subtitle: TextWidget(text:'Price: \Rs.${product['price'].toStringAsFixed(2)}',textSize: 12,color:color),
              onTap: () {
                 Navigator.of(context).pushNamed(
            ProductDetails.routeName,
            arguments: getCurrProduct.id,
          );
              },
            );
          },
        ),
        SizedBox(height: 10),
        Text(
          'Total To Be Paid: \Rs.${double.parse(ordersModel.totalPrice).toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, color: color),
        ),
      ],
    );
  }
}